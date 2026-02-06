// Pantalla que muestra la vista de cada usuario

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
    // Apuntando al ID de este vendedor específico
    final visitsAsync = ref.watch(sellerVisitsProvider(sellerId));

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Reporte de Vendedor", style: TextStyle(color: AppTheme.darkText, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // TARJETA DE PERFIL (Encabezado) 
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.lightBackground,
                    child: Icon(Icons.person, size: 35, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sellerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(sellerEmail, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 8),
                        // Estado en línea (Simulado)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                          child: const Text("● Activo", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // SECCIÓN DE MÉTRICAS
            const Align(alignment: Alignment.centerLeft, child: Text("Estadísticas del día", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const SizedBox(height: 15),

          visitsAsync.when(
              data: (visits) {
                // rutas terminadas
                final completed = visits.where((v) => v['status'] == 'completed').length;
                // rutas en pendientes o en curso
                final pending = visits.where((v) => v['status'] == 'pending' || v['status'] == 'in_progress').length;
                
                // 3. Calcula el porcentaje de eficiencia
                final total = completed + pending;
                final double efficiency = total == 0 ? 0 : (completed / total);
                final int efficiencyPercent = (efficiency * 100).toInt();

                return Column(
                  children: [
                    // Tarjetas de Conteo
                    Row(
                      children: [
                        _buildStatCard(completed.toString(), "Completadas", Icons.check_circle, Colors.green),
                        const SizedBox(width: 15),
                        _buildStatCard(pending.toString(), "Pendientes", Icons.access_time, Colors.orange),
                      ],
                    ),
                    
                    const SizedBox(height: 20),

                   // Barra de Rendimiento
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Eficiencia", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text("$efficiencyPercent%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Barra visual
                          LinearProgressIndicator(
                            value: total == 0 ? 0 : efficiency,
                            backgroundColor: Colors.grey[200],
                            color: AppTheme.primaryColor,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            total == 0 ? "Sin visitas asignadas hoy" : "Basado en $total visitas totales",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text("Error cargando datos: $e")),
            ),

            const SizedBox(height: 30),
            
            //  BOTONES DE CONTACTO 
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor, 
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.phone),
                    label: const Text("Llamar"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {}, 
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      side: const BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.message),
                    label: const Text("Mensaje"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper para dibujar las tarjetitas cuadradas
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
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
          ],
        ),
      ),
    );
  }
}