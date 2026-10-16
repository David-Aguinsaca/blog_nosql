import 'package:bcrypt/bcrypt.dart';

/// Servicio responsable del hashing seguro y verificación de contraseñas
/// utilizando el algoritmo estándar BCrypt con salting automático.
class PasswordService {
  /// Costo computacional por defecto (10 rounds = 1024 iteraciones de clave).
  static const int _defaultLogRounds = 10;

  /// Genera un hash seguro para una contraseña en texto plano.
  /// Lanza [ArgumentError] si la contraseña está vacía.
  static String hashPassword(String plainPassword) {
    final trimmed = plainPassword.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('La contraseña no puede estar vacía.');
    }
    final salt = BCrypt.gensalt(logRounds: _defaultLogRounds);
    return BCrypt.hashpw(trimmed, salt);
  }

  /// Verifica si una contraseña ingresada coincide con el hash o valor almacenado.
  /// 
  /// - Si [storedHash] tiene formato BCrypt (`$2a$`, `$2b$`, `$2y$`, etc.),
  ///   se valida mediante [BCrypt.checkpw].
  /// - Si [storedHash] es texto plano (usuarios legados o seeders de prueba),
  ///   aplica un fallback de comparación directa para garantizar retrocompatibilidad.
  static bool verifyPassword(String plainPassword, String storedHash) {
    final trimmedPlain = plainPassword.trim();
    final trimmedStored = storedHash.trim();

    if (trimmedPlain.isEmpty || trimmedStored.isEmpty) {
      return false;
    }

    if (isBcryptHash(trimmedStored)) {
      try {
        return BCrypt.checkpw(trimmedPlain, trimmedStored);
      } catch (_) {
        return false;
      }
    }

    // Fallback de retrocompatibilidad para contraseñas sin hashear
    return trimmedPlain == trimmedStored;
  }

  /// Determina si una cadena dada cumple con el formato estándar de hash BCrypt.
  static bool isBcryptHash(String value) {
    final trimmed = value.trim();
    return trimmed.startsWith(r'$2a$') ||
        trimmed.startsWith(r'$2b$') ||
        trimmed.startsWith(r'$2y$') ||
        trimmed.startsWith(r'$2$');
  }
}
