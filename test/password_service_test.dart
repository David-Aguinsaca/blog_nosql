import 'package:flutter_test/flutter_test.dart';
import 'package:blog_nosql/services/password_service.dart';

void main() {
  group('PasswordService Tests', () {
    const plainPassword = 'EcoPassword2026!';

    test('hashPassword generates valid BCrypt hash different from plaintext', () {
      final hash = PasswordService.hashPassword(plainPassword);

      expect(hash, isNot(equals(plainPassword)));
      expect(hash.length, greaterThanOrEqualTo(59));
      expect(PasswordService.isBcryptHash(hash), isTrue);
    });

    test('hashPassword produces unique salts for the same password', () {
      final hash1 = PasswordService.hashPassword(plainPassword);
      final hash2 = PasswordService.hashPassword(plainPassword);

      // Los hashes deben ser distintos debido al salt criptográfico aleatorio
      expect(hash1, isNot(equals(hash2)));

      // Ambos deben validar correctamente contra la misma clave
      expect(PasswordService.verifyPassword(plainPassword, hash1), isTrue);
      expect(PasswordService.verifyPassword(plainPassword, hash2), isTrue);
    });

    test('verifyPassword validates correct password against BCrypt hash', () {
      final hash = PasswordService.hashPassword(plainPassword);

      expect(PasswordService.verifyPassword(plainPassword, hash), isTrue);
      expect(PasswordService.verifyPassword('WrongPassword', hash), isFalse);
    });

    test('verifyPassword supports legacy plain-text passwords (retrocompatibilidad)', () {
      const legacyPassword = 'password123';

      expect(PasswordService.verifyPassword(legacyPassword, legacyPassword), isTrue);
      expect(PasswordService.verifyPassword('otra_clave', legacyPassword), isFalse);
    });

    test('verifyPassword handles empty strings and malformed hashes safely', () {
      expect(PasswordService.verifyPassword('', 'someHash'), isFalse);
      expect(PasswordService.verifyPassword('password', ''), isFalse);
      expect(PasswordService.verifyPassword('password', r'$2a$invalid_hash'), isFalse);
    });

    test('hashPassword throws ArgumentError on empty or blank input', () {
      expect(() => PasswordService.hashPassword(''), throwsArgumentError);
      expect(() => PasswordService.hashPassword('   '), throwsArgumentError);
    });
  });
}
