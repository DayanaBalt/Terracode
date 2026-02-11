import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/admin_repository.dart';

class AdminHomeDashboard extends ConsumerWidget {
  const AdminHomeDashboard({super.key});
// 1. Calcular tiempo promedio 
  String _calculateAverageTime(List<Map<String, dynamic>> visits) {
    int totalSeconds = 0; 
    int completedCount = 0;

    for (var visit in visits) {
      if (visit['status'] == 'completed' && visit['startTime'] != null && visit['endTime'] != null) {
        try {
          final start = (visit['startTime'] as Timestamp).toDate();
          final end = (visit['endTime'] as Timestamp).toDate();
          
          // Sumamos la diferencia exacta en SEGUNDOS
          totalSeconds += end.difference(start).inSeconds;
          completedCount++;
        } catch (e) {
          print("Error calculando tiempo: $e");
        }
      }
    }

    if (completedCount == 0) return "0m";
    final averageSeconds = totalSeconds ~/ completedCount;

    // VISUALIZACIÓN INTELIGENTE
    if (averageSeconds < 60) {
      return "${averageSeconds}s"; 
    } else {
      return "${averageSeconds ~/ 60}m"; 
    }
  }

  // Contar vendedores (Activos)
  int _countActiveSellers(List<Map<String, dynamic>> visits) {
    // Lista sin repetidos de los IDs de vendedores en las visitas
    final uniqueSellers = visits.map((v) => v['sellerId']).toSet();
    return uniqueSellers.length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allVisitsAsync = ref.watch(allCompanyVisitsProvider);
    final sellersAsync = ref.watch(sellersListProvider); // Solo para el total de registrados

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER CON DATOS REALES DEL ADMIN
              _buildHeaderCard(),
              
              const SizedBox(height: 25),
              const Text("Métricas del Día", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              const SizedBox(height: 15),

              // SECCIÓN DE DATOS
              allVisitsAsync.when(
                data: (visits) {
                  // CÁLCULOS EN TIEMPO REAL
                  final totalVisits = visits.length;
                  final completed = visits.where((v) => v['status'] == 'completed').length;
                  final activeSellers = _countActiveSellers(visits);
                  
                  // Eficiencia
                  final efficiency = totalVisits == 0 ? 0 : ((completed / totalVisits) * 100).toInt();
                  
                  // Tiempo Promedio Real
                  final averageTime = _calculateAverageTime(visits);

                  return Column(
                    children: [
                      Row(
                        children: [
                          // Comparamos Vendedores Activos vs Registrados
                          sellersAsync.when(
                            data: (s) => _buildStatCard(
                              Icons.people_outline, 
                              "$activeSellers / ${s.length}", 
                              "Vendedores activos"
                            ),
                            loading: () => _buildStatCard(Icons.people_outline, "-", "Cargando..."),
                            error: (_,__) => _buildStatCard(Icons.people_outline, "0", "Vendedores"),
                          ),
                          const SizedBox(width: 15),
                          _buildStatCard(Icons.check_circle_outline, "$completed", "Visitas completadas"),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          _buildStatCard(
                            Icons.trending_up, 
                            "$efficiency%", 
                            "Eficiencia Global",
                            colorOverride: efficiency > 80 ? Colors.green : (efficiency < 50 ? Colors.red : Colors.orange)
                          ),
                          const SizedBox(width: 15),
                          _buildStatCard(Icons.access_time, averageTime, "Duración promedio"),
                        ],
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(10)),
                  child: Text("Error cargando estadísticas: $e", style: const TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(height: 30),

              // LISTA DE ACTIVIDAD
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Actividad Reciente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                  TextButton(onPressed: (){}, child: const Text("Ver todo")),
                ],
              ),
              
              _buildRecentActivityList(allVisitsAsync),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS UI ---
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF004D40),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF004D40).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Panel de Control", style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text("Administrador", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.notifications_none, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, {Color? colorOverride}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.lightBackground, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(height: 15),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorOverride ?? AppTheme.darkText)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList(AsyncValue<List<Map<String, dynamic>>> visitsAsync) {
    return visitsAsync.when(
      data: (visits) {
        if (visits.isEmpty) return const Padding(padding: EdgeInsets.all(20), child: Text("No hay visitas registradas hoy."));
        
        // Mostramos solo las últimas 5
        return Column(
          children: visits.take(5).map((visit) {
            final isCompleted = visit['status'] == 'completed';
            
            // Intentamos formatear la hora si existe
            String timeString = "";
            if (visit['date'] != null) {
               // Manejo simple de la fecha para mostrar hora
               try {
                 DateTime d = DateTime.parse(visit['date']); 
                 timeString = "${d.hour}:${d.minute.toString().padLeft(2,'0')}";
               } catch(e) {
                 timeString = "Hoy";
               }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isCompleted ? Colors.green[50] : Colors.orange[50],
                    child: Icon(
                      isCompleted ? Icons.check : Icons.timer, 
                      color: isCompleted ? Colors.green : Colors.orange, 
                      size: 20
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(visit['clientName'] ?? 'Cliente Desconocido', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(visit['address'] ?? 'Sin dirección', style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(timeString, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      Text(
                        isCompleted ? "Finalizado" : "En ruta",
                        style: TextStyle(
                          color: isCompleted ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox(),
      error: (_,__) => const SizedBox(),
    );
  }
}