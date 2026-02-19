import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/visits_repository.dart';

class SellerProfileScreen extends ConsumerWidget {
  const SellerProfileScreen({super.key});

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
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final visitsAsync = ref.watch(userVisitsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TARJETA DE IDENTIFICACIÓN ---
              userProfileAsync.when(
                data: (user) {
                  final name = user?['name'] ?? 'Usuario';
                  final uid = user?['uid'] ?? '...';
                  final shortId = uid.length > 4 ? uid.substring(uid.length - 4).toUpperCase() : uid;
                  
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryColor.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0xFFE0F2F1),
                                child: Icon(Icons.person, size: 35, color: AppTheme.primaryColor),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                  const Text("Vendedor de Campo", style: TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
                                    child: Text("ID: V-$shortId", style: const TextStyle(color: Colors.white, fontSize: 10)),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 25),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 15),
                        
                        // ESTADÍSTICAS DEL HEADER
                        visitsAsync.when(
                          data: (visits) {
                            final total = visits.length;
                            final uniqueClients = visits.map((v) => v['clientName']).toSet().length;
                            
                            // SUMA REAL DE PUNTOS (Traídos de Firebase)
                            final totalPoints = visits.fold<int>(0, (sum, visit) {
                              final p = visit['points'];
                              return sum + (p is int ? p : 0);
                            });

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildHeaderStat("$total", "Visitas"),
                                _buildVerticalLine(),
                                _buildHeaderStat("$uniqueClients", "PDVs"),
                                _buildVerticalLine(),
                                _buildHeaderStat("$totalPoints", "Puntos"),
                              ],
                            );
                          },
                          loading: () => const SizedBox(),
                          error: (_,__) => const SizedBox(),
                        )
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_,__) => const SizedBox(),
              ),

              const SizedBox(height: 25),

              // --- RENDIMIENTO SEMANAL ---
              const Text("Tu Rendimiento", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              const SizedBox(height: 15),

              visitsAsync.when(
                data: (visits) {
                   final now = DateTime.now();
                   final thisMonthVisits = visits.where((v) {
                    DateTime? date;

                    // Intentamos leer la fecha nueva (Timestamp)
                     if (v['createdAt'] != null && v['createdAt'] is Timestamp) {
                       date = (v['createdAt'] as Timestamp).toDate();
                     } 
                     //  Si no existe, intentamos leer la fecha vieja (String)
                     else if (v['date'] != null) {
                       try {
                         date = DateTime.parse(v['date'].toString());
                       } catch (e) {
                         return false; // Fecha inválida
                       }
                     }

                     // Si no encontramos fecha, no cuenta para el mes
                     if (date == null) return false;

                     // Verificamos si es este mes y este año
                     return date.month == now.month && date.year == now.year;
                   }).length;

                   final total = visits.length;
                   final completed = visits.where((v) => v['status'] == 'completed').length;
                   final efficiency = total == 0 ? 0 : ((completed / total) * 100).toInt();

                   return Column(
                     children: [
                       Container(
                         padding: const EdgeInsets.all(20),
                         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Row(
                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                               children: [
                                 const Text("Tasa de Cumplimiento", style: TextStyle(fontWeight: FontWeight.bold)),
                                 Text("$efficiency%", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                               ],
                             ),
                             const SizedBox(height: 10),
                             ClipRRect(
                               borderRadius: BorderRadius.circular(10),
                               child: LinearProgressIndicator(
                                 value: efficiency / 100,
                                 minHeight: 10,
                                 backgroundColor: Colors.green.withOpacity(0.1),
                                 color: Colors.green,
                               ),
                             ),
                           ],
                         ),
                       ),
                       const SizedBox(height: 15),
                       _buildStatRowCard(Icons.calendar_month, "Visitas este mes", "$thisMonthVisits realizadas", Colors.blue),
                     ],
                   );
                },
                loading: () => const SizedBox(),
                error: (_,__) => const SizedBox(),
              ),

              const SizedBox(height: 30),

              // --- COMUNICACIÓN Y CUENTA ---
              const Text("Cuenta y Comunicación", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              const SizedBox(height: 15),

              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      Icons.chat_outlined, 
                      "Mensajes del Admin", 
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                        child: const Text("1 Nuevo", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildSettingsTile(Icons.lock_outline, "Cambiar Contraseña"),
                    const Divider(height: 1, indent: 50),
                    _buildSettingsTile(Icons.help_outline, "Ayuda y Soporte"),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              
              // CERRAR SESIÓN
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
            ],
          ),
        ),
      ),
    );
  }

  // WIDGETS DE DISEÑO
  Widget _buildHeaderStat(String value, String label) => Column(
    children: [Text(value, style: const TextStyle(
      fontSize: 24, fontWeight: FontWeight.bold, 
      color: Colors.white)), Text(label, 
      style: const TextStyle(fontSize: 12, color: Colors.white70))]
    );
  Widget _buildVerticalLine() => Container(height: 30, width: 1, color: Colors.white24);
  Widget _buildStatRowCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, 
      borderRadius: BorderRadius.circular(15), 
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), 
      blurRadius: 5)]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText))]))
      ]),
    );
  }
  Widget _buildSettingsTile(IconData icon, String title, {Widget? trailing}) => ListTile(leading: Icon(icon, 
    color: AppTheme.primaryColor), 
    title: Text(title, style: const TextStyle(
      fontWeight: FontWeight.w500)),
       trailing: trailing ?? const Icon(Icons.chevron_right, 
       color: Colors.grey), onTap: () {});
}