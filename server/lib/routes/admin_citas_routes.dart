// server/lib/routes/admin_citas_routes.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/db.dart';

Router getAdminCitasRoutes() {
  final router = Router();

  // Completar citas vencidas (solo admin)
  router.post('/citas/completar-vencidas', (Request req) async {
    try {
      final now = DateTime.now();
      final nowStr = now.toIso8601String();

      final result = await db.execute(
        '''
        UPDATE citas
        SET estado = 'completada'
        WHERE estado = 'confirmada'
          AND (
            (fecha || ' ' || hora)::timestamp +
            (SELECT duracion_minutos FROM servicios WHERE id = citas.servicio_id) * interval '1 minute'
          ) <= \$1::timestamp
        RETURNING id
        ''',
        parameters: [nowStr],
      );

      return Response.ok(
        jsonEncode({
          'message': 'Citas vencidas actualizadas a "completada"',
          'actualizadas': result.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e, st) {
      print('❌ Error completando citas vencidas: $e\n$st');
      return Response.internalServerError(body: 'Error interno al completar citas');
    }
  });


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

final adminCitasRoutes = getAdminCitasRoutes();
