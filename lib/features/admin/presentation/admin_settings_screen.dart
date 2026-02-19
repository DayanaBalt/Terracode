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

//ENVIAR MENSAJE MASIVO (GLOBAL)
  void _showGlobalMessageDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController(text: "Orientación General");
    final bodyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Mensaje a Todos"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Este mensaje le llegará a TODOS los vendedores en campo.", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 15),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Título del Mensaje", border: OutlineInputBorder())),
              const SizedBox(height: 10),
              TextField(controller: bodyCtrl, decoration: const InputDecoration(labelText: "Contenido", border: OutlineInputBorder()), maxLines: 3),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: Colors.grey))),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
              onPressed: () async {
                if (bodyCtrl.text.isEmpty) return;
                
                // Cerramos el cuadro y mostramos que está cargando
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enviando orientaciones a todos...")));

                // Disparamos la función masiva
                await ref.read(adminRepositoryProvider).sendGlobalNotification(
                  titleCtrl.text, 
                  bodyCtrl.text
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Mensaje enviado exitosamente!"), backgroundColor: Colors.green));
                }
              }, 
              icon: const Icon(Icons.send, size: 16),
              label: const Text("Enviar a Todos")
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    
    // Conteo real de vendedores
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
                  color: const Color(0xFF004D40), 
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF004D40).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: userProfileAsync.when(
                  data: (user) {
                    final name = user?['name'] ?? 'Usuario';
                    final email = user?['email'] ?? 'Sin correo';
                    final uid = user?['uid'] ?? '---';
                    // Toma los últimos 4 caracteres del ID  (ej: ID: ...A82B)
                    final shortId = uid.length > 4 ? uid.substring(uid.length - 4).toUpperCase() : uid;

                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.shield_outlined, color: Colors.white, size: 35),
                        ),
                        const SizedBox(width: 20),
                        Expanded( // Usa Expanded para evitar error si el correo es muy largo
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

              // --- SECCIÓN DE COMUNICACIÓN Y CONFIGURACIÓN ---
              const Text("Comunicación y Sistema", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              const SizedBox(height: 15),
              
              // BOTÓN DE NOTIFICACIONES
              _buildSettingsOption(
                icon: Icons.notifications_active, 
                title: "Notificaciones", 
                subtitle: "Mensaje masivo a todos los vendedores",
                onTap: () => _showGlobalMessageDialog(context, ref)
              ),
              _buildSettingsOption(icon: Icons.lock_outline, title: "Seguridad y privacidad"),
              _buildSettingsOption(icon: Icons.description_outlined, title: "Términos y condiciones"),

              const SizedBox(height: 25),

              // SECCIÓN DE GESTIÓN 
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
                        onPressed: () {},
                        child: const Text("Administrar Permisos"),
                      ),
                    ),
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
              const Center(child: Text("TerraCode v1.0.0", style: TextStyle(color: Colors.grey, fontSize: 10))),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET MEJORADO PARA ACEPTAR CLICS
  Widget _buildSettingsOption({
    required IconData icon, 
    required String title, 
    String? subtitle,
    Widget? trailing, 
    VoidCallback? onTap
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: AppTheme.primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap ?? () {},
      ),
    );
  }
}