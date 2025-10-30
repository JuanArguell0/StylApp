import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/barberos_service.dart';
import 'barbero_form_view.dart';

class BarberosAdminView extends StatefulWidget {
  const BarberosAdminView({super.key});

  @override
  State<BarberosAdminView> createState() => _BarberosAdminViewState();
}

class _BarberosAdminViewState extends State<BarberosAdminView> {
  List<dynamic> barberos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBarberos();
  }

  Future<void> fetchBarberos() async {
    setState(() => isLoading = true);
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final barberosService = BarberosService(authController.token!);
      final data = await barberosService.listar();
      setState(() {
        barberos = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando barberos: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _openForm({Map<String, dynamic>? barbero}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BarberoFormView(barbero: barbero),
      ),
    );
    if (result == true) {
      fetchBarberos(); // refrescar lista al volver
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Gestión de Barberos"),
        backgroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber.shade600,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : barberos.isEmpty
              ? const Center(
                  child: Text(
                    "No hay barberos registrados",
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: barberos.length,
                  itemBuilder: (context, index) {
                    final b = barberos[index];
                    return Card(
                      color: Colors.grey.shade900,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          b['nombre_completo'] ?? '',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Especialidades: ${b['especialidades'] ?? ''}\n"
                          "Horario: ${b['horario_inicio']} - ${b['horario_fin']}\n"
                          "Días: ${b['dias_disponibles'] ?? ''}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.amber),
                          onPressed: () => _openForm(barbero: b),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
