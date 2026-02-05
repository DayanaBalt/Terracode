import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input.dart';
import '../data/auth_repository.dart';
import 'register_screen.dart';
import '../../auth/presentation/check_role_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLoading = false;

  // LA LÓGICA DE ENTRAR
  void _login() async {
    setState(() => isLoading = true); // Ruedita de carga
    try {
      // Llamamos a Firebase para entrar
      await ref.read(authRepositoryProvider).signIn(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CheckRoleScreen()),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          Positioned(
            top: -size.width * 0.1,
            right: -size.width * 0.1,
            child: Opacity(
              opacity: 0.15,
              child: Icon(Icons.public, size: size.width * 0.7, color: Colors.white),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: AppTheme.secondaryColor, size: 30),
                          SizedBox(width: 8),
                          Text('TerraCode', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('¡Hola!', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)),
                      const Text('Bienvenido a tu red de localización', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
                
                // FORMULARIO 
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
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Login', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          const SizedBox(height: 25),
                          
                          CustomInput(controller: emailCtrl, hintText: 'Correo Electrónico', icon: Icons.email_outlined),
                          CustomInput(controller: passCtrl, hintText: 'Contraseña', icon: Icons.lock_outline, isPassword: true),
                          
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.blueGrey)),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          CustomButton(
                            text: 'Entrar',
                            isLoading: isLoading,
                            onPressed: _login,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("¿No tienes cuenta? ", style: TextStyle(fontSize: 14)),
                              GestureDetector(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                                child: const Text('Regístrate', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                              ),
                            ],
                          ),
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