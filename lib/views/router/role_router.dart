import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../admin/admin_dashboard_view.dart';

// TODO: Crear estas vistas más adelante
class ClienteDashboardView extends StatelessWidget {
  const ClienteDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Dashboard Cliente (en construcción)"),
      ),
    );
  }
}

class BarberoDashboardView extends StatelessWidget {
  const BarberoDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Panel Barbero (en construcción)"),
      ),
    );
  }
}

class RoleRouter extends StatelessWidget {
  const RoleRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    if (authController.currentUser == null) {
      // Si no hay usuario autenticado, volver al login
      return const Scaffold(
        body: Center(child: Text("No autenticado")),
      );
    }

    final rolId = authController.currentUser!.rolId;

    switch (rolId) {
      case 1:
        return const ClienteDashboardView();
      case 2:
        return const BarberoDashboardView();
      case 3:
        return const AdminDashboardView();
      default:
        return const Scaffold(
          body: Center(child: Text("Rol no reconocido")),
        );
    }
  }
}
