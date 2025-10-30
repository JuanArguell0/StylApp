import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/db.dart';

Router getCitasRoutes() {
  final router = Router();

  // Crear cita (solo clientes autenticados)
router.post('/citas', (Request req) async {
  try {
    final user = req.context['user'] as Map<String, dynamic>?;
    if (user == null || user['rolId'] != 1) {
      return Response.forbidden('Solo clientes pueden agendar citas');
    }

    final body = jsonDecode(await req.readAsString());
    final clienteId = user['id'] as int;
    final barberoId = body['barbero_id'] as int?;
    final servicioId = body['servicio_id'] as int?;
    final fecha = DateTime.tryParse(body['fecha'] ?? '');
    final hora = body['hora'] as String?;

    if ([barberoId, servicioId, fecha, hora].contains(null)) {
      return Response(400, body: 'Faltan campos obligatorios');
    }

    final fechaCita = fecha!;

    // 1. Duración del servicio
    final duracionResult = await db.execute(
      'SELECT duracion_minutos FROM servicios WHERE id = \$1',
      parameters: [servicioId],
    );
    if (duracionResult.isEmpty) {
      return Response(400, body: 'Servicio no encontrado');
    }
    final duracionNueva = duracionResult.first[0] as int;

    // 2. Horario del barbero
    final horarioResult = await db.execute(
      'SELECT horario_inicio, horario_fin, dias_disponibles FROM barberos WHERE id = \$1',
      parameters: [barberoId],
    );
    if (horarioResult.isEmpty) {
      return Response(400, body: 'Barbero no encontrado');
    }

    final barbero = horarioResult.first.toColumnMap();
    final inicioTime = barbero['horario_inicio'];
    final finTime = barbero['horario_fin'];
    final diasDisponibles = (barbero['dias_disponibles'] as String).split('-');

    final diaSemana = ['LUN','MAR','MIE','JUE','VIE','SAB','DOM'][fechaCita.weekday - 1];
    if (!diasDisponibles.contains(diaSemana)) {
      return Response.forbidden('El barbero no trabaja el día seleccionado');
    }

    final horaInicio = DateTime(fechaCita.year, fechaCita.month, fechaCita.day,
        inicioTime.hour, inicioTime.minute);
    final horaFin = DateTime(fechaCita.year, fechaCita.month, fechaCita.day,
        finTime.hour, finTime.minute);

    final citaInicio = DateTime.parse('${fechaCita.toIso8601String().split("T")[0]} $hora');
    final citaFin = citaInicio.add(Duration(minutes: duracionNueva));

    if (citaInicio.isBefore(horaInicio) || citaFin.isAfter(horaFin)) {
      return Response.forbidden('La cita está fuera del horario laboral del barbero');
    }

    // 3. Validar solapamiento
    final check = await db.execute(
      '''
      SELECT 1
      FROM citas c
      JOIN servicios s ON c.servicio_id = s.id
      WHERE c.barbero_id = \$1
        AND c.fecha = \$2
        AND c.estado IN ('pendiente','confirmada')
        AND (
          (c.hora, c.hora + (s.duracion_minutos || ' minutes')::interval)
            OVERLAPS (\$3::time, \$3::time + (\$4 || ' minutes')::interval)
        )
      ''',
      parameters: [barberoId, fechaCita, hora, duracionNueva],
    );

    if (check.isNotEmpty) {
      return Response(409, body: 'El barbero ya tiene una cita en ese rango de tiempo');
    }

    // 4. Insertar cita
    final result = await db.execute(
      '''
      INSERT INTO citas (cliente_id, barbero_id, servicio_id, fecha, hora)
      VALUES (\$1, \$2, \$3, \$4, \$5::time)
      RETURNING id, cliente_id, barbero_id, servicio_id, fecha, hora, estado, creado_en
      ''',
      parameters: [clienteId, barberoId, servicioId, fechaCita, hora],
    );

    final row = result.first.toColumnMap();
    final response = {
      'message': 'Cita agendada exitosamente',
      ...row,
      'fecha': row['fecha']?.toString(),
      'hora': row['hora']?.toString(),
      'creado_en': row['creado_en']?.toString(),
    };

    return Response.ok(jsonEncode(response),
        headers: {'Content-Type': 'application/json'});
  } catch (e, st) {
    print('❌ Error creando cita: $e\n$st');
    return Response.internalServerError(body: 'Error interno');
  }
});

// Reagendar cita
router.put('/citas/<id>', (Request req, String id) async {
  try {
    final body = jsonDecode(await req.readAsString());
    final fecha = DateTime.tryParse(body['fecha'] ?? '');
    final hora = body['hora'] as String?;

    if (fecha == null || hora == null) {
      return Response(400, body: 'Fecha y hora requeridas');
    }

    final fechaCita = fecha;

    // 1. Obtener servicio y barbero de la cita actual
    final citaResult = await db.execute(
      'SELECT servicio_id, barbero_id FROM citas WHERE id = \$1',
      parameters: [int.parse(id)],
    );
    if (citaResult.isEmpty) {
      return Response(404, body: 'Cita no encontrada');
    }
    final servicioId = citaResult.first[0] as int;
    final barberoId = citaResult.first[1] as int;

    // 2. Obtener duración del servicio
    final duracionResult = await db.execute(
      'SELECT duracion_minutos FROM servicios WHERE id = \$1',
      parameters: [servicioId],
    );
    if (duracionResult.isEmpty) {
      return Response(400, body: 'Servicio no encontrado');
    }
    final duracionNueva = duracionResult.first[0] as int;

    // 3. Validar horario laboral del barbero
    final horarioResult = await db.execute(
      'SELECT horario_inicio, horario_fin, dias_disponibles FROM barberos WHERE id = \$1',
      parameters: [barberoId],
    );
    if (horarioResult.isEmpty) {
      return Response(400, body: 'Barbero no encontrado');
    }

    final barbero = horarioResult.first.toColumnMap();
    final inicioTime = barbero['horario_inicio'];
    final finTime = barbero['horario_fin'];
    final diasDisponibles = (barbero['dias_disponibles'] as String).split('-');

    final diaSemana = ['LUN','MAR','MIE','JUE','VIE','SAB','DOM'][fechaCita.weekday - 1];
    if (!diasDisponibles.contains(diaSemana)) {
      return Response.forbidden('El barbero no trabaja el día seleccionado');
    }

    // Construir DateTime de inicio/fin de jornada
    final horaInicio = DateTime(
      fechaCita.year,
      fechaCita.month,
      fechaCita.day,
      inicioTime.hour,
      inicioTime.minute,
    );

    final horaFin = DateTime(
      fechaCita.year,
      fechaCita.month,
      fechaCita.day,
      finTime.hour,
      finTime.minute,
    );

    // Construir inicio/fin de la cita
    final citaInicio = DateTime.parse('${fechaCita.toIso8601String().split("T")[0]} $hora');
    final citaFin = citaInicio.add(Duration(minutes: duracionNueva));

    if (citaInicio.isBefore(horaInicio) || citaFin.isAfter(horaFin)) {
      return Response.forbidden('La cita está fuera del horario laboral del barbero');
    }

    // 4. Validar solapamiento con otras citas
    final check = await db.execute(
      '''
      SELECT 1
      FROM citas c
      JOIN servicios s ON c.servicio_id = s.id
      WHERE c.barbero_id = \$1
        AND c.fecha = \$2
        AND c.estado IN ('pendiente','confirmada')
        AND c.id <> \$3
        AND (
          (c.hora, c.hora + (s.duracion_minutos || ' minutes')::interval)
            OVERLAPS (\$4::time, \$4::time + (\$5 || ' minutes')::interval)
        )
      ''',
      parameters: [barberoId, fechaCita, int.parse(id), hora, duracionNueva],
    );

    if (check.isNotEmpty) {
      return Response(409, body: 'El barbero ya tiene otra cita en ese rango de tiempo');
    }

    // 5. Actualizar cita
    final result = await db.execute(
      '''
      UPDATE citas 
      SET fecha = \$1, hora = \$2::time
      WHERE id = \$3
      RETURNING id, cliente_id, barbero_id, servicio_id, fecha, hora, estado, creado_en
      ''',
      parameters: [fechaCita, hora, int.parse(id)],
    );

    if (result.isEmpty) return Response(404, body: 'Cita no encontrada');

    final row = result.first.toColumnMap();
    final response = {
      'message': 'Cita reagendada exitosamente',
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
    print('❌ Error reagendando cita: $e\n$st');
    return Response.internalServerError(body: 'Error interno');
  }
});





  // Listar citas
router.get('/citas', (Request req) async {
  try {
    final params = req.url.queryParameters;
    final clienteId = params['cliente_id'];
    final barberoUsuarioId = params['barbero_usuario_id']; // 👈 ojo, pasas el id del usuario barbero

    var query = 'SELECT * FROM citas WHERE 1=1';
    final args = <dynamic>[];

    if (clienteId != null) {
      query += ' AND cliente_id = \$${args.length + 1}';
      args.add(int.parse(clienteId));
    }

    if (barberoUsuarioId != null) {
      // 1. Buscar el id del barbero asociado a este usuario
      final barberoResult = await db.execute(
        'SELECT id FROM barberos WHERE usuario_id = \$1',
        parameters: [int.parse(barberoUsuarioId)],
      );

      if (barberoResult.isNotEmpty) {
        final barberoId = barberoResult.first[0] as int;
        query += ' AND barbero_id = \$${args.length + 1}';
        args.add(barberoId);
      }
    }

    final result = await db.execute(query, parameters: args);
    final citas = result.map((r) {
      final row = r.toColumnMap();
      return {
        ...row,
        'fecha': row['fecha']?.toString(),
        'hora': row['hora']?.toString(),
        'creado_en': row['creado_en']?.toString(),
      };
    }).toList();

    return Response.ok(jsonEncode(citas),
        headers: {'Content-Type': 'application/json'});
  } catch (e, st) {
    print('❌ Error listando citas: $e\n$st');
    return Response.internalServerError(body: 'Error interno');
  }
});




// Confirmar cita (solo barbero)
router.put('/citas/<id>/confirmar', (Request req, String id) async {
  try {
    final user = req.context['user'] as Map<String, dynamic>?;
    if (user == null || user['rolId'] != 2) {
      return Response.forbidden('Solo barberos pueden confirmar citas');
    }

    final usuarioId = user['id'] as int;

    // 1. Buscar el id del barbero asociado a este usuario
    final barberoResult = await db.execute(
      'SELECT id FROM barberos WHERE usuario_id = \$1',
      parameters: [usuarioId],
    );

    if (barberoResult.isEmpty) {
      return Response.forbidden('Este usuario no está registrado como barbero');
    }

    final barberoId = barberoResult.first[0] as int;

    // 2. Confirmar la cita
    final result = await db.execute(
      '''
      UPDATE citas
      SET estado = 'confirmada'
      WHERE id = \$1 AND barbero_id = \$2 AND estado = 'pendiente'
      RETURNING id, cliente_id, barbero_id, servicio_id, fecha, hora, estado, creado_en
      ''',
      parameters: [int.parse(id), barberoId],
    );

    if (result.isEmpty) {
      return Response(404, body: 'Cita no encontrada o ya confirmada');
    }

    final row = result.first.toColumnMap();
    final response = {
      'message': 'Cita confirmada exitosamente',
      ...row,
      'fecha': row['fecha']?.toString(),
      'hora': row['hora']?.toString(),
      'creado_en': row['creado_en']?.toString(),
    };

    return Response.ok(jsonEncode(response),
        headers: {'Content-Type': 'application/json'});
  } catch (e, st) {
    print('❌ Error confirmando cita: $e\n$st');
    return Response.internalServerError(body: 'Error interno');
  }
});



    // Cancelar cita (cliente, con límite de 12 horas)
  router.delete('/citas/<id>', (Request req, String id) async {
    try {
      final user = req.context['user'] as Map<String, dynamic>?;
      if (user == null || user['rolId'] != 1) {
        return Response.forbidden('Solo clientes pueden cancelar sus citas');
      }

      final clienteId = user['id'] as int;

      // Obtener cita
      final citaResult = await db.execute(
        'SELECT fecha, hora FROM citas WHERE id = \$1 AND cliente_id = \$2 AND estado = \'pendiente\'',
        parameters: [int.parse(id), clienteId],
      );

      if (citaResult.isEmpty) {
        return Response(404, body: 'Cita no encontrada o no cancelable');
      }

      final row = citaResult.first.toColumnMap();
      final fecha = row['fecha'] as DateTime;
      final hora = row['hora'] as DateTime;

      final citaDateTime = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        hora.hour,
        hora.minute,
      );

      final now = DateTime.now();
      final diff = citaDateTime.difference(now);

      if (diff.inHours < 12) {
        return Response.forbidden('Solo se puede cancelar con al menos 12 horas de anticipación');
      }

      final result = await db.execute(
        '''
        UPDATE citas SET estado = 'cancelada'
        WHERE id = \$1
        RETURNING id, cliente_id, barbero_id, servicio_id, fecha, hora, estado, creado_en
        ''',
        parameters: [int.parse(id)],
      );

      final updated = result.first.toColumnMap();
      final response = {
        'message': 'Cita cancelada exitosamente',
        ...updated,
        'fecha': updated['fecha']?.toString(),
        'hora': updated['hora']?.toString(),
        'creado_en': updated['creado_en']?.toString(),
      };

      return Response.ok(jsonEncode(response),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('❌ Error cancelando cita: $e\n$st');
      return Response.internalServerError(body: 'Error interno');
    }
  });

  // Cancelar cita (barbero)
router.delete('/citas/<id>/barbero', (Request req, String id) async {
  try {
    final user = req.context['user'] as Map<String, dynamic>?;
    if (user == null || user['rolId'] != 2) {
      return Response.forbidden('Solo barberos pueden cancelar citas');
    }

    final usuarioId = user['id'] as int;

    // 1. Buscar el id del barbero asociado a este usuario
    final barberoResult = await db.execute(
      'SELECT id FROM barberos WHERE usuario_id = \$1',
      parameters: [usuarioId],
    );

    if (barberoResult.isEmpty) {
      return Response.forbidden('Este usuario no está registrado como barbero');
    }

    final barberoId = barberoResult.first[0] as int;

    // 2. Cancelar la cita
    final result = await db.execute(
      '''
      UPDATE citas
      SET estado = 'cancelada', cancelado_por = 'barbero'
      WHERE id = \$1 AND barbero_id = \$2
      RETURNING id, cliente_id, barbero_id, servicio_id, fecha, hora, estado, creado_en
      ''',
      parameters: [int.parse(id), barberoId],
    );

    if (result.isEmpty) {
      return Response(404, body: 'Cita no encontrada o no pertenece a este barbero');
    }

    final row = result.first.toColumnMap();
    final response = {
      'message': 'Cita cancelada por el barbero',
      ...row,
      'fecha': row['fecha']?.toString(),
      'hora': row['hora']?.toString(),
      'creado_en': row['creado_en']?.toString(),
    };

    return Response.ok(jsonEncode(response),
        headers: {'Content-Type': 'application/json'});
  } catch (e, st) {
    print('❌ Error cancelando cita por barbero: $e\n$st');
    return Response.internalServerError(body: 'Error interno');
  }
});

// Marcar citas vencidas como "completadas" (solo para uso interno o job programado)
router.post('/completar-vencidas', (Request req) async {
  try {
    // Opcional: podrías restringirlo a admin si lo deseas con authorizeRoles([3])
    // Pero como es una tarea de mantenimiento, lo dejamos accesible a cualquier autenticado
    // o incluso podrías quitar la autenticación si lo llamas desde un job interno seguro.

    final now = DateTime.now();
    final nowStr = now.toIso8601String();

    // Actualiza todas las citas "confirmadas" cuyo tiempo ya terminó
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



  return router;
}

final citasRoutes = getCitasRoutes();
