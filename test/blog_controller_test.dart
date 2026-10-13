import 'package:flutter_test/flutter_test.dart';
import 'package:blog_nosql/controllers/blog_controller.dart';

void main() {
  group('BlogController Tests', () {
    late BlogController blogController;

    setUp(() {
      blogController = BlogController();
    });

    test('Initial posts are empty without mockup', () {
      expect(blogController.allPosts.isEmpty, true);
      expect(blogController.filteredPosts.isEmpty, true);
    });

    test('Filter by title works reactively', () async {
      await blogController.addPost(
        creatorUsername: 'usuario1',
        topic: 'Energía',
        title: 'Paneles Solares en Comunidades',
        content: 'Contenido sobre energía solar.',
      );
      await blogController.addPost(
        creatorUsername: 'usuario2',
        topic: 'Agua',
        title: 'Cuidado de Cuencas Hídricas',
        content: 'Contenido sobre agua.',
      );

      blogController.setSearchQuery('Solar');
      expect(
        blogController.filteredPosts.every(
          (p) => p.title.toLowerCase().contains('solar'),
        ),
        true,
      );
      expect(blogController.filteredPosts.length, 1);

      blogController.clearSearchQuery();
      expect(blogController.filteredPosts.length, 2);
    });

    test('getUserPosts returns only posts by specified user', () async {
      await blogController.addPost(
        creatorUsername: 'autor_a',
        topic: 'Tema A',
        title: 'Post de autor A',
        content: 'Contenido A',
      );
      await blogController.addPost(
        creatorUsername: 'autor_b',
        topic: 'Tema B',
        title: 'Post de autor B',
        content: 'Contenido B',
      );

      final postsA = blogController.getUserPosts('autor_a');
      expect(postsA.length, 1);
      expect(postsA.first.creatorUsername, 'autor_a');
    });

    test('Add post inserts new publication at the beginning', () async {
      final initialCount = blogController.allPosts.length;
      await blogController.addPost(
        creatorUsername: 'david',
        topic: 'Agroecología',
        title: 'Cultivos sin pesticidas en huertos urbanos',
        content: 'La agroecología fomenta la salud del suelo y evita químicos.',
      );

      expect(blogController.allPosts.length, initialCount + 1);
      final latest = blogController.allPosts.first;
      expect(latest.title, 'Cultivos sin pesticidas en huertos urbanos');
      expect(latest.creatorUsername, 'david');
      expect(latest.topic, 'Agroecología');
    });

    test('Update post modifies post content', () async {
      final newPost = await blogController.addPost(
        creatorUsername: 'david',
        topic: 'Tema Inicial',
        title: 'Título Inicial',
        content: 'Contenido Inicial',
      );

      final success = await blogController.updatePost(
        postId: newPost.id,
        topic: 'Tema Actualizado',
        title: 'Título Modificado',
        content: 'Contenido editado con éxito.',
      );

      expect(success, true);
      final updated = blogController.getPostById(newPost.id);
      expect(updated?.title, 'Título Modificado');
      expect(updated?.topic, 'Tema Actualizado');
      expect(updated?.content, 'Contenido editado con éxito.');
      expect(updated?.isEdited, true);
    });

    test('Delete post removes publication from list', () async {
      final newPost = await blogController.addPost(
        creatorUsername: 'david',
        topic: 'Para Eliminar',
        title: 'Post temporal',
        content: 'Contenido a borrar',
      );
      final initialCount = blogController.allPosts.length;

      final success = await blogController.deletePost(newPost.id);
      expect(success, true);
      expect(blogController.allPosts.length, initialCount - 1);
      expect(blogController.getPostById(newPost.id), isNull);
    });

    test('Add, update and delete comments on a post', () async {
      final post = await blogController.addPost(
        creatorUsername: 'david',
        topic: 'Conservación',
        title: 'Artículo con comentarios',
        content: 'Contenido base',
      );

      // 1. Add comment
      final addSuccess = await blogController.addComment(
        postId: post.id,
        userName: 'elena',
        commentText: 'Excelente artículo para la conservación.',
      );
      expect(addSuccess, true);

      final updatedPost = blogController.getPostById(post.id)!;
      expect(updatedPost.comments.length, 1);
      final addedComment = updatedPost.comments.last;
      expect(addedComment.comment, 'Excelente artículo para la conservación.');
      expect(addedComment.userName, 'elena');

      // 2. Update comment
      final editSuccess = await blogController.updateComment(
        postId: post.id,
        commentId: addedComment.id,
        newCommentText: 'Comentario editado con más detalles.',
      );
      expect(editSuccess, true);

      final postAfterEdit = blogController.getPostById(post.id)!;
      final editedComment = postAfterEdit.comments.firstWhere(
        (c) => c.id == addedComment.id,
      );
      expect(editedComment.comment, 'Comentario editado con más detalles.');
      expect(editedComment.isEdited, true);

      // 3. Delete comment
      final deleteSuccess = await blogController.deleteComment(
        postId: post.id,
        commentId: addedComment.id,
      );
      expect(deleteSuccess, true);

      final postAfterDelete = blogController.getPostById(post.id)!;
      expect(postAfterDelete.comments.isEmpty, true);
    });
  });
}
