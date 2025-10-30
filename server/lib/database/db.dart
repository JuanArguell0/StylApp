// server/lib/database/db.dart
import 'package:postgres/postgres.dart';
import 'package:dotenv/dotenv.dart';

final env = DotEnv();
late final Connection _connection;

Future<void> initDatabase() async {
  env.load();

  final endpoint = Endpoint(
    host: env['DB_HOST'] ?? 'localhost',
    port: int.tryParse(env['DB_PORT'] ?? '5432') ?? 5432,
    database: env['DB_NAME'] ?? 'barberia',
    username: env['DB_USER'] ?? 'postgres',
    password: env['DB_PASSWORD'] ?? '',
  );

  final settings = ConnectionSettings(sslMode: SslMode.disable);
  _connection = await Connection.open(endpoint, settings: settings);

  print('✅ Conectado a PostgreSQL: ${env['DB_NAME']}');
}

Connection get db => _connection;
