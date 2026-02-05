import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/visits_repository.dart';
import 'visit_detail_screen.dart';

class SellerHomeScreen extends ConsumerWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //  Escuchamos los datos de Firebase
    final visitsAsyncValue = ref.watch(userVisitsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      // Usamos .when para que TODA la pantalla dependa de los datos
      body: visitsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (visits) {
          // Contamos cuántas visitas hay de cada tipo
          final pendingCount = visits.where((v) => v['status'] == 'pending').length;
          final completedCount = visits.where((v) => v['status'] == 'completed').length;

          return Column(
            children: [
              _buildHeader(),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // TARJETAS 
                      Row(
                        children: [
                          _buildSummaryCard(
                            pendingCount.toString(),
                            'Pendientes', 
                            Icons.access_time, 
                            Colors.orange
                          ),
                          const SizedBox(width: 15),
                          _buildSummaryCard(
                            completedCount.toString(),
                            'Completadas', 
                            Icons.check_circle_outline, 
                            Colors.green
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 25),
                      const Text("Ruta de Hoy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                      const SizedBox(height: 15),

                      // LISTA DE VISITAS
                      if (visits.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(30),
                          alignment: Alignment.center,
                          child: const Text("No tienes rutas asignadas hoy 😴", style: TextStyle(color: Colors.grey)),
                        )
                      else
                        Column(
                          children: visits.map((visit) {
                            return _buildVisitCard(
                              context,
                              visitId: visit['id'],
                              title: visit['clientName'] ?? 'Sin Nombre',
                              address: visit['address'] ?? 'Sin Dirección',
                              isUrgent: visit['isUrgent'] ?? false,
                              status: visit['status'],
                              iconColor: visit['status'] == 'completed' ? Colors.green : AppTheme.primaryColor,
                            );
                          }).toList(),
                        ),
                      
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGETS AUXILIARES  ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(Icons.person, color: AppTheme.primaryColor, size: 30)),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hola Vendedor', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Text('Tu ruta está lista', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String count, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(count, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, {
    required String visitId,
    required String title,
    required String address,
    bool isUrgent = false,
    String? status,
    required Color iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VisitDetailScreen(
            visitId: visitId,
            clientName: title, 
            address: address,
            status: status ?? 'pending',
          )),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.location_on, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Text('Urgente', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(address, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (status == 'completed')
               const Icon(Icons.check_circle, color: Colors.green)
            else
               const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}