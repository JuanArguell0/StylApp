import 'package:flutter/material.dart';
import '../../../services/barberos_service.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';

class BarberoFormView extends StatefulWidget {
  final Map<String, dynamic>? barbero; // null = crear, !=null = editar
  const BarberoFormView({super.key, this.barbero});

  @override
  State<BarberoFormView> createState() => _BarberoFormViewState();
}

class _BarberoFormViewState extends State<BarberoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _especialidadesController = TextEditingController();
  final _horarioInicioController = TextEditingController();
  final _horarioFinController = TextEditingController();
  final _diasDisponiblesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.barbero != null) {
      _nombreController.text = widget.barbero!['nombre_completo'] ?? '';
      _emailController.text = widget.barbero!['email'] ?? '';
      _telefonoController.text = widget.barbero!['telefono'] ?? '';
      _especialidadesController.text = widget.barbero!['especialidades'] ?? '';
      _horarioInicioController.text = widget.barbero!['horario_inicio'] ?? '';
      _horarioFinController.text = widget.barbero!['horario_fin'] ?? '';
      _diasDisponiblesController.text = widget.barbero!['dias_disponibles'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final barberosService = BarberosService(authController.token!);
    final isEdit = widget.barbero != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Editar Barbero" : "Nuevo Barbero"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField("Nombre completo", _nombreController),
              _buildField("Correo electrónico", _emailController),
              _buildField("Teléfono", _telefonoController),
              if (!isEdit) _buildField("Contraseña", _passwordController, obscure: true),
              _buildField("Especialidades", _especialidadesController),
              _buildField("Horario inicio (HH:mm)", _horarioInicioController),
              _buildField("Horario fin (HH:mm)", _horarioFinController),
              _buildField("Días disponibles (ej: Lun-Vie)", _diasDisponiblesController),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      if (isEdit) {
                        await barberosService.editar(
                          id: widget.barbero!['id'],
                          especialidades: _especialidadesController.text,
                          horarioInicio: _horarioInicioController.text,
                          horarioFin: _horarioFinController.text,
                          diasDisponibles: _diasDisponiblesController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Barbero actualizado")),
                        );
                      } else {
                        await barberosService.crear(
                          nombre: _nombreController.text,
                          email: _emailController.text,
                          telefono: _telefonoController.text,
                          contrasena: _passwordController.text,
                          especialidades: _especialidadesController.text,
                          horarioInicio: _horarioInicioController.text,
                          horarioFin: _horarioFinController.text,
                          diasDisponibles: _diasDisponiblesController.text,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Barbero creado")),
                        );
                      }
                      if (mounted) Navigator.pop(context, true);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  }
                },
                child: Text(isEdit ? "Guardar cambios" : "Crear barbero"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? "Campo obligatorio" : null,
      ),
    );
  }
}
