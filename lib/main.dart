import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/blog_controller.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EcoBlogApp());
}

class EcoBlogApp extends StatelessWidget {
  const EcoBlogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => BlogController()),
      ],
      child: Consumer<AuthController>(
        builder: (context, authCtrl, _) {
          return MaterialApp(
            title: 'EcoBlog - Medio Ambiente',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: authCtrl.isAuthenticated
                ? const HomeView()
                : const LoginView(),
          );
        },
      ),
    );
  }
}
