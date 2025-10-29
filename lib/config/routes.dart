import 'package:flutter/material.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_client_view.dart';
import '../views/auth/register_barber_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../views/admin/admin_appointments_view.dart';
import '../views/client/client_home_view.dart';
import '../views/barber/barber_profile_view.dart';

class AppRoutes {
  // Rutas de autenticación
  static const String login = '/login';
  static const String registerClient = '/register-client';
  static const String registerBarber = '/register-barber';

  // Rutas de administrador
  static const String adminDashboard = '/admin-dashboard';
  static const String adminAppointments = '/admin-appointments';

  // Rutas de cliente
  static const String clientHome = '/client-home';

  // Rutas de barbero
  static const String barberProfile = '/barber-profile';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginView(),
    registerClient: (context) => const RegisterClientView(),
    registerBarber: (context) => const RegisterBarberView(),
    adminDashboard: (context) => const AdminDashboardView(),
    adminAppointments: (context) => const AdminAppointmentsView(),
    clientHome: (context) => const ClientHomeView(),
    barberProfile: (context) => const BarberProfileView(),
  };
}
