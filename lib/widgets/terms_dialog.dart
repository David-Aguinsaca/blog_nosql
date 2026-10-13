import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TermsDialog extends StatelessWidget {
  const TermsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.paleLime,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: AppColors.primaryTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Términos y Condiciones',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryTeal,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Comunidad Verde y Sostenible',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                fontSize: 15,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. Compromiso ambiental: Las publicaciones y comentarios deben fomentar la conciencia ecológica, el respeto a la biodiversidad y soluciones sustentables.\n\n'
              '2. Respeto mutuo: Queda prohibido cualquier lenguaje ofensivo, desinformación o contenido comercial no relacionado con la ecología.\n\n'
              '3. Veracidad: Comparte información y prácticas basadas en hechos o experiencias constructivas comprobables.\n\n'
              '4. Privacidad y autoría: Tu información de perfil es utilizada únicamente para identificarte dentro de la plataforma del blog.',
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textMuted,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Entendido y Aceptar'),
        ),
      ],
    );
  }
}
