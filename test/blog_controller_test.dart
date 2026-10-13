import 'package:flutter_test/flutter_test.dart';
import 'package:blog_nosql/controllers/blog_controller.dart';

void main() {
  group('BlogController Tests', () {
    late BlogController blogController;

    setUp(() {
      blogController = BlogController();
    });

    test('Initial seed posts are loaded', () {
      expect(blogController.allPosts.isNotEmpty, true);
      expect(blogController.filteredPosts.length, blogController.allPosts.length);
    });

    test('Filter by title works reactively', () {
      blogController.setSearchQuery('Solar');
      expect(
        blogController.filteredPosts.every(
          (p) => p.title.toLowerCase().contains('solar'),
        ),
        true,
      );
      expect(blogController.filteredPosts.length, 1);

      blogController.clearSearchQuery();
      expect(blogController.filteredPosts.length, blogController.allPosts.length);
    });

    test('getUserPosts returns only posts by specified user', () {
      final davidPosts = blogController.getUserPosts('david');
      expect(davidPosts.isNotEmpty, true);
      expect(
        davidPosts.every((p) => p.creatorUsername.toLowerCase() == 'david'),
        true,
      );
    });

    test('Add post inserts new publication at the beginning', () {
      final initialCount = blogController.allPosts.length;
      blogController.addPost(
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

    test('Update post modifies post content', () {
      final post = blogController.allPosts.first;
      final success = blogController.updatePost(
        postId: post.id,
        topic: 'Tema Actualizado',
        title: 'Título Modificado',
        content: 'Contenido editado con éxito.',
      );

      expect(success, true);
      final updated = blogController.getPostById(post.id);
      expect(updated?.title, 'Título Modificado');
      expect(updated?.topic, 'Tema Actualizado');
      expect(updated?.content, 'Contenido editado con éxito.');
      expect(updated?.isEdited, true);
    });

    test('Delete post removes publication from list', () {
      final post = blogController.allPosts.first;
      final initialCount = blogController.allPosts.length;

      final success = blogController.deletePost(post.id);
      expect(success, true);
      expect(blogController.allPosts.length, initialCount - 1);
      expect(blogController.getPostById(post.id), isNull);
    });

    test('Add, update and delete comments on a post', () {
      final post = blogController.allPosts.first;
      final initialCommentsCount = post.comments.length;

      // 1. Add comment
      final addSuccess = blogController.addComment(
        postId: post.id,
        userName: 'david',
        commentText: 'Excelente artículo para la conservación.',
      );
      expect(addSuccess, true);

      final updatedPost = blogController.getPostById(post.id)!;
      expect(updatedPost.comments.length, initialCommentsCount + 1);
      final addedComment = updatedPost.comments.last;
      expect(addedComment.comment, 'Excelente artículo para la conservación.');
      expect(addedComment.userName, 'david');

      // 2. Update comment
      final editSuccess = blogController.updateComment(
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
      final deleteSuccess = blogController.deleteComment(
        postId: post.id,
        commentId: addedComment.id,
      );
      expect(deleteSuccess, true);

      final postAfterDelete = blogController.getPostById(post.id)!;
      expect(postAfterDelete.comments.length, initialCommentsCount);
    });
  });
}
