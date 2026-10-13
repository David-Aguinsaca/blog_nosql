import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../models/blog_post_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';

class MongoService {
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;
  MongoService._internal();

  static const String _defaultDbName = 'ecoblog_db';
  static const String _defaultUser = 'ecouser';
  static const String _defaultPassword = 'ecopassword123';
  static const int _defaultPort = 27017;

  Db? _db;
  DbCollection? _usersCollection;
  DbCollection? _postsCollection;

  bool _isConnected = false;
  String? _lastError;
  String _currentHost = '127.0.0.1';

  bool get isConnected => _isConnected && _db != null && _db!.isConnected;
  String? get lastError => _lastError;
  String get currentHost => _currentHost;

  String _determineDefaultHost() {
    if (kIsWeb) return '127.0.0.1';
    try {
      if (Platform.isAndroid) {
        return '10.0.2.2';
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  Future<bool> connect({String? host}) async {
    _currentHost = host ?? _determineDefaultHost();
    final uri =
        'mongodb://$_defaultUser:$_defaultPassword@$_currentHost:$_defaultPort/$_defaultDbName?authSource=$_defaultDbName';

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
      final doc = await _usersCollection!.findOne(
        where.eq('username', username.trim()),
      );
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
      final docs = await _postsCollection!
          .find(where.sortBy('createdAt', descending: true))
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
      final res = await _postsCollection!.updateOne(
        where.eq('_id', postId),
        modify
            .set('title', title)
            .set('topic', topic)
            .set('content', content)
            .set('isEdited', true),
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
      final res = await _postsCollection!.deleteOne(where.eq('_id', postId));
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
      final res = await _postsCollection!.updateOne(
        where.eq('_id', postId),
        modify.push('comments', comment.toMap()),
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
      final res = await _postsCollection!.updateOne(
        where.eq('_id', postId).and(where.eq('comments.id', comment.id)),
        modify.set(r'comments.$', comment.toMap()),
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
      final res = await _postsCollection!.updateOne(
        where.eq('_id', postId),
        modify.pull('comments', {'id': commentId}),
      );
      return res.isSuccess;
    } catch (e) {
      debugPrint('Error en deleteComment: $e');
      return false;
    }
  }
}
