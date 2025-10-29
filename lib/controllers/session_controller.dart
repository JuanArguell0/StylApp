import '../models/user_model.dart';
import '../models/role_enum.dart';
import '../services/storage_service.dart';
import '../config/constants.dart';

class SessionController {
  static final SessionController _instance = SessionController._internal();
  factory SessionController() => _instance;
  SessionController._internal();

  StorageService? _storageService;
  UserModel? _currentUser;

  Future<void> _initStorage() async {
    _storageService ??= await StorageService.getInstance();
  }

  // Verificar si hay sesión activa
  Future<bool> hasActiveSession() async {
    await _initStorage();
    String? token = _storageService!.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Obtener usuario actual
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    await _initStorage();
    Map<String, dynamic>? userData = _storageService!.getJson(
      AppConstants.userKey,
    );

    if (userData != null) {
      _currentUser = UserModel.fromJson(userData);
      return _currentUser;
    }

    return null;
  }

  // Obtener rol del usuario
  Future<UserRole?> getUserRole() async {
    await _initStorage();
    String? roleString = _storageService!.getString(AppConstants.roleKey);

    if (roleString != null) {
      return UserRoleExtension.fromString(roleString);
    }

    UserModel? user = await getCurrentUser();
    return user?.rol;
  }

  // Obtener token
  Future<String?> getToken() async {
    await _initStorage();
    return _storageService!.getString(AppConstants.tokenKey);
  }

  // Actualizar usuario en sesión
  Future<void> updateUser(UserModel user) async {
    await _initStorage();
    _currentUser = user;
    await _storageService!.saveJson(AppConstants.userKey, user.toJson());
  }

  // Limpiar sesión
  Future<void> clearSession() async {
    await _initStorage();
    _currentUser = null;
    await _storageService!.remove(AppConstants.tokenKey);
    await _storageService!.remove(AppConstants.userKey);
    await _storageService!.remove(AppConstants.roleKey);
  }

  // Verificar si es admin
  Future<bool> isAdmin() async {
    UserRole? role = await getUserRole();
    return role == UserRole.admin;
  }

  // Verificar si es cliente
  Future<bool> isClient() async {
    UserRole? role = await getUserRole();
    return role == UserRole.client;
  }

  // Verificar si es barbero
  Future<bool> isBarber() async {
    UserRole? role = await getUserRole();
    return role == UserRole.barber;
  }
}
