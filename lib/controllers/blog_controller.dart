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
    _initSeedData();
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

  void _initSeedData() {
    _posts.addAll([
      BlogPostModel(
        id: 'seed_post_1',
        creatorUsername: 'elena_bio',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        topic: 'Energía Renovable',
        title: 'Microredes solares comunitarias: transformando el consumo energético',
        content:
            'La transición hacia energías limpias no depende únicamente de grandes parques solares, sino de la descentralización. En comunidades rurales y suburbanas, las microredes solares permiten almacenar y distribuir energía limpia sin intermediarios, reduciendo la huella de carbono un 40% en promedio.',
        comments: [
          CommentModel(
            id: 'seed_comm_1',
            postId: 'seed_post_1',
            userName: 'carlos_verde',
            date: DateTime.now().subtract(const Duration(hours: 2)),
            comment: 'Excelente iniciativa. En mi barrio estamos evaluando paneles compartidos.',
          ),
          CommentModel(
            id: 'seed_comm_2',
            postId: 'seed_post_1',
            userName: 'david',
            date: DateTime.now().subtract(const Duration(minutes: 45)),
            comment: 'El almacenamiento con baterías ecológicas es el siguiente gran paso.',
          ),
        ],
      ),
      BlogPostModel(
        id: 'seed_post_2',
        creatorUsername: 'david',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        topic: 'Cero Residuos',
        title: 'Hábitos diarios para reducir el plástico de un solo uso en casa',
        content:
            'Adoptar el estilo de vida zero waste no requiere perfección, sino constancia. Reemplazar bolsas plásticas por tela, comprar granos a granel y reutilizar frascos de vidrio son pasos sencillos que evitan kilogramos de residuos plásticos que terminan en ríos y océanos.',
        comments: [
          CommentModel(
            id: 'seed_comm_3',
            postId: 'seed_post_2',
            userName: 'elena_bio',
            date: DateTime.now().subtract(const Duration(hours: 18)),
            comment: 'Completamente de acuerdo, los pequeños hábitos suman un impacto masivo.',
          ),
        ],
      ),
      BlogPostModel(
        id: 'seed_post_3',
        creatorUsername: 'marina_eco',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        topic: 'Reforestación Urbana',
        title: 'Bosques de bolsillo: biodiversidad en medio del concreto',
        content:
            'El método Miyawaki demuestra que es posible sembrar bosques densos de vegetación nativa en espacios urbanos reducidos. Estos oasis no solo disminuyen la temperatura en las ciudades, sino que atraen aves polinizadoras y mejoran la calidad del aire respirable.',
        comments: [
          CommentModel(
            id: 'seed_comm_4',
            postId: 'seed_post_3',
            userName: 'david',
            date: DateTime.now().subtract(const Duration(days: 1)),
            comment: 'Hemos plantado 20 árboles nativos en el parque central con este método.',
          ),
        ],
      ),
      BlogPostModel(
        id: 'seed_post_4',
        creatorUsername: 'santiago_clima',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        topic: 'Biodiversidad',
        title: 'Importancia vital de los corredores biológicos para polinizadores',
        content:
            'Las abejas y mariposas enfrentan fragmentación en sus hábitats debido a la expansión urbana y pesticidas. Crear jardines con flores silvestres nativas en balcones y aceras conecta sus rutas y protege la seguridad alimentaria global.',
        comments: [],
      ),
    ]);
  }
}
