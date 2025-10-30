// server/lib/routes/auth_routes.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:bcrypt/bcrypt.dart';
import '../database/db.dart';
import '../utils/jwt_utils.dart';

Router getAuthRoutes() {
  final router = Router();

  router.post('/api/register', _registerHandler);
  router.post('/api/login', _loginHandler);

  return router;
}

Future<Response> _registerHandler(Request request) async {
  try {
    final bodyString = await request.readAsString();
    final body = jsonDecode(bodyString) as Map<String, dynamic>;
    final nombre = body['nombre'] as String?;
    final email = body['email'] as String?;
    final telefono = body['telefono'] as String?;
    final contrasena = body['contrasena'] as String?;
    final rolId = (body['rol_id'] as int?) ?? 1; // cliente por defecto

    if (nombre == null || email == null || contrasena == null) {
      return Response(400, body: 'Faltan campos obligatorios');
    }

    // 🚫 Solo clientes desde aquí
    if (rolId != 1) {
      return Response.forbidden(
          'Solo se pueden registrar clientes desde este endpoint');
    }

    final existing = await db.execute(
      'SELECT id FROM usuarios WHERE email = \$1',
      parameters: [email],
    );
    if (existing.isNotEmpty) {
      return Response(409, body: 'El correo ya está registrado');
    }

    final hash = BCrypt.hashpw(contrasena, BCrypt.gensalt());

    final result = await db.execute(
      '''
      INSERT INTO usuarios (nombre_completo, email, telefono, contrasena_hash, rol_id)
      VALUES (\$1, \$2, \$3, \$4, 1)
      RETURNING id, nombre_completo, email, telefono, rol_id, activo, fecha_registro
      ''',
      parameters: [nombre, email, telefono ?? '', hash],
    );

    final row = result.first.toColumnMap();
    final token = generateJwt(
      row['id'] as int,
      row['email'] as String,
      row['rol_id'] as int,
    );

    final safeUser = {
      'id': row['id'],
      'nombre_completo': row['nombre_completo'],
      'email': row['email'],
      'telefono': row['telefono'],
      'rol_id': row['rol_id'],
      'activo': row['activo'],
      'fecha_registro': (row['fecha_registro'] as DateTime?)?.toIso8601String(),
    };

    return Response.ok(
      jsonEncode({
        'message': 'Usuario registrado exitosamente',
        'token': token,
        'user': safeUser,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e, st) {
    print('❌ Error en registro: $e\n$st');
    return Response.internalServerError(body: 'Error interno del servidor');
  }
}

Future<Response> _loginHandler(Request request) async {
  try {
    final bodyString = await request.readAsString();
    final body = jsonDecode(bodyString) as Map<String, dynamic>;
    final email = body['email'] as String?;
    final contrasena = body['contrasena'] as String?;

    if (email == null || contrasena == null) {
      return Response(400, body: 'Email y contraseña requeridos');
    }

    final rows = await db.execute(
      '''
      SELECT id, nombre_completo, email, telefono, rol_id, contrasena_hash, activo, fecha_registro
      FROM usuarios
      WHERE email = \$1 AND activo = true
      ''',
      parameters: [email],
    );

    if (rows.isEmpty) {
      return Response(401, body: 'Credenciales inválidas');
    }

    final user = rows.first.toColumnMap();
    final storedHash = user['contrasena_hash'] as String;

    final valid = BCrypt.checkpw(contrasena, storedHash);
    if (!valid) {
      return Response(401, body: 'Credenciales inválidas');
    }

    final token = generateJwt(
      user['id'] as int,
      user['email'] as String,
      user['rol_id'] as int,
    );

    final safeUser = {
      'id': user['id'],
      'nombre_completo': user['nombre_completo'],
      'email': user['email'],
      'telefono': user['telefono'],
      'rol_id': user['rol_id'],
      'activo': user['activo'],
      'fecha_registro': (user['fecha_registro'] as DateTime?)?.toIso8601String(),
    };

    return Response.ok(
      jsonEncode({
        'message': 'Inicio de sesión exitoso',
        'token': token,
        'user': safeUser,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e, st) {
    print('❌ Error en login: $e\n$st');
    return Response.internalServerError(body: 'Error interno del servidor');
  }
}

final authRoutes = getAuthRoutes();
