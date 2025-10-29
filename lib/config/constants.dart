class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://api.stylapp.com'; // Cambiar por tu URL
  static const String apiVersion = '/api/v1';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String appointmentsEndpoint = '/appointments';
  static const String usersEndpoint = '/users';
  static const String barbersEndpoint = '/barbers';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';

  // App Info
  static const String appName = 'StyLApp Barbería';
  static const String appVersion = '1.0.0';

  // Social Media URLs (placeholder)
  static const String facebookUrl = 'https://facebook.com/stylapp';
  static const String twitterUrl = 'https://twitter.com/stylapp';
  static const String instagramUrl = 'https://instagram.com/stylapp';
  static const String tiktokUrl = 'https://tiktok.com/@stylapp';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;

  // Timeouts
  static const Duration requestTimeout = Duration(seconds: 30);
}
