import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/mongo_service.dart';
import '../services/password_service.dart';

class AuthController extends ChangeNotifier {
  final MongoService _mongoService = MongoService();
  UserModel? _currentUser;
  final List<UserModel> _users = [];

  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _errorMessage = null;
    final trimmedUser = username.trim();
    final trimmedPass = password.trim();

    if (!_mongoService.isConnected) {
      await _mongoService.connect();
    }

    if (trimmedUser.isEmpty || trimmedPass.isEmpty) {
      _errorMessage = 'Por favor ingresa usuario y contraseña.';
      notifyListeners();
      return false;
    }

    // Si MongoDB está conectado, buscar en la colección de usuarios
    if (_mongoService.isConnected) {
      final dbUser = await _mongoService.findUserByUsername(trimmedUser);
      if (dbUser != null) {
        if (PasswordService.verifyPassword(trimmedPass, dbUser.password)) {
          // Migración progresiva: si la clave era texto plano antiguo, actualizar a hash BCrypt
          if (!PasswordService.isBcryptHash(dbUser.password)) {
            final newHash = PasswordService.hashPassword(trimmedPass);
            await _mongoService.updateUserPassword(dbUser.id, newHash);
            _currentUser = dbUser.copyWith(password: newHash);
          } else {
            _currentUser = dbUser;
          }
          _errorMessage = null;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Credenciales incorrectas. Verifica tu usuario y clave.';
          notifyListeners();
          return false;
        }
      }
    }

    // Respaldo en memoria / offline
    final matchIndex = _users.indexWhere(
      (u) =>
          u.username.toLowerCase() == trimmedUser.toLowerCase() &&
          PasswordService.verifyPassword(trimmedPass, u.password),
    );

    if (matchIndex != -1) {
      var matchedUser = _users[matchIndex];
      // Si la clave en memoria era texto plano, actualizar a hash BCrypt
      if (!PasswordService.isBcryptHash(matchedUser.password)) {
        final newHash = PasswordService.hashPassword(trimmedPass);
        matchedUser = matchedUser.copyWith(password: newHash);
        _users[matchIndex] = matchedUser;
      }
      _currentUser = matchedUser;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Credenciales incorrectas. Verifica tu usuario y clave.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String username,
    required String password,
    required bool termsAccepted,
  }) async {
    _errorMessage = null;
    final trimmedEmail = email.trim();
    final trimmedUser = username.trim();
    final trimmedPass = password.trim();

    if (!_mongoService.isConnected) {
      await _mongoService.connect();
    }

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

    // Verificar en MongoDB si está conectado
    if (_mongoService.isConnected) {
      final existingUser = await _mongoService.findUserByUsername(trimmedUser);
      if (existingUser != null) {
        _errorMessage = 'El usuario o correo electrónico ya se encuentra registrado.';
        notifyListeners();
        return false;
      }
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

    final hashedPassword = PasswordService.hashPassword(trimmedPass);

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      username: trimmedUser,
      email: trimmedEmail,
      password: hashedPassword,
    );

    if (_mongoService.isConnected) {
      await _mongoService.createUser(newUser);
    }

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
