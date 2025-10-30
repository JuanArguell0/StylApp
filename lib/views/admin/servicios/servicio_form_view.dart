import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/auth_controller.dart';
import '../../../services/servicios_service.dart';

class ServicioFormView extends StatefulWidget {
  final Map<String, dynamic>? servicio; // null = crear, !=null = editar
  const ServicioFormView({super.key, this.servicio});

  @override
  State<ServicioFormView> createState() => _ServicioFormViewState();
}

class _ServicioFormViewState extends State<ServicioFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _duracionController = TextEditingController();
  final _precioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.servicio != null) {
      _nombreController.text = widget.servicio!['nombre'] ?? '';
      _descripcionController.text = widget.servicio!['descripcion'] ?? '';
      _duracionController.text =
          widget.servicio!['duracion_minutos']?.toString() ?? '';
      _precioController.text =
          widget.servicio!['precio']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _duracionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final serviciosService = ServiciosService(authController.token!);
    final isEdit = widget.servicio != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Editar Servicio" : "Nuevo Servicio"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildField("Nombre", _nombreController),
              _buildField("Descripción", _descripcionController),
              _buildField("Duración (minutos)", _duracionController,
                  keyboard: TextInputType.number),
              _buildField("Precio", _precioController,
                  keyboard: TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      if (isEdit) {
                        await serviciosService.editar(
                          id: widget.servicio!['id'],
                          nombre: _nombreController.text,
                          descripcion: _descripcionController.text,
                          duracion: int.tryParse(_duracionController.text),
                          precio: double.tryParse(_precioController.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Servicio actualizado con éxito")),
                        );
                      } else {
                        await serviciosService.crear(
                          nombre: _nombreController.text,
                          descripcion: _descripcionController.text,
                          duracion: int.parse(_duracionController.text),
                          precio: double.parse(_precioController.text),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Servicio creado con éxito")),
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
                child: Text(isEdit ? "Guardar cambios" : "Crear servicio"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
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
