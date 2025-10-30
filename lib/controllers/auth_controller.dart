import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Registro de cliente
  Future<bool> register({
    required String nombre,
    required String email,
    required String telefono,
    required String contrasena,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.register(
        nombre: nombre,
        email: email,
        telefono: telefono,
        contrasena: contrasena,
      );
      _token = result['token'];
      _currentUser = result['user'];
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Login de cliente
  Future<bool> login({
    required String email,
    required String contrasena,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.login(
        email: email,
        contrasena: contrasena,
      );
      _token = result['token'];
      _currentUser = result['user'];
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void logout() {
    _token = null;
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
