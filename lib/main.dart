// lib/main.dart
import 'package:flutter/material.dart';
import 'views/auth/login_view.dart';

void main() {
  runApp(const StylApp());
}

class StylApp extends StatelessWidget {
  const StylApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StylApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const LoginView(),
    );
  }
}