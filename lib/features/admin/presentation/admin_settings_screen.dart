import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/admin_repository.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. CONEXIÓN REAL: Escuchamos quién es el usuario actual
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    
    // También escuchamos el conteo real de vendedores
    final sellersAsync = ref.watch(sellersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER DE PERFIL REAL ---
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF004D40), // Verde Corporativo
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF004D40).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: userProfileAsync.when(
                  data: (user) {
                    // AQUÍ OBTENEMOS LOS DATOS REALES
                    final name = user?['name'] ?? 'Usuario';
                    final email = user?['email'] ?? 'Sin correo';
                    final uid = user?['uid'] ?? '---';
                    // Tomamos los últimos 4 caracteres del ID para que se vea profesional (ej: ID: ...A82B)
                    final shortId = uid.length > 4 ? uid.substring(uid.length - 4).toUpperCase() : uid;

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 35),
                        ),
                        const SizedBox(width: 20),
                        Expanded( // Usamos Expanded para evitar error si el correo es muy largo
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              Text(email, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                child: Text("ID: ...$shortId", style: const TextStyle(color: Colors.white70, fontSize: 10)),
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                  error: (_,__) => const Text("Error cargando perfil", style: TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 30),

              // SECCIÓN DE CONFIGURACIÓN
              const Text("Configuración", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              const SizedBox(height: 15),
              
              _buildSettingsOption(Icons.notifications_outlined, "Notificaciones", trailing: _notificationBadge(3)),
              _buildSettingsOption(Icons.lock_outline, "Seguridad y privacidad"),
              _buildSettingsOption(Icons.description_outlined, "Términos y condiciones"),

              const SizedBox(height: 30),

              // SECCIÓN DE GESTIÓN (Datos Reales)
              const Text("Gestión de Usuarios", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              const SizedBox(height: 15),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total de vendedores", style: TextStyle(color: Colors.grey)),
                        // CONTADOR REAL DE LA BASE DE DATOS
                        sellersAsync.when(
                          data: (s) => Text("${s.length}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          loading: () => const Text("-"),
                          error: (_,__) => const Text("0"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Navegar a gestión de permisos
                        },
                        child: const Text("Administrar Permisos"),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // BOTÓN CERRAR SESIÓN
              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton.icon(
                  onPressed: () => _signOut(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red[50],
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text("Cerrar Sesión", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              
              const SizedBox(height: 20),
              // Versión de la app (Esto sí puede ser estático o venir de un config file)
              const Center(child: Text("TerraCode v1.0.0", style: TextStyle(color: Colors.grey, fontSize: 10))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption(IconData icon, String title, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  Widget _notificationBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
      child: Text("$count", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}