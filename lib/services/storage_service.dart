import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Guardar datos string
  Future<bool> saveString(String key, String value) async {
    return await _preferences!.setString(key, value);
  }

  // Obtener datos string
  String? getString(String key) {
    return _preferences!.getString(key);
  }

  // Guardar datos JSON
  Future<bool> saveJson(String key, Map<String, dynamic> value) async {
    String jsonString = jsonEncode(value);
    return await _preferences!.setString(key, jsonString);
  }

  // Obtener datos JSON
  Map<String, dynamic>? getJson(String key) {
    String? jsonString = _preferences!.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // Guardar boolean
  Future<bool> saveBool(String key, bool value) async {
    return await _preferences!.setBool(key, value);
  }

  // Obtener boolean
  bool? getBool(String key) {
    return _preferences!.getBool(key);
  }

  // Guardar int
  Future<bool> saveInt(String key, int value) async {
    return await _preferences!.setInt(key, value);
  }

  // Obtener int
  int? getInt(String key) {
    return _preferences!.getInt(key);
  }

  // Eliminar un dato específico
  Future<bool> remove(String key) async {
    return await _preferences!.remove(key);
  }

  // Limpiar todos los datos
  Future<bool> clearAll() async {
    return await _preferences!.clear();
  }

  // Verificar si existe una key
  bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }
}
