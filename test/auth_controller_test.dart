import 'package:flutter_test/flutter_test.dart';
import 'package:blog_nosql/controllers/auth_controller.dart';
import 'package:blog_nosql/services/password_service.dart';

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

    test('Register and login succeeds', () async {
      final id = DateTime.now().microsecondsSinceEpoch;
      final uname = 'test_$id';
      final email = 'test_$id@planetaverde.org';

      final regSuccess = await authController.register(
        email: email,
        username: uname,
        password: 'password123',
        termsAccepted: true,
      );
      expect(regSuccess, true);
      // Validar que la contraseña guardada en el usuario NO es texto plano
      expect(authController.currentUser?.password, isNot(equals('password123')));
      expect(PasswordService.isBcryptHash(authController.currentUser!.password), isTrue);

      authController.logout();
      expect(authController.isAuthenticated, false);

      final loginSuccess = await authController.login(uname, 'password123');
      expect(loginSuccess, true);
      expect(authController.isAuthenticated, true);
      expect(authController.currentUser?.username, uname);
      expect(authController.errorMessage, isNull);
    });

    test('Register stores password hashed with BCrypt and not in plain text', () async {
      final id = DateTime.now().microsecondsSinceEpoch;
      final uname = 'hash_user_$id';
      final email = 'hash_user_$id@planetaverde.org';
      const rawPassword = 'MiPasswordSeguro2026!';

      final regSuccess = await authController.register(
        email: email,
        username: uname,
        password: rawPassword,
        termsAccepted: true,
      );
      expect(regSuccess, true);

      final registeredUser = authController.currentUser;
      expect(registeredUser, isNotNull);
      expect(registeredUser!.password, isNot(equals(rawPassword)));
      expect(PasswordService.isBcryptHash(registeredUser.password), isTrue);

      authController.logout();

      final loginSuccess = await authController.login(uname, rawPassword);
      expect(loginSuccess, true);
      expect(authController.isAuthenticated, true);
    });

    test('Login with wrong password fails', () async {
      final id = DateTime.now().microsecondsSinceEpoch;
      final uname = 'test2_$id';
      final email = 'test2_$id@planetaverde.org';

      await authController.register(
        email: email,
        username: uname,
        password: 'password123',
        termsAccepted: true,
      );
      authController.logout();

      final success = await authController.login(uname, 'wrong_pass');
      expect(success, false);
      expect(authController.isAuthenticated, false);
      expect(authController.errorMessage, isNotNull);
    });

    test('Register fails if terms and conditions are not accepted', () async {
      final id = DateTime.now().microsecondsSinceEpoch;
      final success = await authController.register(
        email: 'nuevo_$id@ecovida.org',
        username: 'nuevo_$id',
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

    test('Register succeeds when terms are accepted and inputs are valid', () async {
      final id = DateTime.now().microsecondsSinceEpoch;
      final uname = 'nuevo_$id';
      final email = 'nuevo_$id@ecovida.org';

      final success = await authController.register(
        email: email,
        username: uname,
        password: 'password123',
        termsAccepted: true,
      );
      expect(success, true);
      expect(authController.isAuthenticated, true);
      expect(authController.currentUser?.username, uname);
      expect(authController.currentUser?.email, email);
    });

    test('Logout clears currentUser', () async {
      final id = DateTime.now().microsecondsSinceEpoch;
      final uname = 'logout_$id';
      final email = 'logout_$id@ecovida.org';

      await authController.register(
        email: email,
        username: uname,
        password: 'password123',
        termsAccepted: true,
      );
      expect(authController.isAuthenticated, true);

      authController.logout();
      expect(authController.isAuthenticated, false);
      expect(authController.currentUser, isNull);
    });
  });
}
