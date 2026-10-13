import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/blog_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/post_card.dart';
import 'create_post_view.dart';
import 'edit_post_view.dart';

class MyPostsView extends StatelessWidget {
  const MyPostsView({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final blogCtrl = context.watch<BlogController>();
    final currentUser = authCtrl.currentUser;

    final myPosts = currentUser != null
        ? blogCtrl.getUserPosts(currentUser.username)
        : [];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mis Publicaciones'),
      ),
      body: SafeArea(
        child: myPosts.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.paleLime.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.article_outlined,
                          size: 50,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Aún no tienes publicaciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Comparte tus proyectos, ideas ecológicas o reflexiones para que la comunidad pueda leerte.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Crear mi primera publicación'),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CreatePostView(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner resumen
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.paleLime.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.softOlive, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.eco_rounded,
                          color: AppColors.primaryTeal,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tienes ${myPosts.length} ${myPosts.length == 1 ? "publicación activa" : "publicaciones activas"} en EcoBlog.',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryTeal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lista de publicaciones
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: myPosts.length,
                      itemBuilder: (context, index) {
                        final post = myPosts[index];
                        return PostCard(
                          post: post,
                          isOwner: true,
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditPostView(post: post),
                              ),
                            );
                          },
                          onDelete: () {
                            blogCtrl.deletePost(post.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Publicación eliminada correctamente.'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
