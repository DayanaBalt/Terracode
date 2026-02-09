// Pantalla que muestra la vista de cada usuario (Reporte del Vendedor)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/admin_repository.dart'; 

class AdminSellerDetailScreen extends ConsumerWidget {
  // Datos que recibimos al dar clic en la lista
  final String sellerId;
  final String sellerName;
  final String sellerEmail;

 const AdminSellerDetailScreen({
    super.key,
    required this.sellerId,
    required this.sellerName,
    required this.sellerEmail,
  });

 @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsync = ref.watch(sellerVisitsProvider(sellerId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(title: const Text("Reporte de Vendedor"), backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // PERFIL
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const CircleAvatar(radius: 30, backgroundColor: AppTheme.lightBackground, child: Icon(Icons.person, size: 40, color: AppTheme.primaryColor)),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sellerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(sellerEmail, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 25),

            visitsAsync.when(
              data: (visits) {
                final completed = visits.where((v) => v['status'] == 'completed').length;
                final pending = visits.where((v) => v['status'] == 'pending' || v['status'] == 'in_progress').length;
                
                //  lista SOLO con las completadas para el historial de abajo
                final completedVisitsHistory = visits.where((v) => v['status'] == 'completed').toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ESTADÍSTICAS
                    const Text("Rendimiento Hoy", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatCard(completed.toString(), "Completadas", Icons.check_circle, Colors.green),
                        const SizedBox(width: 15),
                        _buildStatCard(pending.toString(), "Pendientes", Icons.access_time, Colors.orange),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // LISTA DE VISITAS CON FOTOS
                    const Text("Historial de Visitas Completa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    
                    // lista filtrada 
                    if (completedVisitsHistory.isEmpty) 
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("Este vendedor no ha completado visitas hoy.", style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        // lista filtrada
                        itemCount: completedVisitsHistory.length, 
                        itemBuilder: (context, index) {
                          final visit = completedVisitsHistory[index]; 
                          final hasPhoto = visit['photoUrl'] != null;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(visit['clientName'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    // Chip de estado
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: visit['status'] == 'completed' ? Colors.green[50] : Colors.orange[50],
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Text(
                                        visit['status'] == 'completed' ? 'Completado' : 'Pendiente',
                                        style: TextStyle(
                                          fontSize: 10, 
                                          fontWeight: FontWeight.bold,
                                          color: visit['status'] == 'completed' ? Colors.green : Colors.orange
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(visit['address'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                
                                // SI HAY FOTO, LA MOSTRAMOS
                                if (hasPhoto) ...[
                                  const SizedBox(height: 15),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      visit['photoUrl'],
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (c, child, loading) {
                                        if (loading == null) return child;
                                        return Container(height: 150, color: Colors.grey[200], child: const Center(child: CircularProgressIndicator()));
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text("Evidencia fotográfica adjunta", style: TextStyle(fontSize: 10, color: Colors.grey)),
                                ]
                              ],
                            ),
                          );
                        },
                      )
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text("Error: $e"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}