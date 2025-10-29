enum UserRole { admin, client, barber }

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.client:
        return 'Cliente';
      case UserRole.barber:
        return 'Barbero';
    }
  }

  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.client:
        return 'client';
      case UserRole.barber:
        return 'barber';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
      case 'administrador':
        return UserRole.admin;
      case 'barber':
      case 'barbero':
      case 'empleado':
        return UserRole.barber;
      case 'client':
      case 'cliente':
      default:
        return UserRole.client;
    }
  }
}
