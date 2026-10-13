import 'package:flutter/foundation.dart';
import '../models/blog_post_model.dart';
import '../models/comment_model.dart';
import '../services/mongo_service.dart';

class BlogController extends ChangeNotifier {
  final MongoService _mongoService = MongoService();
  final List<BlogPostModel> _posts = [];
  String _searchQuery = '';
  bool _isLoading = false;

  BlogController() {
    initializeMongo();
  }

  MongoService get mongoService => _mongoService;
  List<BlogPostModel> get allPosts => List.unmodifiable(_posts);
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<BlogPostModel> get filteredPosts {
    if (_searchQuery.trim().isEmpty) {
      return List.unmodifiable(_posts);
    }
    final query = _searchQuery.trim().toLowerCase();
    return _posts.where((p) => p.title.toLowerCase().contains(query)).toList();
  }

  List<BlogPostModel> getUserPosts(String username) {
    return _posts
        .where(
          (p) => p.creatorUsername.toLowerCase() == username.toLowerCase(),
        )
        .toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Inicializa la conexión con MongoDB y sincroniza los datos
  Future<bool> initializeMongo({String? host}) async {
    _isLoading = true;
    notifyListeners();

    final connected = await _mongoService.connect(host: host);
    if (connected) {
      await syncFromMongo();
    }

    _isLoading = false;
    notifyListeners();
    return connected;
  }

  /// Sincroniza las publicaciones directamente desde la colección 'posts' de MongoDB
  Future<void> syncFromMongo() async {
    if (!_mongoService.isConnected) return;
    try {
      final dbPosts = await _mongoService.fetchPosts();
      if (dbPosts.isNotEmpty) {
        _posts
          ..clear()
          ..addAll(dbPosts);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error en syncFromMongo: $e');
    }
  }

  Future<BlogPostModel> addPost({
    required String creatorUsername,
    required String topic,
    required String title,
    required String content,
  }) async {
    final newPost = BlogPostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      creatorUsername: creatorUsername,
      createdAt: DateTime.now(),
      topic: topic.trim(),
      title: title.trim(),
      content: content.trim(),
      comments: [],
    );

    _posts.insert(0, newPost);
    notifyListeners();

    if (_mongoService.isConnected) {
      await _mongoService.insertPost(newPost);
    }

    return newPost;
  }

  Future<bool> updatePost({
    required String postId,
    required String topic,
    required String title,
    required String content,
  }) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final current = _posts[index];
      _posts[index] = current.copyWith(
        topic: topic.trim(),
        title: title.trim(),
        content: content.trim(),
        isEdited: true,
      );
      notifyListeners();

      if (_mongoService.isConnected) {
        await _mongoService.updatePost(
          postId: postId,
          topic: topic.trim(),
          title: title.trim(),
          content: content.trim(),
        );
      }
      return true;
    }
    return false;
  }

  Future<bool> deletePost(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts.removeAt(index);
      notifyListeners();

      if (_mongoService.isConnected) {
        await _mongoService.deletePost(postId);
      }
      return true;
    }
    return false;
  }

  Future<bool> addComment({
    required String postId,
    required String userName,
    required String commentText,
  }) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newComment = CommentModel(
        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
        postId: postId,
        userName: userName,
        date: DateTime.now(),
        comment: commentText.trim(),
      );

      final updatedComments = List<CommentModel>.from(post.comments)..add(newComment);
      _posts[index] = post.copyWith(comments: updatedComments);
      notifyListeners();

      if (_mongoService.isConnected) {
        await _mongoService.addComment(postId, newComment);
      }
      return true;
    }
    return false;
  }

  Future<bool> updateComment({
    required String postId,
    required String commentId,
    required String newCommentText,
  }) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final commentIndex = post.comments.indexWhere((c) => c.id == commentId);
      if (commentIndex != -1) {
        final comment = post.comments[commentIndex];
        final updatedComment = comment.copyWith(
          comment: newCommentText.trim(),
          isEdited: true,
        );
        final updatedList = List<CommentModel>.from(post.comments);
        updatedList[commentIndex] = updatedComment;

        _posts[postIndex] = post.copyWith(comments: updatedList);
        notifyListeners();

        if (_mongoService.isConnected) {
          await _mongoService.updateComment(postId, updatedComment);
        }
        return true;
      }
    }
    return false;
  }

  Future<bool> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final updatedList = post.comments.where((c) => c.id != commentId).toList();
      _posts[postIndex] = post.copyWith(comments: updatedList);
      notifyListeners();

      if (_mongoService.isConnected) {
        await _mongoService.deleteComment(postId, commentId);
      }
      return true;
    }
    return false;
  }

  BlogPostModel? getPostById(String id) {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) return _posts[index];
    return null;
  }
}
