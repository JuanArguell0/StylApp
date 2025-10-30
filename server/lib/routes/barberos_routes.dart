// server/lib/routes/barberos_routes.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/db.dart';

Router getBarberosRoutes() {
  final router = Router();

  // Crear barbero (solo admin)
  router.post('/barberos', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString());
      final usuarioId = body['usuario_id'] as int?;
      final especialidades = body['especialidades'] as String? ?? '';
      final horarioInicio = body['horario_inicio'] as String?;
      final horarioFin = body['horario_fin'] as String?;
      final diasDisponibles = body['dias_disponibles'] as String? ?? '';

      if (usuarioId == null || horarioInicio == null || horarioFin == null) {
        return Response(400,
            body: 'usuario_id, horario_inicio y horario_fin son obligatorios');
      }

      final result = await db.execute(
        '''
        INSERT INTO barberos (usuario_id, especialidades, horario_inicio, horario_fin, dias_disponibles)
        VALUES (\$1, \$2, \$3::time, \$4::time, \$5)
        RETURNING id, usuario_id, especialidades, horario_inicio, horario_fin, dias_disponibles
        ''',
        parameters: [usuarioId, especialidades, horarioInicio, horarioFin, diasDisponibles],
      );

      final row = result.first.toColumnMap();
      final response = {
        ...row,
        'horario_inicio': row['horario_inicio']?.toString(),
        'horario_fin': row['horario_fin']?.toString(),
      };

      return Response.ok(jsonEncode(response),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('❌ Error creando barbero: $e\n$st');
      return Response.internalServerError(body: 'Error interno');
    }
  });

  // Editar barbero (solo admin)
  router.put('/barberos/<id>', (Request req, String id) async {
    try {
      final body = jsonDecode(await req.readAsString());
      final especialidades = body['especialidades'] as String?;
      final horarioInicio = body['horario_inicio'] as String?;
      final horarioFin = body['horario_fin'] as String?;
      final diasDisponibles = body['dias_disponibles'] as String?;

      final result = await db.execute(
        '''
        UPDATE barberos
        SET especialidades = COALESCE(\$1, especialidades),
            horario_inicio = COALESCE(\$2::time, horario_inicio),
            horario_fin = COALESCE(\$3::time, horario_fin),
            dias_disponibles = COALESCE(\$4, dias_disponibles)
        WHERE id = \$5
        RETURNING id, usuario_id, especialidades, horario_inicio, horario_fin, dias_disponibles
        ''',
        parameters: [especialidades, horarioInicio, horarioFin, diasDisponibles, int.parse(id)],
      );

      if (result.isEmpty) return Response(404, body: 'Barbero no encontrado');

      final row = result.first.toColumnMap();
      final response = {
        ...row,
        'horario_inicio': row['horario_inicio']?.toString(),
        'horario_fin': row['horario_fin']?.toString(),
      };

      return Response.ok(jsonEncode(response),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('❌ Error editando barbero: $e\n$st');
      return Response.internalServerError(body: 'Error interno');
    }
  });

  // Listar barberos (público)
  router.get('/barberos', (Request req) async {
    try {
      final result = await db.execute(
        '''
        SELECT b.id, b.usuario_id, u.nombre_completo, u.email, b.especialidades,
               b.horario_inicio, b.horario_fin, b.dias_disponibles
        FROM barberos b
        JOIN usuarios u ON u.id = b.usuario_id
        ''',
      );

      final list = result.map((r) {
        final row = r.toColumnMap();
        return {
          ...row,
          'horario_inicio': row['horario_inicio']?.toString(),
          'horario_fin': row['horario_fin']?.toString(),
        };
      }).toList();

      return Response.ok(jsonEncode(list),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('❌ Error listando barberos: $e\n$st');
      return Response.internalServerError(body: 'Error interno');
    }
  });

  return router;
}

final barberosRoutes = getBarberosRoutes();
