import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  // ⚠️ Ajusta según tu entorno:
  // - Android emulador: 10.0.2.2
  // - iOS emulador: 127.0.0.1
  // - Dispositivo físico: IP local de tu PC
  final String baseUrl = "http://10.0.2.2:8080/api";

  /// Registro de cliente
  Future<Map<String, dynamic>> register({
    required String nombre,
    required String email,
    required String telefono,
    required String contrasena,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nombre': nombre,
              'email': email,
              'telefono': telefono,
              'contrasena': contrasena,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print("🔎 [REGISTER] Status: ${response.statusCode}");
      print("🔎 [REGISTER] Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data['user']);
        return {
          'token': data['token'],
          'user': user,
        };
      } else {
        throw Exception('Error en registro: ${response.body}');
      }
    } catch (e) {
      print("❌ Excepción en register: $e");
      rethrow;
    }
  }

  /// Login de usuario
  Future<Map<String, dynamic>> login({
    required String email,
    required String contrasena,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'contrasena': contrasena,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print("🔎 [LOGIN] Status: ${response.statusCode}");
      print("🔎 [LOGIN] Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data['user']);
        return {
          'token': data['token'],
          'user': user,
        };
      } else {
        throw Exception('Error en login: ${response.body}');
      }
    } catch (e) {
      print("❌ Excepción en login: $e");
      rethrow;
    }
  }
}
