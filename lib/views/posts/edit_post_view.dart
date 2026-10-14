import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/blog_controller.dart';
import '../../models/blog_post_model.dart';
import '../../theme/app_theme.dart';

class EditPostView extends StatefulWidget {
  final BlogPostModel post;

  const EditPostView({super.key, required this.post});

  @override
  State<EditPostView> createState() => _EditPostViewState();
}

class _EditPostViewState extends State<EditPostView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _topicController;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController(text: widget.post.topic);
    _titleController = TextEditingController(text: widget.post.title);
    _contentController = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _topicController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitEdit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final success = await context.read<BlogController>().updatePost(
          postId: widget.post.id,
          topic: _topicController.text.trim(),
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        );
    if (mounted) setState(() => _isSubmitting = false);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publicación actualizada correctamente.'),
          backgroundColor: AppColors.sageGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Editar Publicación'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tema
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
                  maxLength: 15,
                  decoration: const InputDecoration(
                    hintText: 'Tema (ej. Reciclaje, Energía Solar)',
                    prefixIcon: Icon(
                      Icons.spa_rounded,
                      color: AppColors.sageGreen,
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'El tema no puede estar vacío.';
                    }
                    if (val.trim().length < 3) {
                      return 'El tema debe tener al menos 3 caracteres.';
                    }
                    if (val.trim().length > 15) {
                      return 'El tema no puede tener más de 15 caracteres.';
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
                  decoration: const InputDecoration(
                    hintText: 'Título de la publicación',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'El título no puede estar vacío.';
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
                  decoration: const InputDecoration(
                    hintText: 'Contenido...',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'El contenido no puede estar vacío.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Botón Guardar
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitEdit,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded, size: 18),
                  label: const Text('Guardar Cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
