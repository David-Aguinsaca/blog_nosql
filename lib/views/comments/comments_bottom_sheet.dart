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
  CommentModel? _replyingTo;
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
    final success = await blogCtrl.addComment(
      postId: widget.postId,
      userName: currentUser.username,
      commentText: text,
      parentCommentId: _replyingTo?.id,
    );

    if (mounted) {
      if (success) {
        _newCommentController.clear();
        _focusNode.unfocus();
        setState(() {
          _replyingTo = null;
          _isSubmitting = false;
        });
      } else {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo publicar el comentario.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleEditComment(CommentModel comment) async {
    final updatedText = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (dialogCtx) => _EditCommentDialog(initialText: comment.comment),
    );

    if (updatedText != null && updatedText.isNotEmpty && mounted) {
      await context.read<BlogController>().updateComment(
        postId: widget.postId,
        commentId: comment.id,
        newCommentText: updatedText,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentario actualizado correctamente'),
            backgroundColor: AppColors.sageGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteComment(CommentModel comment) async {
    final shouldDelete = await ConfirmDeleteDialog.show(
      context,
      title: 'Eliminar comentario',
      message:
          '¿Estás seguro de que deseas eliminar este comentario? Se eliminarán también todas sus respuestas.',
      confirmText: 'Eliminar',
    );

    if (shouldDelete && mounted) {
      await context.read<BlogController>().deleteComment(
        postId: widget.postId,
        commentId: comment.id,
      );
      if (mounted) {
        if (_replyingTo?.id == comment.id) {
          setState(() => _replyingTo = null);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentario y respuestas eliminados'),
            backgroundColor: AppColors.danger,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildCommentCard(
    CommentModel c,
    String? currentUsername,
    bool isReply,
  ) {
    final isOwner =
        currentUsername != null &&
        c.userName.toLowerCase() == currentUsername.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isReply
            ? Colors.white
            : (isOwner
                ? AppColors.paleLime.withValues(alpha: 0.45)
                : AppColors.background),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isReply
              ? AppColors.softOlive.withValues(alpha: 0.6)
              : (isOwner ? AppColors.softOlive : AppColors.borderLight),
          width: 1,
        ),
        boxShadow: isReply
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isReply ? 12 : 14,
                backgroundColor: isReply
                    ? AppColors.paleLime
                    : AppColors.sageGreen,
                child: Text(
                  c.userName.isNotEmpty ? c.userName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: isReply ? AppColors.primaryTeal : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isReply ? 11 : 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            c.userName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isReply ? 12.5 : 13,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (isOwner) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryTeal,
                              borderRadius: BorderRadius.circular(6),
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
                    size: 17,
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
                    size: 17,
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
          const SizedBox(height: 6),
          // Botón Responder
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(
                Icons.reply_rounded,
                size: 15,
                color: AppColors.primaryTeal,
              ),
              label: const Text(
                'Responder',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                setState(() => _replyingTo = c);
                _focusNode.requestFocus();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCommentTree(
    List<CommentModel> allComments,
    String? parentId,
    int depth,
    String? currentUsername,
  ) {
    final children =
        allComments.where((c) => c.parentCommentId == parentId).toList();
    final widgets = <Widget>[];

    for (final c in children) {
      final isReply = depth > 0;
      final indent = depth > 0 ? (depth > 2 ? 32.0 : depth * 20.0) : 0.0;

      widgets.add(
        Padding(
          padding: EdgeInsets.only(left: indent, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isReply) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 14, right: 6),
                  child: Icon(
                    Icons.subdirectory_arrow_right_rounded,
                    size: 16,
                    color: AppColors.sageGreen.withValues(alpha: 0.8),
                  ),
                ),
              ],
              Expanded(
                child: _buildCommentCard(c, currentUsername, isReply),
              ),
            ],
          ),
        ),
      );

      // Agregar respuestas hijas de manera recursiva
      widgets.addAll(
        _buildCommentTree(allComments, c.id, depth + 1, currentUsername),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final blogCtrl = context.watch<BlogController>();
    final authCtrl = context.watch<AuthController>();
    final currentUsername = authCtrl.currentUser?.username;

    final post = blogCtrl.getPostById(widget.postId);
    final comments = post?.comments ?? [];

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final commentTreeWidgets = _buildCommentTree(
      comments,
      null,
      0,
      currentUsername,
    );

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
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

          // Lista jerárquica de comentarios
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
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: commentTreeWidgets,
                  ),
          ),

          // Indicador visual de modo respuesta
          if (_replyingTo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.paleLime.withValues(alpha: 0.6),
                border: const Border(
                  top: BorderSide(color: AppColors.softOlive, width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.reply_rounded,
                    size: 16,
                    color: AppColors.primaryTeal,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Respondiendo a @${_replyingTo!.userName}: "${_replyingTo!.comment}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _replyingTo = null),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Barra inferior de entrada para nuevo comentario / respuesta
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
                      hintText: _replyingTo != null
                          ? 'Escribe tu respuesta a @${_replyingTo!.userName}...'
                          : (currentUsername != null
                              ? 'Comenta como @$currentUsername...'
                              : 'Escribe un comentario...'),
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
                  tooltip: _replyingTo != null
                      ? 'Publicar respuesta'
                      : 'Publicar comentario',
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

class _EditCommentDialog extends StatefulWidget {
  final String initialText;

  const _EditCommentDialog({required this.initialText});

  @override
  State<_EditCommentDialog> createState() => _EditCommentDialogState();
}

class _EditCommentDialogState extends State<_EditCommentDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
        controller: _controller,
        maxLines: 3,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Modifica tu comentario...',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryTeal,
          ),
          onPressed: () {
            final text = _controller.text.trim();
            Navigator.of(context).pop(text);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
