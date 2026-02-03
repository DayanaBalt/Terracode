import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'core/constants/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TerraCode',
      theme: AppTheme.theme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // ... ¡Lo dejamos pasar!
            // AQUÍ IRÁ DASHBOARD (Admin o Vendedor).
            // Por ahora ponemos un texto temporal para probar que funciona.
           return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¡BIENVENIDO! Estás dentro del sistema."),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Esta línea cierra la sesión en Firebase
                        FirebaseAuth.instance.signOut();
                      },
                      child: const Text("Cerrar Sesión (Temporal)"),
                    ),
                  ],
                ),
              ),
            );
          }
          
          return const LoginScreen();
        },
      ),
    );
  }
}