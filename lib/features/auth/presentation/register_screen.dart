// Pantalla de Registro

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input.dart';
import '../data/auth_repository.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;

  void _register() async {
    setState(() => isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signUp(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
        name: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
      );

      await FirebaseAuth.instance.signOut(); 

     if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Cuenta creada! Por favor inicia sesión.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

 @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          Positioned(
            top: -size.width * 0.1,
            right: -size.width * 0.1,
            child: Opacity(
              opacity: 0.1,
              child: Icon(Icons.public, size: size.width * 0.7, color: Colors.white),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      const SizedBox(height: 10),
                      const Text('Crear Cuenta', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                      const Text('Únete a la comunidad de TerraCode', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                
                // Formulario
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppTheme.lightBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          CustomInput(controller: nameCtrl, hintText: 'Nombre Completo', icon: Icons.person_outline),
                          CustomInput(controller: emailCtrl, hintText: 'Correo Electrónico', icon: Icons.email_outlined),
                          CustomInput(controller: phoneCtrl, hintText: 'Teléfono', icon: Icons.phone_android_outlined),
                          CustomInput(controller: passCtrl, hintText: 'Contraseña', icon: Icons.lock_outline, isPassword: true),
                          
                          const SizedBox(height: 30),
                          
                          CustomButton(text: 'Registrarse', isLoading: isLoading, onPressed: _register),
                          
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("¿Ya tienes cuenta? "),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text('Inicia Sesión', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}