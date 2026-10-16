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

    test('Add replies (sub-comments) and verify hierarchical helpers', () async {
      final post = await blogController.addPost(
        creatorUsername: 'carlos',
        topic: 'Energía',
        title: 'Post con sub-comentarios',
        content: 'Debate sobre paneles solares.',
      );

      // 1. Agregar comentario raíz
      final rootSuccess = await blogController.addComment(
        postId: post.id,
        userName: 'elena',
        commentText: '¿Cuál es el retorno de inversión promedio?',
      );
      expect(rootSuccess, true);

      final rootComment = blogController.getRootComments(post.id).first;
      expect(rootComment.parentCommentId, isNull);

      // 2. Agregar sub-comentario (respuesta)
      final replySuccess = await blogController.addComment(
        postId: post.id,
        userName: 'carlos',
        commentText: 'Suele ser entre 4 y 6 años con subsidios.',
        parentCommentId: rootComment.id,
      );
      expect(replySuccess, true);

      final replies = blogController.getRepliesForComment(post.id, rootComment.id);
      expect(replies.length, 1);
      expect(replies.first.parentCommentId, rootComment.id);
      expect(replies.first.comment, 'Suele ser entre 4 y 6 años con subsidios.');

      // 3. Agregar respuesta de segundo nivel
      final subReplySuccess = await blogController.addComment(
        postId: post.id,
        userName: 'marina',
        commentText: '¡Excelente, gracias por el dato!',
        parentCommentId: replies.first.id,
      );
      expect(subReplySuccess, true);

      final allPostComments = blogController.getPostById(post.id)!.comments;
      expect(allPostComments.length, 3);
      expect(blogController.getRootComments(post.id).length, 1);
    });

    test('Cascading deletion: deleting parent comment removes all nested replies', () async {
      final post = await blogController.addPost(
        creatorUsername: 'marina',
        topic: 'Océanos',
        title: 'Arrecifes de coral',
        content: 'Protección de biodiversidad.',
      );

      // Comentario raíz 1 con 2 respuestas (una de 1er nivel y otra de 2do nivel)
      await blogController.addComment(
        postId: post.id,
        userName: 'usuario1',
        commentText: 'Comentario raíz 1',
      );
      final root1 = blogController.getRootComments(post.id).first;

      await blogController.addComment(
        postId: post.id,
        userName: 'usuario2',
        commentText: 'Respuesta nivel 1',
        parentCommentId: root1.id,
      );
      final reply1 = blogController.getRepliesForComment(post.id, root1.id).first;

      await blogController.addComment(
        postId: post.id,
        userName: 'usuario3',
        commentText: 'Respuesta nivel 2',
        parentCommentId: reply1.id,
      );

      // Comentario raíz 2 independiente
      await blogController.addComment(
        postId: post.id,
        userName: 'usuario4',
        commentText: 'Comentario raíz 2 independiente',
      );

      expect(blogController.getPostById(post.id)!.comments.length, 4);

      // Eliminar comentario raíz 1: debe eliminar raíz 1, respuesta nivel 1 y respuesta nivel 2
      final deleted = await blogController.deleteComment(
        postId: post.id,
        commentId: root1.id,
      );
      expect(deleted, true);

      final remaining = blogController.getPostById(post.id)!.comments;
      expect(remaining.length, 1);
      expect(remaining.first.comment, 'Comentario raíz 2 independiente');
    });
  });
}

