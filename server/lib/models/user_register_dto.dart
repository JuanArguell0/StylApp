// lib/models/user_register_dto.dart (Frontend Flutter)
class UserRegisterDTO {
  final String nombre;
  final String email;
  final String telefono;
  final String contrasena;
  final int rolId; // 1=cliente, 2=barbero, 3=admin

  UserRegisterDTO({
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.contrasena,
    this.rolId = 1,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'contrasena': contrasena,
        'rol_id': rolId,
      };
}
