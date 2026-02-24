import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/admin_repository.dart';

class AdminPermissionsScreen extends ConsumerWidget {
  const AdminPermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersListProvider);
    final myUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Gestión de Permisos y Roles", style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: usersAsync.when(
        data: (users) {
          // Filtramos para no mostrar al propio administrador logueado (para evitar autobloqueo)
          final otherUsers = users.where((u) => u['uid'] != myUid).toList();

          if (otherUsers.isEmpty) return const Center(child: Text("No hay otros usuarios registrados."));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: otherUsers.length,
            itemBuilder: (context, index) {
              final user = otherUsers[index];
              final String name = user['name'] ?? 'Sin Nombre';
              final String email = user['email'] ?? 'Sin correo';
              final String uid = user['uid'];
              final String role = user['role'] ?? 'seller';
              final bool isActive = user['isActive'] ?? true;

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  border: Border.all(color: isActive ? Colors.transparent : Colors.red.withOpacity(0.5), width: 1.5)
                ),
                child: Column(
                  children: [
                    // Datos del usuario
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isActive ? const Color(0xFFE0F2F1) : Colors.red[50],
                          child: Icon(isActive ? Icons.person : Icons.block, color: isActive ? AppTheme.primaryColor : Colors.red),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: TextStyle(fontWeight: FontWeight.bold,
                               color: isActive ? AppTheme.darkText : Colors.red,
                                decoration: isActive ? TextDecoration.none : TextDecoration.lineThrough)),
                              Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 25),
                    
                    // Controles de Rol y Acceso
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // SELECTOR DE ROL
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: role == 'admin' ? 'admin' : 'seller',
                                isExpanded: true,
                                icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryColor),
                                items: const [
                                  DropdownMenuItem(value: 'seller', child: Text("Vendedor", style: TextStyle(fontSize: 14))),
                                  DropdownMenuItem(value: 'admin', child: Text("Administrador", style: TextStyle(fontSize: 14,
                                   color: AppTheme.primaryColor, fontWeight: FontWeight.bold))),
                                ],
                                onChanged: (newRole) async {
                                  if (newRole != null && newRole != role) {
                                    await ref.read(adminRepositoryProvider).updateUserRole(uid, newRole);
                                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Rol de $name actualizado a $newRole")));
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        
                        // SWITCH DE BLOQUEO
                        Column(
                          children: [
                            Text(isActive ? "Activo" : "Bloqueado", style: TextStyle(fontSize: 10, color: isActive ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                            Switch(
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.red,
                              inactiveTrackColor: Colors.red.withOpacity(0.2),
                              value: isActive,
                              onChanged: (val) async {
                                await ref.read(adminRepositoryProvider).toggleUserAccess(uid, isActive);
                              },
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }
}