import 'package:flutter_test/flutter_test.dart';
import 'package:blog_nosql/controllers/auth_controller.dart';

void main() {
  group('AuthController Tests', () {
    late AuthController authController;

    setUp(() {
      authController = AuthController();
    });

    test('Initial state is unauthenticated', () {
      expect(authController.isAuthenticated, false);
      expect(authController.currentUser, isNull);
    });

    test('Login with seed user david succeeds', () {
      final success = authController.login('david', '123456');
      expect(success, true);
      expect(authController.isAuthenticated, true);
      expect(authController.currentUser?.username, 'david');
      expect(authController.errorMessage, isNull);
    });

    test('Login with wrong password fails', () {
      final success = authController.login('david', 'wrong_pass');
      expect(success, false);
      expect(authController.isAuthenticated, false);
      expect(authController.errorMessage, isNotNull);
    });

    test('Register fails if terms and conditions are not accepted', () {
      final success = authController.register(
        email: 'nuevo@ecovida.org',
        username: 'nuevo_usuario',
        password: 'password123',
        termsAccepted: false,
      );
      expect(success, false);
      expect(authController.isAuthenticated, false);
      expect(
        authController.errorMessage,
        contains('Debes aceptar los términos y condiciones'),
      );
    });

    test('Register succeeds when terms are accepted and inputs are valid', () {
      final success = authController.register(
        email: 'nuevo@ecovida.org',
        username: 'nuevo_usuario',
        password: 'password123',
        termsAccepted: true,
      );
      expect(success, true);
      expect(authController.isAuthenticated, true);
      expect(authController.currentUser?.username, 'nuevo_usuario');
      expect(authController.currentUser?.email, 'nuevo@ecovida.org');
    });

    test('Logout clears currentUser', () {
      authController.login('david', '123456');
      expect(authController.isAuthenticated, true);

      authController.logout();
      expect(authController.isAuthenticated, false);
      expect(authController.currentUser, isNull);
    });
  });
}
