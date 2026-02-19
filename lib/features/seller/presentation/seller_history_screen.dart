import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../data/visits_repository.dart';

class SellerHistoryScreen extends ConsumerWidget {
  const SellerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final visitsAsync = ref.watch(userVisitsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SingleChildScrollView( // Scroll para pantallas pequeñas
        child: Column(
          children: [
            // --- ENCABEZADO VERDE ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  // Perfil Mini
                  userProfileAsync.when(
                    data: (user) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?['name'] ?? 'Vendedor', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                const Text("Vendedor de Campo", style: TextStyle(color: Colors.white70, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                          child: Text(DateFormat('dd MMM').format(DateTime.now()), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    loading: () => const SizedBox(height: 40),
                    error: (_,__) => const SizedBox(),
                  ),

                  const SizedBox(height: 25),
                  const Align(alignment: Alignment.centerLeft, child: Text("Historial de Visitas", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 5),
                  const Align(alignment: Alignment.centerLeft, child: Text("Registro completo de tus visitas realizadas", style: TextStyle(color: Colors.white70, fontSize: 12))),
                  const SizedBox(height: 20),

                  // TARJETA DE ESTADÍSTICAS REALES
                  visitsAsync.when(
                    data: (visits) {
                      // CÁLCULOS REALES
                      final totalAssigned = visits.length;
                      final completed = visits.where((v) => v['status'] == 'completed').toList();
                      final totalCompleted = completed.length;
                      final totalPhotos = completed.where((v) => v['photoUrl'] != null).length;
                      
                      // Porcentaje 
                      final compliance = totalAssigned == 0 ? 0 : ((totalCompleted / totalAssigned) * 100).toInt();

                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004D40), 
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem("$totalCompleted", "Total visitas"),
                            _buildVerticalDivider(),
                            _buildStatItem("$totalPhotos", "Fotos"),
                            _buildVerticalDivider(),
                            _buildStatItem("$compliance%", "Cumplimiento"),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox(height: 80),
                    error: (_,__) => const SizedBox(),
                  ),
                ],
              ),
            ),

            // --- LISTA DE VISITAS ---
            visitsAsync.when(
              data: (visits) {
                final completedVisits = visits.where((v) => v['status'] == 'completed').toList();
                
                if (completedVisits.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Text("No hay historial disponible", style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: completedVisits.length,
                  itemBuilder: (context, index) {
                    final visit = completedVisits[index];
                    return _buildHistoryCard(visit);
                  },
                );
              },
              loading: () => const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
              error: (e, s) => Padding(padding: EdgeInsets.all(20), child: Text("Error: $e")),
            ),
          ],
        ),
      ),
    );
  }

  // WIDGETS AUXILIARES
  Widget _buildStatItem(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ]);
  }

  Widget _buildVerticalDivider() => Container(height: 30, width: 1, color: Colors.white24);

  Widget _buildHistoryCard(Map<String, dynamic> visit) {
    // LÓGICA DE TIEMPO REAL
    String dateStr = "Hoy";
    String durationStr = "-- min";
    bool hasPhoto = visit['photoUrl'] != null;

    if (visit['endTime'] != null) {
      final end = (visit['endTime'] as Timestamp).toDate();
      dateStr = DateFormat('yyyy-MM-dd').format(end); 

      if (visit['startTime'] != null) {
        final start = (visit['startTime'] as Timestamp).toDate();
        final duration = end.difference(start);
        
        if (duration.inMinutes < 1) {
          durationStr = "${duration.inSeconds} seg";
        } else {
          durationStr = "${duration.inMinutes} min";
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.green, width: 2)),
            child: const Icon(Icons.check, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visit['clientName'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText)),
                Text(visit['address'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildSmallIconInfo(Icons.calendar_today, dateStr),
                    const SizedBox(width: 15),
                    _buildSmallIconInfo(Icons.access_time, durationStr),
                    const SizedBox(width: 15),
                    _buildSmallIconInfo(Icons.camera_alt_outlined, hasPhoto ? "1" : "0"),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallIconInfo(IconData icon, String text) {
    return Row(
      children: [Icon(
        icon, size: 14, 
        color: Colors.grey), 
        const SizedBox(width: 4), 
        Text(text, style: 
          const TextStyle(fontSize: 11, color: Colors.grey))]
    );
  }
}