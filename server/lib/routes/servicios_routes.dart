// server/lib/routes/servicios_routes.dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../database/db.dart';

Router getServiciosRoutes() {
  final router = Router();

  // Crear servicio (solo admin)
  router.post('/servicios', (Request req) async {
    try {
      final body = jsonDecode(await req.readAsString());
      final nombre = body['nombre'] as String?;
      final descripcion = body['descripcion'] as String? ?? '';
      final duracion = body['duracion_minutos'] as int?;
      final precio = body['precio'];

      if (nombre == null || duracion == null || precio == null) {
        return Response(400,
            body: 'nombre, duracion_minutos y precio son obligatorios');
      }

      final result = await db.execute(
        '''
        INSERT INTO servicios (nombre, descripcion, duracion_minutos, precio, activo)
        VALUES (\$1, \$2, \$3, \$4::numeric, true)
        RETURNING id, nombre, descripcion, duracion_minutos, precio, activo
        ''',
        parameters: [nombre, descripcion, duracion, precio],
      );

      return Response.ok(jsonEncode(result.first.toColumnMap()),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('❌ Error creando servicio: $e\n$st');
      return Response.internalServerError(body: 'Error interno');
    }
  });

  // Editar servicio (solo admin)
  router.put('/servicios/<id>', (Request req, String id) async {
    try {
      final body = jsonDecode(await req.readAsString());
      final nombre = body['nombre'] as String?;
      final descripcion = body['descripcion'] as String?;
      final duracion = body['duracion_minutos'] as int?;
      final precio = body['precio'];

      final result = await db.execute(
        '''
        UPDATE servicios
        SET nombre = COALESCE(\$1, nombre),
            descripcion = COALESCE(\$2, descripcion),
            duracion_minutos = COALESCE(\$3, duracion_minutos),
            precio = COALESCE(\$4::numeric, precio)
        WHERE id = \$5
        RETURNING id, nombre, descripcion, duracion_minutos, precio, activo
        ''',
        parameters: [nombre, descripcion, duracion, precio, int.parse(id)],
      );

      if (result.isEmpty) return Response(404, body: 'Servicio no encontrado');

      return Response.ok(jsonEncode(result.first.toColumnMap()),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('❌ Error editando servicio: $e\n$st');
      return Response.internalServerError(body: 'Error interno');
    }
  });

  // Listar servicios activos (público)
  router.get('/servicios', (Request req) async {
    try {
      final result = await db.execute(
        'SELECT id, nombre, descripcion, duracion_minutos, precio, activo FROM servicios WHERE activo = true',
      );
      final list = result.map((r) => r.toColumnMap()).toList();
      return Response.ok(jsonEncode(list),
          headers: {'Content-Type': 'application/json'});
    } catch (e, st) {
      print('❌ Error listando servicios: $e\n$st');
      return Response.internalServerError(body: 'Error interno');
    }
  });

  return router;
}

final serviciosRoutes = getServiciosRoutes();
