import 'package:flutter/material.dart';
import '../models/blog_post_model.dart';
import '../theme/app_theme.dart';
import '../views/comments/comments_bottom_sheet.dart';
import 'confirm_delete_dialog.dart';

class PostCard extends StatelessWidget {
  final BlogPostModel post;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    this.isOwner = false,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera: Avatar, Usuario creador, Fecha de creación y Acciones de propietario
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.paleLime,
                  child: Text(
                    post.creatorUsername.isNotEmpty
                        ? post.creatorUsername[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primaryTeal,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '@${post.creatorUsername}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
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
                                color: AppColors.paleLime,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.softOlive,
                                  width: 0.8,
                                ),
                              ),
                              child: const Text(
                                'Autor',
                                style: TextStyle(
                                  color: AppColors.primaryTeal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Text(
                            _formatDate(post.createdAt),
                            style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                          if (post.isEdited) ...[
                            const SizedBox(width: 4),
                            const Text(
                              'editado',
                              style: TextStyle(
                                color: AppColors.textLight,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Chip de Tema Ambiental
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.paleLime.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.softOlive, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.spa_rounded,
                        size: 13,
                        color: AppColors.sageGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.topic,
                        style: const TextStyle(
                          color: AppColors.primaryTeal,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Título de la publicación
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryTeal,
                height: 1.3,
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 8),

            // Contenido de la publicación
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textDark,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 8),

            // Pie de tarjeta: Botón de comentarios y acciones del propietario (Editar, Eliminar)
            // IMPORTANTE: Se omiten por completo los likes según requerimiento estricto
            Row(
              children: [
                // Botón de Comentarios
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => CommentsBottomSheet.show(context, post.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: AppColors.sageGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.comments.isEmpty
                              ? 'Comentar'
                              : '${post.comments.length} comentarios',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.sageGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Si el usuario logueado es el autor de la publicación
                if (isOwner) ...[
                  // Botón Editar
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.primaryTeal,
                    ),
                    label: const Text(
                      'Editar',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: onEdit,
                  ),

                  const SizedBox(width: 6),

                  // Botón Eliminar
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: AppColors.danger,
                    ),
                    label: const Text(
                      'Eliminar',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      final confirmed = await ConfirmDeleteDialog.show(
                        context,
                        title: 'Eliminar publicación',
                        message:
                            '¿Estás seguro de que deseas eliminar esta publicación sobre "${post.topic}"? Esta acción no se puede deshacer.',
                        confirmText: 'Eliminar',
                      );
                      if (confirmed && onDelete != null) {
                        onDelete!();
                      }
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
