import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/visits_repository.dart';
import 'visit_in_progress_screen.dart'; 

class VisitDetailScreen extends ConsumerWidget {
  final String visitId;
  final String clientName;
  final String address;
  final String status;
  final String phone;
  final String schedule;

  const VisitDetailScreen({
    super.key,
    required this.visitId,
    required this.clientName,
    required this.address,
    required this.status,
    required this.phone,
    required this.schedule,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.45; 
    final bool isCompleted = status == 'completed';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            // --- SOLUCIÓN PANTALLA NEGRA ---
            onPressed: () {
              // Limpiamos la selección y volvemos a la pestaña Rutas
              ref.read(activeVisitIdProvider.notifier).state = null;
              ref.read(sellerNavIndexProvider.notifier).state = 0;
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          // --- FONDO DEL MAPA ---
          Positioned(
            top: 0, left: 0, right: 0, height: topHeight,
            child: Container(
              color: const Color(0xFFE0F7FA),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(top: 50, right: 50, child: Icon(Icons.location_on, color: Colors.blue.withOpacity(0.2), size: 40)),
                  Positioned(bottom: 100, left: 50, child: Icon(Icons.location_on, color: Colors.blue.withOpacity(0.2), size: 40)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 60, color: isCompleted ? Colors.green : AppTheme.primaryColor),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, 
                        borderRadius: BorderRadius.circular(20), 
                        boxShadow: [BoxShadow(blurRadius: 10, 
                        color: Colors.black.withOpacity(0.1))]),
                        child: Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- TARJETA DE INFORMACIÓN DESLIZABLE ---
          Positioned(
            top: topHeight - 40, left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CABECERA 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(clientName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                              const SizedBox(height: 5),
                              Text(address, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            ],
                          ),
                        ),
                        // ÍCONO DE ESTADO (Tienda o Check Verde)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCompleted ? Colors.green[50] : const Color(0xFFE0F2F1), 
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: Icon(isCompleted ? Icons.check_circle : Icons.store, color: isCompleted ? Colors.green : AppTheme.primaryColor),
                        )
                      ],
                    ),
                    
                    const Divider(height: 40, color: Color(0xFFEEEEEE)),
                    
                    // DATOS DEL PDV
                    const Text("Información del PDV", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 20),
                    
                    _buildInfoRow(Icons.access_time, "Horario", schedule), 
                    const SizedBox(height: 15),
                    _buildInfoRow(Icons.phone, "Contacto", phone),

                    const SizedBox(height: 40),

                    // --- BOTONES DE ACCIÓN ---
                    if (isCompleted)
                      // SI YA ESTÁ COMPLETADA
                      Container(
                        width: double.infinity, padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green[50], 
                          borderRadius: BorderRadius.circular(15), 
                          border: Border.all(color: Colors.green.withOpacity(0.3))),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.center, 
                          children: [Icon(Icons.check_circle, color: Colors.green), 
                          SizedBox(width: 10), Text("Visita Finalizada", 
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16))]
                        ),
                      )
                    else
                      // SI ESTÁ PENDIENTE -> BOTÓN INICIAR
                      SizedBox(
                        width: double.infinity, height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor, 
                            foregroundColor: Colors.white, elevation: 5, 
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                          ),
                          
                          // ---  SOLUCIÓN NAVEGACIÓN AL CRONÓMETRO ---
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Iniciando visita...")));
                            
                            //  Iniciamos en Firebase
                            await ref.read(visitsRepositoryProvider).startVisit(visitId);
                            
                            // Navegamos a la pantalla de Progreso (VisitInProgressScreen)
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VisitInProgressScreen(
                                    visitId: visitId,
                                    clientName: clientName,
                                  ),
                                ),
                              );
                            }
                          },
                          
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Iniciar Visita", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    
                    const SizedBox(height: 15),
                    
                    // BOTÓN MAPA
                    SizedBox(width: double.infinity, 
                      height: 50, 
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor, 
                          side: const BorderSide(color: AppTheme.primaryColor), 
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))), 
                            onPressed: () {}, 
                            icon: const Icon(Icons.map), label: const Text("Ver en Mapa"))),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(children: [Icon(icon, color: Colors.grey[400], size: 20), 
    const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: 
    const TextStyle(fontSize: 12, color: Colors.grey)), Text(value, style: 
    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.darkText))])]);
  }
}