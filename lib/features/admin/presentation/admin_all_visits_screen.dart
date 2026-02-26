import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/admin_repository.dart';
import 'admin_visit_detail_screen.dart'; 

class AdminAllVisitsScreen extends ConsumerWidget {
  const AdminAllVisitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos todas las visitas
    final allVisitsAsync = ref.watch(allCompanyVisitsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Historial de Visitas", style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: allVisitsAsync.when(
        data: (visits) {
          if (visits.isEmpty) return const Center(child: Text("No hay visitas registradas."));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visit = visits[index];
              final isCompleted = visit['status'] == 'completed';
              
              String timeString = "Hoy";
              if (visit['date'] != null) {
                try {
                  DateTime d = DateTime.parse(visit['date']); 
                  timeString = "${d.hour}:${d.minute.toString().padLeft(2,'0')}";
                } catch(e) {}
              }

              return InkWell(
                onTap: () {
                  // AL TOCAR, ABRE LA PANTALLA DE DETALLES
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AdminVisitDetailScreen(visit: visit)));
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
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
                            style: TextStyle(color: isCompleted ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}