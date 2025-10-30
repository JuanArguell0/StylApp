// server/lib/routes/valoraciones_routes.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/db.dart';

Router getValoracionesRoutes() {
  final router = Router();

  // Crear valoración (solo cliente autenticado y cita completada)
  router.post('/valoraciones', (Request req) async {
    try {
      final user = req.context['user'] as Map<String, dynamic>?;
      if (user == null || user['rolId'] != 1) {
        return Response.forbidden('Solo clientes pueden dejar valoraciones');
      }
      final clienteId = user['id'] as int;

      final body = jsonDecode(await req.readAsString());
      final citaId = body['cita_id'] as int?;
      final calificacion = body['calificacion'] as int?;
      final comentario = body['comentario'] as String?;

      if (citaId == null || calificacion == null) {
        return Response(400, body: 'cita_id y calificacion son obligatorios');
      }
      if (calificacion < 1 || calificacion > 5) {
        return Response(400, body: 'La calificación debe estar entre 1 y 5');
      }

      // 1. Verificar que la cita existe, pertenece al cliente y está completada
      final citaResult = await db.execute(
        '''
        SELECT c.barbero_id, c.estado
        FROM citas c
        WHERE c.id = \$1 AND c.cliente_id = \$2
        ''',
        parameters: [citaId, clienteId],
      );
      if (citaResult.isEmpty) {
        return Response(404, body: 'Cita no encontrada o no pertenece al cliente');
      }
      final cita = citaResult.first.toColumnMap();
      if (cita['estado'] != 'completada') {
        return Response(403, body: 'Solo se puede valorar citas con estado "completada"');
      }

      // 2. Evitar valoraciones duplicadas
      final existe = await db.execute(
        'SELECT 1 FROM valoraciones WHERE cita_id = \$1',
        parameters: [citaId],
      );
      if (existe.isNotEmpty) {
        return Response(409, body: 'Ya existe una valoración para esta cita');
      }

      // 3. Insertar valoración
      final barberoId = cita['barbero_id'] as int;
      final result = await db.execute(
        '''
        INSERT INTO valoraciones (cita_id, cliente_id, barbero_id, calificacion, comentario)
        VALUES (\$1, \$2, \$3, \$4, \$5)
        RETURNING id, cita_id, cliente_id, barbero_id, calificacion, comentario, fecha
        ''',
        parameters: [citaId, clienteId, barberoId, calificacion, comentario ?? ''],
      );

      final row = result.first.toColumnMap();
      final response = {
        ...row,
        'fecha': (row['fecha'] as DateTime?)?.toIso8601String(),
      };

      return Response.ok(
        jsonEncode(response),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, st) {
      print('❌ Error creando valoración: $e\n$st');
      return Response.internalServerError(body: 'Error interno');
    }
  });

  // Listar valoraciones de un barbero
  router.get('/valoraciones/barbero/<barberoId>', (Request req, String barberoId) async {
    try {
      final result = await db.execute(
        '''
        SELECT v.calificacion, v.comentario, v.fecha,
               u.nombre_completo AS cliente_nombre
        FROM valoraciones v
        JOIN usuarios u ON u.id = v.cliente_id
        WHERE v.barbero_id = \$1
        ORDER BY v.fecha DESC
        ''',
        parameters: [int.parse(barberoId)],
      );

      final list = result.map((r) {
        final row = r.toColumnMap();
        return {
          'calificacion': row['calificacion'],
          'comentario': row['comentario'],
          'fecha': (row['fecha'] as DateTime?)?.toIso8601String(),
          'cliente_nombre': row['cliente_nombre'],
        };
      }).toList();

      return Response.ok(
        jsonEncode(list),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, st) {
      print('❌ Error listando valoraciones: $e\n$st');
      return Response.internalServerError(body: 'Error interno');
    }
  });

  return router;
}

final valoracionesRoutes = getValoracionesRoutes();