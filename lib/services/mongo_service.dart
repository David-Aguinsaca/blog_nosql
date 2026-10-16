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
  DbCollection? _commentsCollection;

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
        '10.0.3.2',
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
        '[Web] Modo memoria/local activo: Los navegadores web no admiten sockets TCP directos a MongoDB.',
      );
      return false;
    }

    _currentHost = await _resolveBestHost(host);

    final uri =
        'mongodb+srv://$_user:$_password@appambiente.astsdqz.mongodb.net/$_dbName?appName=AppAmbiente';

    try {
      if (_db != null && _db!.isConnected) {
        await _db!.close();
      }

      _db = await Db.create(uri);
      await _db!.open();

      _usersCollection = _db!.collection('users');
      _postsCollection = _db!.collection('posts');
      _commentsCollection = _db!.collection('comments');

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

  Future<bool> updateUserPassword(String userId, String newHashedPassword) async {
    if (!isConnected || _usersCollection == null) return false;
    try {
      // Sentencia directa MongoDB: db.users.updateOne({ _id: userId }, { $set: { password: ... } })
      final res = await _usersCollection!.updateOne(
        {'_id': userId},
        {
          r'$set': {'password': newHashedPassword},
        },
      );
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en updateUserPassword: $e');
      return false;
    }
  }

  // ================= POSTS =================

  /// Helper privado para consultar comentarios desde la colección 'comments'
  /// agrupados por postId en un `Map<String, List<CommentModel>>`.
  Future<Map<String, List<CommentModel>>> _fetchCommentsGroupedByPost({
    List<String>? postIds,
  }) async {
    if (!isConnected || _commentsCollection == null) return {};
    try {
      final Map<String, dynamic> filter =
          (postIds != null && postIds.isNotEmpty)
              ? {
                  'postId': {r'$in': postIds},
                }
              : {};

      final commentDocs = await _commentsCollection!
          .modernFind(filter: filter, sort: {'date': 1})
          .toList();

      final map = <String, List<CommentModel>>{};
      for (final doc in commentDocs) {
        final comment = CommentModel.fromMap(Map<String, dynamic>.from(doc));
        map.putIfAbsent(comment.postId, () => []).add(comment);
      }
      return map;
    } catch (e) {
      debugPrint('Error en _fetchCommentsGroupedByPost: $e');
      return {};
    }
  }

  Future<List<BlogPostModel>> fetchPosts() async {
    if (!isConnected || _postsCollection == null) return [];
    try {
      // Sentencia directa MongoDB: db.posts.find({}).sort({ createdAt: -1 })
      final docs = await _postsCollection!
          .modernFind(filter: {}, sort: {'createdAt': -1})
          .toList();

      final commentsByPost = await _fetchCommentsGroupedByPost();

      return docs.map((d) {
        final post = BlogPostModel.fromMap(Map<String, dynamic>.from(d));
        return post.copyWith(comments: commentsByPost[post.id] ?? []);
      }).toList();
    } catch (e) {
      debugPrint('Error en fetchPosts: $e');
      return [];
    }
  }

  /// Consulta directa a MongoDB para filtrar publicaciones por título
  /// Sentencia nativa: db.posts.find({ title: { $regex: titleQuery, $options: "i" } }).sort({ createdAt: -1 })
  Future<List<BlogPostModel>> searchPostsByTitle(String titleQuery) async {
    if (!isConnected || _postsCollection == null) return [];
    try {
      final query = titleQuery.trim();
      final Map<String, dynamic> filter = query.isEmpty
          ? {}
          : {
              'title': {r'$regex': query, r'$options': 'i'},
            };

      final docs = await _postsCollection!
          .modernFind(filter: filter, sort: {'createdAt': -1})
          .toList();

      final postIds =
          docs.map((d) => (d['_id'] ?? d['id']).toString()).toList();
      final commentsByPost =
          await _fetchCommentsGroupedByPost(postIds: postIds);

      return docs.map((d) {
        final post = BlogPostModel.fromMap(Map<String, dynamic>.from(d));
        return post.copyWith(comments: commentsByPost[post.id] ?? []);
      }).toList();
    } catch (e) {
      debugPrint('Error en searchPostsByTitle: $e');
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
      // 1. Sentencia directa MongoDB: db.posts.deleteOne({ _id: postId })
      final res = await _postsCollection!.deleteOne({'_id': postId});

      // 2. Eliminación en cascada en la colección 'comments'
      // Sentencia directa MongoDB: db.comments.deleteMany({ postId: postId })
      if (_commentsCollection != null) {
        await _commentsCollection!.deleteMany({'postId': postId});
      }

      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en deletePost: $e');
      return false;
    }
  }

  // ================= COMMENTS (Referenced Collection) =================

  /// Consulta directa a MongoDB: db.comments.find({ postId: postId }).sort({ date: 1 })
  Future<List<CommentModel>> fetchCommentsByPost(String postId) async {
    if (!isConnected || _commentsCollection == null) return [];
    try {
      final docs = await _commentsCollection!
          .modernFind(filter: {'postId': postId}, sort: {'date': 1})
          .toList();
      return docs
          .map((d) => CommentModel.fromMap(Map<String, dynamic>.from(d)))
          .toList();
    } catch (e) {
      debugPrint('Error en fetchCommentsByPost: $e');
      return [];
    }
  }

  /// Inserta un nuevo comentario o sub-comentario en la colección 'comments'
  /// Sentencia directa MongoDB: db.comments.insertOne({ ... })
  Future<bool> addComment(CommentModel comment) async {
    if (!isConnected || _commentsCollection == null) return false;
    try {
      final res = await _commentsCollection!.insertOne(comment.toMap());
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en addComment: $e');
      return false;
    }
  }

  /// Actualiza el texto de un comentario existente en la colección 'comments'
  /// Sentencia directa MongoDB: db.comments.updateOne({ _id: commentId }, { $set: { comment: ..., isEdited: true } })
  Future<bool> updateComment(CommentModel comment) async {
    if (!isConnected || _commentsCollection == null) return false;
    try {
      final res = await _commentsCollection!.updateOne(
        {'_id': comment.id},
        {
          r'$set': {
            'comment': comment.comment,
            'isEdited': true,
          },
        },
      );
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en updateComment: $e');
      return false;
    }
  }

  /// Elimina en cascada una lista de comentarios por sus IDs
  /// Sentencia directa MongoDB: db.comments.deleteMany({ _id: { $in: [...] } })
  Future<bool> deleteCommentsByIds(List<String> commentIds) async {
    if (!isConnected || _commentsCollection == null || commentIds.isEmpty) {
      return false;
    }
    try {
      final res = await _commentsCollection!.deleteMany({
        '_id': {
          r'$in': commentIds,
        },
      });
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en deleteCommentsByIds: $e');
      return false;
    }
  }
}

