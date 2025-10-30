import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/servicios_service.dart';
import 'servicio_form_view.dart';

class ServiciosAdminView extends StatefulWidget {
  const ServiciosAdminView({super.key});

  @override
  State<ServiciosAdminView> createState() => _ServiciosAdminViewState();
}

class _ServiciosAdminViewState extends State<ServiciosAdminView> {
  List<dynamic> servicios = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchServicios();
  }

  Future<void> fetchServicios() async {
    setState(() => isLoading = true);
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final serviciosService = ServiciosService(authController.token!);
      final data = await serviciosService.listar();
      setState(() {
        servicios = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando servicios: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _openForm({Map<String, dynamic>? servicio}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServicioFormView(servicio: servicio),
      ),
    );
    if (result == true) {
      fetchServicios(); // refrescar lista al volver
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Gestión de Servicios"),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber.shade600,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : servicios.isEmpty
              ? const Center(
                  child: Text(
                    "No hay servicios registrados",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: servicios.length,
                  itemBuilder: (context, index) {
                    final s = servicios[index];
                    return Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          s['nombre'] ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Duración: ${s['duracion_minutos']} min\n"
                          "Precio: \$${s['precio']}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () => _openForm(servicio: s),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
