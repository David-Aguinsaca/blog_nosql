import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/blog_controller.dart';
import '../../models/comment_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confirm_delete_dialog.dart';

class CommentsBottomSheet extends StatefulWidget {
  final String postId;

  const CommentsBottomSheet({super.key, required this.postId});

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CommentsBottomSheet(postId: postId),
    );
  }

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _newCommentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _newCommentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  Future<void> _submitComment() async {
    final text = _newCommentController.text.trim();
    if (text.isEmpty) return;

    final authCtrl = context.read<AuthController>();
    final blogCtrl = context.read<BlogController>();
    final currentUser = authCtrl.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para comentar.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    blogCtrl.addComment(
      postId: widget.postId,
      userName: currentUser.username,
      commentText: text,
    );

    _newCommentController.clear();
    _focusNode.unfocus();
    setState(() => _isSubmitting = false);
  }

  Future<void> _handleEditComment(CommentModel comment) async {
    final editController = TextEditingController(text: comment.comment);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Editar comentario',
          style: TextStyle(
            color: AppColors.primaryTeal,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: editController,
          maxLines: 3,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Modifica tu comentario...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final updatedText = editController.text.trim();
      if (updatedText.isNotEmpty) {
        context.read<BlogController>().updateComment(
          postId: widget.postId,
          commentId: comment.id,
          newCommentText: updatedText,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentario actualizado correctamente'),
            backgroundColor: AppColors.sageGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
    editController.dispose();
  }

  Future<void> _handleDeleteComment(CommentModel comment) async {
    final shouldDelete = await ConfirmDeleteDialog.show(
      context,
      title: 'Eliminar comentario',
      message:
          '¿Estás seguro de que deseas eliminar este comentario? Esta acción no se puede deshacer.',
      confirmText: 'Eliminar',
    );

    if (shouldDelete && mounted) {
      context.read<BlogController>().deleteComment(
        postId: widget.postId,
        commentId: comment.id,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentario eliminado'),
          backgroundColor: AppColors.danger,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final blogCtrl = context.watch<BlogController>();
    final authCtrl = context.watch<AuthController>();
    final currentUsername = authCtrl.currentUser?.username;

    final post = blogCtrl.getPostById(widget.postId);
    final comments = post?.comments ?? [];

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de arrastre superior
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Cabecera del modal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.primaryTeal,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Comentarios (${comments.length})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryTeal,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cerrar',
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),
          // Lista de comentarios
          Expanded(
            child: comments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 48,
                            color: AppColors.sageGreen.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Aún no hay comentarios.',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Sé la primera persona en compartir tu perspectiva ecológica.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: comments.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final c = comments[index];
                      final isOwner =
                          currentUsername != null &&
                          c.userName.toLowerCase() ==
                              currentUsername.toLowerCase();

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isOwner
                              ? AppColors.paleLime.withValues(alpha: 0.45)
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isOwner
                                ? AppColors.softOlive
                                : AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.sageGreen,
                                  child: Text(
                                    c.userName.isNotEmpty
                                        ? c.userName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            c.userName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: AppColors.textDark,
                                            ),
                                          ),
                                          if (isOwner) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 1,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryTeal,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'Tú',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (c.isEdited) ...[
                                            const SizedBox(width: 6),
                                            const Text(
                                              '(editado)',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textLight,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      Text(
                                        _formatDate(c.date),
                                        style: const TextStyle(
                                          color: AppColors.textLight,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isOwner) ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: AppColors.primaryTeal,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Editar comentario',
                                    onPressed: () => _handleEditComment(c),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: AppColors.danger,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    tooltip: 'Eliminar comentario',
                                    onPressed: () => _handleDeleteComment(c),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                c.comment,
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 13.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Barra inferior de entrada para nuevo comentario
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColors.borderLight, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newCommentController,
                    focusNode: _focusNode,
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: currentUsername != null
                          ? 'Comenta como @$currentUsername...'
                          : 'Escribe un comentario...',
                      hintStyle: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textLight,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.borderLight,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.primaryTeal,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                  ),
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  tooltip: 'Publicar comentario',
                  onPressed: _isSubmitting ? null : _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
