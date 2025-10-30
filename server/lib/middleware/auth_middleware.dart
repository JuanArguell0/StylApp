// server/lib/middleware/auth_middleware.dart
import 'package:shelf/shelf.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import '../utils/jwt_utils.dart';

/// Middleware que valida que exista un token JWT válido en la cabecera Authorization.
/// Si es válido, añade un objeto normalizado con id, email y rolId al contexto de la request.
Middleware checkAuth() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Manejo de preflight CORS
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        });
      }

      final authHeader = request.headers['Authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden('Token requerido');
      }

      try {
        final token = authHeader.substring(7);
        final jwt = JWT.verify(token, SecretKey(jwtSecret));
        final payload = jwt.payload as Map<String, dynamic>;

        // Normalizamos el payload para que siempre tenga las mismas claves
        final normalizedUser = {
          'id': payload['id'] ?? payload['userId'],
          'email': payload['email'],
          'rolId': payload['rolId'],
        };

        return innerHandler(request.change(context: {'user': normalizedUser}));
      } catch (e) {
        final msg = e.toString();
        if (msg.contains('expired')) {
          return Response.forbidden('Token expirado');
        }
        return Response.forbidden('Token inválido');
      }
    };
  };
}

/// Middleware que autoriza solo a ciertos roles.
/// Ejemplo: authorizeRoles([3]) → solo admin.
Middleware authorizeRoles(List<int> allowedRoles) {
  return (Handler innerHandler) {
    return (Request request) async {
      final user = request.context['user'] as Map<String, dynamic>?;
      if (user == null) {
        return Response.forbidden('No autenticado');
      }

      final rolId = user['rolId'] as int?;
      if (rolId == null || !allowedRoles.contains(rolId)) {
        return Response.forbidden('No autorizado');
      }

      return innerHandler(request);
    };
  };
}
