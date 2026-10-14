import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/blog_controller.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/mongo_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(
      'Archivo .env no encontrado o no cargado en assets, usando valores por defecto: $e',
    );
  }
  await MongoService().connect();
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
            title: 'TerraBlog - Medio Ambiente',
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
