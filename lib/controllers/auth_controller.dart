import 'package:styleapp/services/api_service.dart';

import '../models/user_model.dart';
import '../models/auth_response_model.dart';
import '../models/role_enum.dart';
import '../services/storage_service.dart';
import '../services/storage_service.dart';
import '../config/constants.dart';

class AuthController {
  final ApiService _apiService = ApiService();
  StorageService? _storageService;

  Future<void> _initStorage() async {
    _storageService ??= await StorageService.getInstance();
  }

  // Login
  Future<AuthResponseModel> login(String correo, String contrasena) async {
    try {
      // Validaciones
      if (correo.isEmpty || contrasena.isEmpty) {
        return AuthResponseModel.error(
          message: 'Por favor complete todos los campos',
        );
      }

      if (!_isValidEmail(correo)) {
        return AuthResponseModel.error(message: 'Correo electrónico inválido');
      }

      // Llamada a la API
      final response = await _apiService.post(AppConstants.loginEndpoint, {
        'correo': correo,
        'contrasena': contrasena,
      });

      // Procesar respuesta
      if (response['success'] == true) {
        final authResponse = AuthResponseModel.fromJson(response);

        // Guardar token y usuario
        await _saveAuthData(authResponse);

        return authResponse;
      } else {
        return AuthResponseModel.error(
          message: response['message'] ?? 'Error al iniciar sesión',
        );
      }
    } catch (e) {
      return AuthResponseModel.error(
        message: 'Error de conexión. Intenta nuevamente.',
      );
    }
  }

  // Registro de Cliente
  Future<AuthResponseModel> registerClient({
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    required String confirmacionContrasena,
  }) async {
    return await _register(
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      contrasena: contrasena,
      confirmacionContrasena: confirmacionContrasena,
      rol: UserRole.client,
    );
  }

  // Registro de Barbero/Empleado
  Future<AuthResponseModel> registerBarber({
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    required String confirmacionContrasena,
  }) async {
    return await _register(
      nombre: nombre,
      apellido: apellido,
      correo: correo,
      contrasena: contrasena,
      confirmacionContrasena: confirmacionContrasena,
      rol: UserRole.barber,
    );
  }

  // Método privado de registro
  Future<AuthResponseModel> _register({
    required String nombre,
    required String apellido,
    required String correo,
    required String contrasena,
    required String confirmacionContrasena,
    required UserRole rol,
  }) async {
    try {
      // Validaciones
      final validation = _validateRegistration(
        nombre,
        apellido,
        correo,
        contrasena,
        confirmacionContrasena,
      );

      if (!validation['isValid']) {
        return AuthResponseModel.error(message: validation['message']);
      }

      // Llamada a la API
      final response = await _apiService.post(AppConstants.registerEndpoint, {
        'nombre': nombre,
        'apellido': apellido,
        'correo': correo,
        'contrasena': contrasena,
        'rol': rol.value,
      });

      if (response['success'] == true) {
        final authResponse = AuthResponseModel.fromJson(response);
        await _saveAuthData(authResponse);
        return authResponse;
      } else {
        return AuthResponseModel.error(
          message: response['message'] ?? 'Error al registrar usuario',
        );
      }
    } catch (e) {
      return AuthResponseModel.error(
        message: 'Error de conexión. Intenta nuevamente.',
      );
    }
  }

  // Cerrar sesión
  Future<bool> logout() async {
    try {
      await _initStorage();
      await _storageService!.remove(AppConstants.tokenKey);
      await _storageService!.remove(AppConstants.userKey);
      await _storageService!.remove(AppConstants.roleKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Guardar datos de autenticación
  Future<void> _saveAuthData(AuthResponseModel authResponse) async {
    await _initStorage();

    if (authResponse.token != null) {
      await _storageService!.saveString(
        AppConstants.tokenKey,
        authResponse.token!,
      );
    }

    if (authResponse.user != null) {
      await _storageService!.saveJson(
        AppConstants.userKey,
        authResponse.user!.toJson(),
      );
      await _storageService!.saveString(
        AppConstants.roleKey,
        authResponse.user!.rol.value,
      );
    }
  }

  // Validaciones
  Map<String, dynamic> _validateRegistration(
    String nombre,
    String apellido,
    String correo,
    String contrasena,
    String confirmacionContrasena,
  ) {
    if (nombre.isEmpty ||
        apellido.isEmpty ||
        correo.isEmpty ||
        contrasena.isEmpty ||
        confirmacionContrasena.isEmpty) {
      return {'isValid': false, 'message': 'Todos los campos son obligatorios'};
    }

    if (!_isValidEmail(correo)) {
      return {'isValid': false, 'message': 'Correo electrónico inválido'};
    }

    if (contrasena.length < AppConstants.minPasswordLength) {
      return {
        'isValid': false,
        'message':
            'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres',
      };
    }

    if (contrasena != confirmacionContrasena) {
      return {'isValid': false, 'message': 'Las contraseñas no coinciden'};
    }

    return {'isValid': true};
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
