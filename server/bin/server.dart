// server/bin/server.dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart';
import '../lib/database/db.dart';
import '../lib/routes/auth_routes.dart';
import '../lib/routes/citas_routes.dart';
import '../lib/routes/barberos_routes.dart';
import '../lib/routes/servicios_routes.dart';
import '../lib/routes/admin_users_routes.dart';
import '../lib/routes/valoraciones_routes.dart'; 
import '../lib/middleware/auth_middleware.dart';
import '../lib/routes/admin_citas_routes.dart'; // 👈 nuevo

void main() async {
  final env = DotEnv()..load();
  await initDatabase();

  // ------------------------
  // Router público
  // ------------------------
  final publicRouter = Router()
    ..get('/api/health', (_) => Response.ok('✅ Backend StylApp activo\n'))
    ..mount('/', authRoutes); // /api/register, /api/login

  // ------------------------
  // Router protegido (requiere token)
  // ------------------------
  final secureRouter = Router()
    ..mount('/', citasRoutes)          // 👈 citas requieren token
    ..mount('/', valoracionesRoutes)   // 👈 valoraciones requieren token
    ..get('/', (Request req) {
      final user = req.context['user'] as Map<String, dynamic>?;
      return Response.ok(
          'Área segura. Hola ${user?['email']} (rol ${user?['rolId']})\n');
    });

  // ------------------------
  // Router solo admin
  // ------------------------
  final adminRouter = Router()
    ..get('/metrics', (Request req) => Response.ok('Métricas admin OK\n'))
    ..mount('/', serviciosRoutes)   // ✅ solo admin crea/edita servicios
    ..mount('/', barberosRoutes)    // ✅ solo admin crea/edita barberos
    ..mount('/', adminUsersRoutes) // ✅ solo admin crea usuarios barbero/admin
    ..mount('/', adminCitasRoutes); //  completar manual

  // ------------------------
  // Handlers con middlewares específicos
  // ------------------------
  final publicHandler = publicRouter;

  final secureHandler = const Pipeline()
      .addMiddleware(checkAuth())
      .addHandler(secureRouter);

  final adminHandler = const Pipeline()
      .addMiddleware(checkAuth())
      .addMiddleware(authorizeRoles([3])) // solo rol_id=3
      .addHandler(adminRouter);

  // ------------------------
  // Router final que monta todo con prefijos claros
  // ------------------------
  final app = Router()
    ..mount('/', publicHandler)              // /api/health, /api/register, /api/login
    ..mount('/api/secure', secureHandler)    // /api/secure + /api/citas + /api/valoraciones
    ..mount('/api/admin', adminHandler);     // /api/admin/...

  // ------------------------
  // Pipeline global (logs + CORS)
  // ------------------------
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware)
      .addHandler(app);

  final server = await io.serve(handler, 'localhost', 8080);
  print('🚀 Backend corriendo en http://localhost:8080');
}

// ------------------------
// Middleware CORS global
// ------------------------
Middleware get corsMiddleware {
  return (Handler inner) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      final resp = await inner(request);
      return resp.change(headers: _corsHeaders);
    };
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};
