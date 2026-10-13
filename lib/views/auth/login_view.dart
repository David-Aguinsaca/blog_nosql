import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/app_theme.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authCtrl = context.read<AuthController>();
    final success = authCtrl.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );
    setState(() => _isLoading = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authCtrl.errorMessage ?? 'Error al iniciar sesión.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _fillDemoUser(String user, String pass) {
    setState(() {
      _usernameController.text = user;
      _passwordController.text = pass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo e Isotipo Ecológico
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.paleLime,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.softOlive,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.park_rounded,
                        color: AppColors.primaryTeal,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Títulos
                  const Text(
                    'EcoBlog',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryTeal,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Voces por el medio ambiente y la sostenibilidad',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 36),

                  // Campo Usuario
                  const Text(
                    'Usuario',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _usernameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa tu usuario (ej. david)',
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.sageGreen,
                        size: 20,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Por favor ingresa tu usuario.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Campo Clave
                  const Text(
                    'Clave',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submitLogin(),
                    decoration: InputDecoration(
                      hintText: 'Ingresa tu contraseña',
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.sageGreen,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Por favor ingresa tu clave.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Botón Iniciar Sesión
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Iniciar Sesión'),
                  ),

                  const SizedBox(height: 24),

                  // Acceso rápido de prueba para prototipo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.paleLime.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.softOlive,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Credenciales Demo para prueba rápida:',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryTeal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                              ),
                              onPressed: () => _fillDemoUser('david', '123456'),
                              child: const Text(
                                'Usuario: david',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                              ),
                              onPressed: () =>
                                  _fillDemoUser('elena_bio', '123456'),
                              child: const Text(
                                'Usuario: elena_bio',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Enlace a Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '¿Aún no tienes cuenta? ',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 13.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterView(),
                            ),
                          );
                        },
                        child: const Text(
                          'Regístrate aquí',
                          style: TextStyle(
                            color: AppColors.primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
