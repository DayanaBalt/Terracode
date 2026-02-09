import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import 'visit_in_progress_screen.dart'; 
import '../data/visits_repository.dart'; 

class VisitDetailScreen extends ConsumerWidget {
  final String visitId;
  final String clientName;
  final String address;
  final String status; // Recibimos el estado actual

  const VisitDetailScreen({
    super.key,
    required this.visitId,
    required this.clientName,
    required this.address,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.45; 

    // VERIFICAMOS SI la visita ESTÁ COMPLETADA
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // MAPA DE FONDO (Visual)
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))],
                        ),
                        child: Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),

          //  TARJETA DESLIZABLE
          Positioned(
            top: topHeight - 40,
            left: 0, right: 0, bottom: 0,
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
                    // Header
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
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            // Cambia de color si está completada
                            color: isCompleted ? Colors.green[50] : const Color(0xFFE0F2F1), 
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: Icon(
                            isCompleted ? Icons.check_circle : Icons.store, 
                            color: isCompleted ? Colors.green : AppTheme.primaryColor
                          ),
                        )
                      ],
                    ),
                    
                    const Divider(height: 40, color: Color(0xFFEEEEEE)),

                    const Text("Información del PDV", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 20),
                    _buildInfoRow(Icons.access_time, "Horario", "09:00 - 18:00"),
                    const SizedBox(height: 15),
                    _buildInfoRow(Icons.phone, "Contacto", "+51 987 654 321"),

                    const SizedBox(height: 40),

                    if (isCompleted)
                      //SI ESTÁ COMPLETADA: Mostramos cartel de éxito
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green.withOpacity(0.3))
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 10),
                            const Text("Visita Finalizada", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      )
                    else
                      // SI NO ESTÁ COMPLETADA: Mostramos el botón de acción
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Iniciando visita...")));
                            await ref.read(visitsRepositoryProvider).startVisit(visitId);

                            if (context.mounted) {
                               Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VisitInProgressScreen(
                                    visitId: visitId, 
                                    clientName: clientName
                                  )
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.play_arrow),
                          label: const Text("Iniciar Visita", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    
                    const SizedBox(height: 15),
                    
                    // Botón Mapa (Siempre visible)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: const BorderSide(color: AppTheme.primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () {}, // Aquí luego pondremos Google Maps
                        icon: const Icon(Icons.map),
                        label: const Text("Ver en Mapa"),
                      ),
                    ),
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
    return Row(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.darkText)),
          ],
        )
      ],
    );
  }
}