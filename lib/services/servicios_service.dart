import 'dart:convert';
import 'package:http/http.dart' as http;

class ServiciosService {
  final String baseUrl = "http://10.0.2.2:8080/api/admin"; // Ajusta según entorno
  final String token;

  ServiciosService(this.token);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// Listar servicios
  Future<List<dynamic>> listar() async {
    final res = await http.get(Uri.parse('$baseUrl/servicios'), headers: _headers);
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error listando servicios: ${res.body}");
    }
  }

  /// Crear servicio
  Future<Map<String, dynamic>> crear({
    required String nombre,
    required String descripcion,
    required int duracion,
    required double precio,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/servicios'),
      headers: _headers,
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'duracion_minutos': duracion,
        'precio': precio,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error creando servicio: ${res.body}");
    }
  }

  /// Editar servicio
  Future<Map<String, dynamic>> editar({
    required int id,
    String? nombre,
    String? descripcion,
    int? duracion,
    double? precio,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/servicios/$id'),
      headers: _headers,
      body: jsonEncode({
        'nombre': nombre,
        'descripcion': descripcion,
        'duracion_minutos': duracion,
        'precio': precio,
      }),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Error editando servicio: ${res.body}");
    }
  }
}
