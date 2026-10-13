import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  UserModel? _currentUser;
  final List<UserModel> _users = [
    UserModel(
      id: 'user_1',
      username: 'david',
      email: 'david@planetaverde.org',
      password: '123456',
    ),
    UserModel(
      id: 'user_2',
      username: 'elena_bio',
      email: 'elena@ecovida.org',
      password: '123456',
    ),
  ];

  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  bool login(String username, String password) {
    _errorMessage = null;
    final trimmedUser = username.trim();
    final trimmedPass = password.trim();

    if (trimmedUser.isEmpty || trimmedPass.isEmpty) {
      _errorMessage = 'Por favor ingresa usuario y contraseña.';
      notifyListeners();
      return false;
    }

    final matchIndex = _users.indexWhere(
      (u) =>
          u.username.toLowerCase() == trimmedUser.toLowerCase() &&
          u.password == trimmedPass,
    );

    if (matchIndex != -1) {
      _currentUser = _users[matchIndex];
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Credenciales incorrectas. Verifica tu usuario y clave.';
      notifyListeners();
      return false;
    }
  }

  bool register({
    required String email,
    required String username,
    required String password,
    required bool termsAccepted,
  }) {
    _errorMessage = null;
    final trimmedEmail = email.trim();
    final trimmedUser = username.trim();
    final trimmedPass = password.trim();

    if (trimmedEmail.isEmpty || trimmedUser.isEmpty || trimmedPass.isEmpty) {
      _errorMessage = 'Todos los campos son obligatorios.';
      notifyListeners();
      return false;
    }

    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      _errorMessage = 'Por favor ingresa un correo electrónico válido.';
      notifyListeners();
      return false;
    }

    if (trimmedUser.length < 3) {
      _errorMessage = 'El usuario debe tener al menos 3 caracteres.';
      notifyListeners();
      return false;
    }

    if (trimmedPass.length < 4) {
      _errorMessage = 'La contraseña debe tener al menos 4 caracteres.';
      notifyListeners();
      return false;
    }

    if (!termsAccepted) {
      _errorMessage = 'Debes aceptar los términos y condiciones para continuar.';
      notifyListeners();
      return false;
    }

    final exists = _users.any(
      (u) =>
          u.username.toLowerCase() == trimmedUser.toLowerCase() ||
          u.email.toLowerCase() == trimmedEmail.toLowerCase(),
    );

    if (exists) {
      _errorMessage = 'El usuario o correo electrónico ya se encuentra registrado.';
      notifyListeners();
      return false;
    }

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: trimmedUser,
      email: trimmedEmail,
      password: trimmedPass,
    );

    _users.add(newUser);
    _currentUser = newUser;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
