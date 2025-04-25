import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';

// This is a standalone test file for the splash screen
// Run this with: flutter run -t lib/test_splash.dart

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acer Splash Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF83B81A), // Acer green
      ),
      home: const SplashScreen(),
    );
  }
}
