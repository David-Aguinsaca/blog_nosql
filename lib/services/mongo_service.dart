import 'dart:io' show Socket;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/blog_post_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  String _getEnv(String key, String defaultValue) {
    if (dotenv.isInitialized) {
      return dotenv.env[key] ?? defaultValue;
    }
    return defaultValue;
  }

  String get _dbName => _getEnv('MONGO_DB_NAME', 'ecoblog_db');
  String get _user => _getEnv('MONGO_USER', 'ecouser');
  String get _password => _getEnv('MONGO_PASSWORD', 'ecopassword123');
  int get _port => int.tryParse(_getEnv('MONGO_PORT', '27017')) ?? 27017;
  String get _configuredHost => _getEnv('MONGO_HOST', '127.0.0.1');

  Db? _db;
  DbCollection? _usersCollection;
  DbCollection? _postsCollection;

  bool _isConnected = false;
  String? _lastError;
  String _currentHost = '127.0.0.1';

  bool get isConnected => _isConnected && _db != null && _db!.isConnected;
  String? get lastError => _lastError;
  String get currentHost => _currentHost;

  Future<String> _resolveBestHost(String? requestedHost) async {
    if (requestedHost != null && requestedHost.trim().isNotEmpty) {
      return requestedHost.trim();
    }
    if (kIsWeb) return '127.0.0.1';

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Candidatos en Android:
      // 1. 127.0.0.1 (adb reverse tcp:27017 tcp:27017)
      // 2. 10.4.15.14 (IP LAN del host)
      // 3. 10.0.2.2 (emulador estándar Android Studio)
      // 4. 10.0.3.2 (Genymotion)
      final candidates = {
        _configuredHost,
        '127.0.0.1',
        '10.4.15.14',
        '10.0.2.2',
        '10.0.3.2'
      }.toList();
      for (final candidate in candidates) {
        try {
          final socket = await Socket.connect(
            candidate,
            _port,
            timeout: const Duration(milliseconds: 500),
          );
          await socket.close();
          debugPrint('Host alcanzable para MongoDB en Android: $candidate');
          return candidate;
        } catch (_) {}
      }
      return _configuredHost;
    }

    return _configuredHost;
  }

  Future<bool> connect({String? host}) async {
    if (kIsWeb) {
      _isConnected = false;
      _lastError =
          'En navegadores web no se permiten conexiones directas por socket TCP a MongoDB. '
          'Para conectar en vivo a MongoDB ejecuta en Linux Desktop (flutter run -d linux) o Android. '
          'La app en web continuará en modo local/memoria.';
      debugPrint(
        'ℹ️ [Web] Modo memoria/local activo: Los navegadores web no admiten sockets TCP directos a MongoDB.',
      );
      return false;
    }

    _currentHost = await _resolveBestHost(host);
    final uri =
        'mongodb://$_user:$_password@$_currentHost:$_port/$_dbName?authSource=$_dbName';

    try {
      if (_db != null && _db!.isConnected) {
        await _db!.close();
      }

      _db = await Db.create(uri);
      await _db!.open();

      _usersCollection = _db!.collection('users');
      _postsCollection = _db!.collection('posts');

      _isConnected = true;
      _lastError = null;
      debugPrint(' Conectado exitosamente a MongoDB ($_currentHost)');
      return true;
    } catch (e) {
      _isConnected = false;
      _lastError = e.toString();
      debugPrint(' Error al conectar a MongoDB: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      if (_db != null && _db!.isConnected) {
        await _db!.close();
      }
    } catch (e) {
      debugPrint('Error al desconectar MongoDB: $e');
    } finally {
      _isConnected = false;
    }
  }

  // ================= USERS =================

  Future<UserModel?> findUserByUsername(String username) async {
    if (!isConnected || _usersCollection == null) return null;
    try {
      // Sentencia directa MongoDB: db.users.findOne({ username: "..." })
      final doc = await _usersCollection!.findOne({
        'username': username.trim(),
      });
      if (doc != null) {
        return UserModel.fromMap(Map<String, dynamic>.from(doc));
      }
    } catch (e) {
      debugPrint('Error en findUserByUsername: $e');
    }
    return null;
  }

  Future<bool> createUser(UserModel user) async {
    if (!isConnected || _usersCollection == null) return false;
    try {
      // Sentencia directa MongoDB: db.users.insertOne({ ... })
      final res = await _usersCollection!.insertOne(user.toMap());
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en createUser: $e');
      return false;
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    if (!isConnected || _usersCollection == null) return [];
    try {
      // Sentencia directa MongoDB: db.users.find({})
      final docs = await _usersCollection!.find().toList();
      return docs
          .map((d) => UserModel.fromMap(Map<String, dynamic>.from(d)))
          .toList();
    } catch (e) {
      debugPrint('Error en getAllUsers: $e');
      return [];
    }
  }

  // ================= POSTS =================

  Future<List<BlogPostModel>> fetchPosts() async {
    if (!isConnected || _postsCollection == null) return [];
    try {
      // Sentencia directa MongoDB: db.posts.find({}).sort({ createdAt: -1 })
      final docs = await _postsCollection!
          .modernFind(filter: {}, sort: {'createdAt': -1})
          .toList();
      return docs
          .map((d) => BlogPostModel.fromMap(Map<String, dynamic>.from(d)))
          .toList();
    } catch (e) {
      debugPrint('Error en fetchPosts: $e');
      return [];
    }
  }

  Future<bool> insertPost(BlogPostModel post) async {
    if (!isConnected || _postsCollection == null) return false;
    try {
      // Sentencia directa MongoDB: db.posts.insertOne({ ... })
      final res = await _postsCollection!.insertOne(post.toMap());
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en insertPost: $e');
      return false;
    }
  }

  Future<bool> updatePost({
    required String postId,
    required String title,
    required String topic,
    required String content,
  }) async {
    if (!isConnected || _postsCollection == null) return false;
    try {
      // Sentencia directa MongoDB: db.posts.updateOne({ _id: postId }, { $set: { ... } })
      final res = await _postsCollection!.updateOne(
        {'_id': postId},
        {
          r'$set': {
            'title': title,
            'topic': topic,
            'content': content,
            'isEdited': true,
          },
        },
      );
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en updatePost: $e');
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    if (!isConnected || _postsCollection == null) return false;
    try {
      // Sentencia directa MongoDB: db.posts.deleteOne({ _id: postId })
      final res = await _postsCollection!.deleteOne({'_id': postId});
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en deletePost: $e');
      return false;
    }
  }

  // ================= COMMENTS (NoSQL Embedded) =================

  Future<bool> addComment(String postId, CommentModel comment) async {
    if (!isConnected || _postsCollection == null) return false;
    try {
      // Sentencia directa MongoDB: db.posts.updateOne({ _id: postId }, { $push: { comments: comment } })
      final res = await _postsCollection!.updateOne(
        {'_id': postId},
        {
          r'$push': {'comments': comment.toMap()},
        },
      );
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en addComment: $e');
      return false;
    }
  }

  Future<bool> updateComment(String postId, CommentModel comment) async {
    if (!isConnected || _postsCollection == null) return false;
    try {
      // Sentencia directa MongoDB: db.posts.updateOne({ _id: postId, "comments.id": comment.id }, { $set: { "comments.$": comment } })
      final res = await _postsCollection!.updateOne(
        {'_id': postId, 'comments.id': comment.id},
        {
          r'$set': {r'comments.$': comment.toMap()},
        },
      );
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en updateComment: $e');
      return false;
    }
  }

  Future<bool> deleteComment(String postId, String commentId) async {
    if (!isConnected || _postsCollection == null) return false;
    try {
      // Sentencia directa MongoDB: db.posts.updateOne({ _id: postId }, { $pull: { comments: { id: commentId } } })
      final res = await _postsCollection!.updateOne(
        {'_id': postId},
        {
          r'$pull': {
            'comments': {'id': commentId},
          },
        },
      );
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en deleteComment: $e');
      return false;
    }
  }
}
