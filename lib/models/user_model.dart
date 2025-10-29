import 'role_enum.dart';

class UserModel {
  final String id;
  final String nombre;
  final String apellido;
  final String correo;
  final String? telefono;
  final UserRole rol;
  final String? confirmacionContrasena;
  final DateTime? fechaCreacion;

  UserModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.correo,
    this.telefono,
    required this.rol,
    this.confirmacionContrasena,
    this.fechaCreacion,
  });

  // Convertir desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? json['name'] ?? '',
      apellido: json['apellido'] ?? json['lastName'] ?? '',
      correo: json['correo'] ?? json['email'] ?? '',
      telefono: json['telefono'] ?? json['phone'],
      rol: UserRoleExtension.fromString(
        json['rol'] ?? json['role'] ?? 'client',
      ),
      fechaCreacion: json['fechaCreacion'] != null
          ? DateTime.parse(json['fechaCreacion'])
          : null,
    );
  }

  // Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'correo': correo,
      'telefono': telefono,
      'rol': rol.value,
      'fechaCreacion': fechaCreacion?.toIso8601String(),
    };
  }

  // Crear copia con modificaciones
  UserModel copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? correo,
    String? telefono,
    UserRole? rol,
    String? confirmacionContrasena,
    DateTime? fechaCreacion,
  }) {
    return UserModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      confirmacionContrasena:
          confirmacionContrasena ?? this.confirmacionContrasena,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  // Obtener nombre completo
  String get nombreCompleto => '$nombre $apellido';

  @override
  String toString() {
    return 'UserModel(id: $id, nombre: $nombre, apellido: $apellido, correo: $correo, rol: ${rol.name})';
  }
}
