import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/blog_controller.dart';
import '../../theme/app_theme.dart';

class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  State<CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<CreatePostView> {
  final _formKey = GlobalKey<FormState>();
  final _topicController = TextEditingController();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _topicController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final authCtrl = context.read<AuthController>();
    final currentUser = authCtrl.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para publicar.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await context.read<BlogController>().addPost(
      creatorUsername: currentUser.username,
      topic: _topicController.text.trim(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Publicación compartida con éxito!'),
        backgroundColor: AppColors.sageGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthController>().currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Crear Publicación'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info de autor
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.paleLime.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.softOlive, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_pin_rounded,
                        color: AppColors.primaryTeal,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Publicando como @${currentUser?.username ?? "anónimo"}',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Tema Ecológico
                const Text(
                  'Tema Ecológico',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _topicController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText:
                        'Ingresa el tema (ej. Reforestación, Cero Residuos...)',
                    prefixIcon: Icon(
                      Icons.spa_rounded,
                      color: AppColors.sageGreen,
                      size: 20,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor ingresa un tema ecológico.';
                    }
                    if (val.trim().length < 3) {
                      return 'El tema debe tener al menos 3 caracteres.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Título
                const Text(
                  'Título de la Publicación',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Un título claro y de impacto ambiental...',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor ingresa un título.';
                    }
                    if (val.trim().length < 5) {
                      return 'El título debe tener al menos 5 caracteres.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Contenido
                const Text(
                  'Contenido',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  maxLines: 8,
                  minLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText:
                        'Comparte tu idea, reflexión o solución ecológica detallada...',
                    alignLabelWithHint: true,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'El contenido de la publicación no puede estar vacío.';
                    }
                    if (val.trim().length < 15) {
                      return 'Por favor escribe al menos 15 caracteres.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Botón Publicar
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitPost,
                  iconAlignment: IconAlignment.end,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : null,
                  label: const Text('Publicar en EcoBlog'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
