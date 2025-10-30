// server/lib/routes/admin_users_routes.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:bcrypt/bcrypt.dart';
import '../database/db.dart';

Router getAdminUsersRoutes() {
  final router = Router();

  // Crear usuario barbero (rol_id = 2)
  router.post('/usuarios/barbero', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString());
      final nombre = body['nombre'] as String?;
      final email = body['email'] as String?;
      final telefono = body['telefono'] as String?;
      final contrasena = body['contrasena'] as String?;

      if (nombre == null || email == null || contrasena == null) {
        return Response(400, body: 'Faltan campos obligatorios');
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
        VALUES (\$1, \$2, \$3, \$4, 2)
        RETURNING id, nombre_completo, email, telefono, rol_id, activo, fecha_registro
        ''',
        parameters: [nombre, email, telefono ?? '', hash],
      );

      final row = result.first.toColumnMap();

      // Convertir DateTime a String
      final safeRow = row.map((key, value) {
        if (value is DateTime) {
          return MapEntry(key, value.toIso8601String());
        }
        return MapEntry(key, value);
      });

      return Response.ok(jsonEncode(safeRow),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('❌ Error creando barbero: $e\n$st');
      return Response.internalServerError(body: 'Error interno');
    }
  });

  // Crear usuario administrador (rol_id = 3)
  router.post('/usuarios/admin', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString());
      final nombre = body['nombre'] as String?;
      final email = body['email'] as String?;
      final telefono = body['telefono'] as String?;
      final contrasena = body['contrasena'] as String?;

      if (nombre == null || email == null || contrasena == null) {
        return Response(400, body: 'Faltan campos obligatorios');
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
        VALUES (\$1, \$2, \$3, \$4, 3)
        RETURNING id, nombre_completo, email, telefono, rol_id, activo, fecha_registro
        ''',
        parameters: [nombre, email, telefono ?? '', hash],
      );

      final row = result.first.toColumnMap();

      // Convertir DateTime a String
      final safeRow = row.map((key, value) {
        if (value is DateTime) {
          return MapEntry(key, value.toIso8601String());
        }
        return MapEntry(key, value);
      });

      return Response.ok(jsonEncode(safeRow),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('❌ Error creando admin: $e\n$st');
      return Response.internalServerError(body: 'Error interno');
    }
  });

  // server/lib/routes/admin_citas_routes.dart

// Completar una cita confirmada (solo admin)
router.put('/citas/<id>/completar', (Request req, String id) async {
  try {
    // 1. Actualizar estado de la cita
    final result = await db.execute(
      '''
      UPDATE citas
      SET estado = 'completada'
      WHERE id = \$1 AND estado = 'confirmada'
      RETURNING id, cliente_id, barbero_id, servicio_id, fecha, hora, estado, creado_en
      ''',
      parameters: [int.parse(id)],
    );

    if (result.isEmpty) {
      return Response(404, body: 'Cita no encontrada o no está en estado confirmada');
    }

    final row = result.first.toColumnMap();
    final response = {
      'message': 'Cita marcada como completada por administrador',
      ...row,
      'fecha': row['fecha']?.toString(),
      'hora': row['hora']?.toString(),
      'creado_en': row['creado_en']?.toString(),
    };

    return Response.ok(
      jsonEncode(response),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (e, st) {
    print('❌ Error completando cita manualmente: $e\n$st');
    return Response.internalServerError(body: 'Error interno al completar cita');
  }
});

  return router;
}

final adminUsersRoutes = getAdminUsersRoutes();
