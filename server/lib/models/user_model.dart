// lib/models/user_model.dart
class UserModel {
  final int? id;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String contrasena; // texto plano por ahora
  final int rolId; // 1=cliente, 2=barbero, 3=admin

  UserModel({
    this.id,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.contrasena,
    this.rolId = 1, // cliente por defecto
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre_completo': nombreCompleto,
        'email': email,
        'telefono': telefono,
        'rol_id': rolId,
      };
}