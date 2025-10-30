// server/lib/utils/jwt_utils.dart
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dotenv/dotenv.dart';

final _env = DotEnv()..load();

String get jwtSecret => _env['JWT_SECRET'] ?? 'fallback_inseguro';

String generateJwt(int userId, String email, int rolId) {
  final jwt = JWT({
    'userId': userId,
    'email': email,
    'rolId': rolId,
  });

  // Expiración limpia usando expiresIn
  return jwt.sign(SecretKey(jwtSecret), expiresIn: const Duration(hours: 24));
}
