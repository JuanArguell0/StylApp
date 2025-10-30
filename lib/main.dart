import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Controladores
import 'controllers/auth_controller.dart';

// Vistas de autenticación
import 'views/auth/login_view.dart';
import 'views/auth/register_view.dart';

// Router inteligente por rol
import 'views/router/role_router.dart';

void main() {
  runApp(const StylApp());
}

class StylApp extends StatelessWidget {
  const StylApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'StylApp Barbería',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.amber.shade600,
          scaffoldBackgroundColor: const Color(0xFF121212),
          colorScheme: ColorScheme.dark(
            primary: Colors.amber.shade600,
            secondary: Colors.amber.shade400,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade900,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            labelStyle: const TextStyle(color: Colors.white70),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterView(),
          '/home': (context) => const RoleRouter(), // 🚀 Router inteligente
        },
      ),
    );
  }
}
