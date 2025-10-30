import 'dart:convert';
import 'package:http/http.dart' as http;

class BarberosService {
  final String baseUrl = "http://10.0.2.2:8080/api/admin"; // Ajusta según entorno
  final String token; // Token del admin

  BarberosService(this.token);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// Listar barberos
  Future<List<dynamic>> listar() async {
    final res = await http.get(Uri.parse('$baseUrl/barberos'), headers: _headers);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error listando barberos: ${res.body}");
    }
  }

  /// Crear usuario barbero + ficha profesional
  Future<Map<String, dynamic>> crear({
    required String nombre,
    required String email,
    required String telefono,
    required String contrasena,
    required String especialidades,
    required String horarioInicio,
    required String horarioFin,
    required String diasDisponibles,
  }) async {
    // 1. Crear usuario barbero
    final userRes = await http.post(
      Uri.parse('$baseUrl/usuarios/barbero'),
      headers: _headers,
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'contrasena': contrasena,
      }),
    );

    if (userRes.statusCode != 200) {
      throw Exception("Error creando usuario barbero: ${userRes.body}");
    }

    final user = jsonDecode(userRes.body);
    final usuarioId = user['id'];

    // 2. Crear ficha profesional
    final barberRes = await http.post(
      Uri.parse('$baseUrl/barberos'),
      headers: _headers,
      body: jsonEncode({
        'usuario_id': usuarioId,
        'especialidades': especialidades,
        'horario_inicio': horarioInicio,
        'horario_fin': horarioFin,
        'dias_disponibles': diasDisponibles,
      }),
    );

    if (barberRes.statusCode != 200) {
      throw Exception("Error creando ficha barbero: ${barberRes.body}");
    }

    return jsonDecode(barberRes.body);
  }

  /// Editar barbero
  Future<Map<String, dynamic>> editar({
    required int id,
    String? especialidades,
    String? horarioInicio,
    String? horarioFin,
    String? diasDisponibles,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/barberos/$id'),
      headers: _headers,
      body: jsonEncode({
        'especialidades': especialidades,
        'horario_inicio': horarioInicio,
        'horario_fin': horarioFin,
        'dias_disponibles': diasDisponibles,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error editando barbero: ${res.body}");
    }
  }
}
