class UserModel {
  final int id;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final int rolId;
  final bool activo;
  final DateTime fechaRegistro;

  UserModel({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.rolId,
    required this.activo,
    required this.fechaRegistro,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      nombreCompleto: json['nombre_completo'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      rolId: json['rol_id'] as int,
      activo: json['activo'] as bool,
      fechaRegistro: DateTime.parse(json['fecha_registro']),
    );
  }
}
