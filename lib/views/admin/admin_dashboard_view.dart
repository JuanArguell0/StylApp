import 'package:flutter/material.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Panel de Administración",
          style: TextStyle(
            color: Colors.amber.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(
              context,
              icon: Icons.people,
              title: "Usuarios",
              subtitle: "Gestión de clientes y barberos",
              onTap: () {
                // TODO: Navegar a gestión de usuarios
              },
            ),
            _buildCard(
              context,
              icon: Icons.cut,
              title: "Barberos",
              subtitle: "Horarios y especialidades",
              onTap: () {
                // TODO: Navegar a gestión de barberos
              },
            ),
            _buildCard(
              context,
              icon: Icons.design_services,
              title: "Servicios",
              subtitle: "Precios y duración",
              onTap: () {
                // TODO: Navegar a gestión de servicios
              },
            ),
            _buildCard(
              context,
              icon: Icons.analytics,
              title: "Métricas",
              subtitle: "Citas e ingresos",
              onTap: () {
                // TODO: Navegar a métricas admin
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber.shade600, width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.amber.shade600),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
