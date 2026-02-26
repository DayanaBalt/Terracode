import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Configura un temporizador para navegar al Login después de segundos
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      body: Center(
        child: Image.asset(
          'assets/images/splash_screen.png.png', 
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width * 0.8, 
        ),
      ),
    );
  }
}