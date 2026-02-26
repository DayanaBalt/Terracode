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
    // Obtenemos los datos sin interrumpir el dibujo de la pantalla
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final visitsAsync = ref.watch(userVisitsProvider);

    final userName = userProfileAsync.value?['name'] ?? 'Cargando...';
    final visits = visitsAsync.value ?? [];

    final completedVisits = visits.where((v) => v['status'] == 'completed').toList();
    final totalAssigned = visits.length;
    final totalCompleted = completedVisits.length;
    final totalPhotos = completedVisits.where((v) => v['photoUrl'] != null).length;
    final compliance = totalAssigned == 0 ? 0 : ((totalCompleted / totalAssigned) * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Avatar circular
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                          radius: 22,
                          child: const Icon(Icons.person, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName, 
                                style: const TextStyle(color: AppTheme.darkText, fontSize: 17, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Text("Vendedor de Campo", style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Etiqueta de la fecha suave
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1), 
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      DateFormat('dd MMM').format(DateTime.now()), 
                      style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                  )
                ],
              ),
              
              const SizedBox(height: 25),
              
              // --- Títulos ---
              const Text("Historial de Visitas", style: TextStyle(color: AppTheme.darkText, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text("Registro de tus visitas realizadas", style: TextStyle(color: Colors.grey, fontSize: 14)),
              
              const SizedBox(height: 20),

              // TARJETA DE ESTADÍSTICAS FLOTANTE
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF004D40),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF004D40).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: visitsAsync.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem("$totalCompleted", "Total visitas"),
                        _buildVerticalDivider(),
                        _buildStatItem("$totalPhotos", "Fotos"),
                        _buildVerticalDivider(),
                        _buildStatItem("$compliance%", "Cumplimiento"),
                      ],
                    ),
              ),

              const SizedBox(height: 25),

              // LISTA DE VISITAS 
              visitsAsync.when(
                data: (_) {
                  if (completedVisits.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            Icon(Icons.history, size: 50, color: Colors.grey[300]),
                            const SizedBox(height: 10),
                            const Text("No hay historial disponible", style: TextStyle(color: Colors.grey, fontSize: 15)),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), 
                    itemCount: completedVisits.length,
                    itemBuilder: (context, index) {
                      return _buildHistoryCard(completedVisits[index]);
                    },
                  );
                },
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
                error: (e, s) => Text("Error: $e"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.white.withOpacity(0.2));
  }

  Widget _buildHistoryCard(Map<String, dynamic> visit) {
    String dateStr = "Hoy";
    String durationStr = "-- min";
    bool hasPhoto = visit['photoUrl'] != null && visit['photoUrl'].toString().isNotEmpty;

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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white, 
              shape: BoxShape.circle, 
              border: Border.all(color: Colors.green, width: 2)
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 18),
          ),
          const SizedBox(width: 15),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visit['clientName'] ?? 'Cliente', style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.darkText)),
                const SizedBox(height: 4),
                Text(visit['address'] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                
                const SizedBox(height: 14),
                
                Row(
                  children: [
                    _buildSmallIconInfo(Icons.calendar_today_outlined, dateStr),
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
      children: [
        Icon(icon, size: 15, color: Colors.grey[400]), 
        const SizedBox(width: 5), 
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500))
      ]
    );
  }
}