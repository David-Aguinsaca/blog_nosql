import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/blog_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/post_card.dart';
import '../posts/create_post_view.dart';
import '../posts/edit_post_view.dart';
import '../posts/my_posts_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(
            color: AppColors.primaryTeal,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: const Text(
          '¿Deseas salir de tu cuenta?',
          style: TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
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
              Navigator.of(ctx).pop();
              context.read<AuthController>().logout();
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }

  void _showMongoConfigDialog(BuildContext context, BlogController blogCtrl) {
    final hostController = TextEditingController(
      text: blogCtrl.mongoService.currentHost,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Conexión MongoDB',
          style: TextStyle(
            color: AppColors.primaryTeal,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Host / Dirección IP del servidor MongoDB:',
              style: TextStyle(fontSize: 13, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: hostController,
              decoration: const InputDecoration(
                hintText: 'ej. 127.0.0.1 o 10.4.15.14',
                prefixIcon: Icon(Icons.dns_rounded),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Accesos rápidos:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('127.0.0.1 (adb reverse)', style: TextStyle(fontSize: 11)),
                  onPressed: () => hostController.text = '127.0.0.1',
                ),
                ActionChip(
                  label: const Text('10.4.15.14 (LAN)', style: TextStyle(fontSize: 11)),
                  onPressed: () => hostController.text = '10.4.15.14',
                ),
                ActionChip(
                  label: const Text('10.0.2.2 (AVD)', style: TextStyle(fontSize: 11)),
                  onPressed: () => hostController.text = '10.0.2.2',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryTeal,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final host = hostController.text.trim();
              final success = await blogCtrl.initializeMongo(
                host: host.isEmpty ? null : host,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Conectado a MongoDB en ${blogCtrl.mongoService.currentHost}:27017'
                          : 'No se pudo conectar a MongoDB: ${blogCtrl.mongoService.lastError ?? "Revisa la IP y el contenedor"}',
                    ),
                    backgroundColor: success ? AppColors.sageGreen : AppColors.danger,
                  ),
                );
              }
            },
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = context.watch<AuthController>();
    final blogCtrl = context.watch<BlogController>();
    final currentUser = authCtrl.currentUser;
    final currentUsername = currentUser?.username;

    final filteredPosts = blogCtrl.filteredPosts;
    final userPostCount = currentUsername != null
        ? blogCtrl.getUserPosts(currentUsername).length
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.paleLime,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.park_rounded,
                color: AppColors.primaryTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text('EcoBlog'),
          ],
        ),
        actions: [
          // Botón "Mis Publicaciones"
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.paleLime.withValues(alpha: 0.7),
              foregroundColor: AppColors.primaryTeal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.softOlive, width: 1),
              ),
            ),
            icon: const Icon(Icons.bookmark_border_rounded, size: 18),
            label: Text(
              'Mis Posts ($userPostCount)',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MyPostsView()));
            },
          ),
          const SizedBox(width: 6),

          // Botón Salir / Logout
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 20),
            tooltip: 'Cerrar sesión',
            onPressed: _confirmLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Barra de bienvenida y Filtro por Título
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hola, @${currentUsername ?? "invitado"}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onLongPress: kIsWeb ? null : () => _showMongoConfigDialog(context, blogCtrl),
                        onTap: () async {
                          if (kIsWeb) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'En navegadores web no se admiten sockets TCP directos a MongoDB. Para probar la base de datos en vivo ejecuta en Linux Desktop: flutter run -d linux',
                                ),
                                backgroundColor: AppColors.primaryTeal,
                                duration: Duration(seconds: 4),
                              ),
                            );
                            return;
                          }
                          if (!blogCtrl.mongoService.isConnected) {
                            _showMongoConfigDialog(context, blogCtrl);
                            return;
                          }
                          final success = await blogCtrl.initializeMongo();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Conectado a MongoDB en ${blogCtrl.mongoService.currentHost}:27017'
                                      : 'No se pudo conectar a MongoDB: ${blogCtrl.mongoService.lastError ?? "Revisa que docker compose esté activo."}',
                                ),
                                backgroundColor: success
                                    ? AppColors.sageGreen
                                    : AppColors.danger,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: blogCtrl.mongoService.isConnected
                                ? Colors.green.shade50
                                : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: blogCtrl.mongoService.isConnected
                                  ? Colors.green.shade300
                                  : Colors.amber.shade400,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 8,
                                color: blogCtrl.mongoService.isConnected
                                    ? Colors.green.shade700
                                    : Colors.amber.shade800,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                blogCtrl.mongoService.isConnected
                                    ? 'MongoDB: Conectado'
                                    : (kIsWeb
                                        ? 'Web: Modo Local'
                                        : 'MongoDB: Offline (Reintentar)'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: blogCtrl.mongoService.isConnected
                                      ? Colors.green.shade900
                                      : Colors.amber.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Filtro por publicación por título
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      blogCtrl.setSearchQuery(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar por título',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.sageGreen,
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: AppColors.textLight,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                blogCtrl.clearSearchQuery();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.borderLight),
            // Feed de publicaciones
            Expanded(
              child: filteredPosts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 54,
                              color: AppColors.sageGreen,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              blogCtrl.searchQuery.isNotEmpty
                                  ? 'No hay publicaciones con el título "${blogCtrl.searchQuery}"'
                                  : 'No hay publicaciones disponibles.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Intenta con otro término o crea una nueva publicación sobre el medio ambiente.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                            if (blogCtrl.searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              OutlinedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  blogCtrl.clearSearchQuery();
                                },
                                child: const Text('Limpiar filtro'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 80),
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        final post = filteredPosts[index];
                        final isOwner =
                            currentUsername != null &&
                            post.creatorUsername.toLowerCase() ==
                                currentUsername.toLowerCase();

                        return PostCard(
                          post: post,
                          isOwner: isOwner,
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditPostView(post: post),
                              ),
                            );
                          },
                          onDelete: () async {
                            await blogCtrl.deletePost(post.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Publicación eliminada correctamente.',
                                  ),
                                  backgroundColor: AppColors.danger,
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      // Botón para crear una publicación (FloatingActionButton)
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryTeal,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreatePostView()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
