import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cut, size: 80, color: Colors.amber.shade600),
              const SizedBox(height: 16),
              Text(
                "Crear Cuenta",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade600,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 32),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nombre completo
                    TextFormField(
                      controller: _nombreController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Nombre completo", Icons.person),
                      validator: (value) =>
                          value!.isEmpty ? "Ingrese su nombre" : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Correo electrónico", Icons.email),
                      validator: (value) =>
                          value!.isEmpty ? "Ingrese su correo" : null,
                    ),
                    const SizedBox(height: 16),

                    // Teléfono
                    TextFormField(
                      controller: _telefonoController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Teléfono", Icons.phone),
                      validator: (value) =>
                          value!.isEmpty ? "Ingrese su teléfono" : null,
                    ),
                    const SizedBox(height: 16),

                    // Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Contraseña", Icons.lock),
                      validator: (value) =>
                          value!.isEmpty ? "Ingrese su contraseña" : null,
                    ),
                    const SizedBox(height: 24),

                    // Botón de registro
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade600,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: authController.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final success = await authController.register(
                                    nombre: _nombreController.text.trim(),
                                    email: _emailController.text.trim(),
                                    telefono: _telefonoController.text.trim(),
                                    contrasena: _passwordController.text.trim(),
                                  );
                                  if (success && mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Registro exitoso"),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context); // volver al login
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(authController.errorMessage ??
                                            "Error en registro"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        child: authController.isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                                "Registrarse",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Link a login
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "¿Ya tienes cuenta? Inicia sesión",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.grey.shade900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
