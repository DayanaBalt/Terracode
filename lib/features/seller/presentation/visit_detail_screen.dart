import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import 'visit_in_progress_screen.dart'; 
import '../data/visits_repository.dart'; 

class VisitDetailScreen extends ConsumerWidget {
  final String visitId;
  final String clientName;
  final String address;
  final String status;

  const VisitDetailScreen({
    super.key,
    required this.visitId,
    required this.clientName,
    required this.address,
    required this.status,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Alturas para el diseño responsivo
    final size = MediaQuery.of(context).size;
    final topHeight = size.height * 0.45; // El mapa ocupa el 45% de arriba

    return Scaffold(
      extendBodyBehindAppBar: true, // Para que el mapa quede detrás de la flecha volver
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
          // EL MAPA DE FONDO (Simulado visualmente)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topHeight,
            child: Container(
              color: const Color(0xFFE0F7FA), // Azulito mapa
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Líneas decorativas de mapa
                  Positioned(top: 50, right: 50, child: Icon(Icons.location_on, color: Colors.blue.withOpacity(0.2), size: 40)),
                  Positioned(bottom: 100, left: 50, child: Icon(Icons.location_on, color: Colors.blue.withOpacity(0.2), size: 40)),
                  
                  // Marcador Central
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, size: 60, color: AppTheme.primaryColor),
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

          // LA TARJETA DE INFORMACIÓN (Deslizable hacia arriba)
          Positioned(
            top: topHeight - 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y Estado
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
                        decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.store, color: AppTheme.primaryColor),
                      )
                    ],
                  ),
                  
                  const Divider(height: 40, color: Color(0xFFEEEEEE)),

                  // Detalles de la Visita
                  const Text("Información del PDV", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 20),
                  _buildInfoRow(Icons.access_time, "Horario programado", "09:00 - 18:00"),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.phone, "Contacto", "+51 987 654 321"),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.category, "Tipo", "Minimarket"),

                  const Spacer(),

                  // BOTÓN INICIAR VISITA
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
                        //  Mostrar carga
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Iniciando visita...")));
                        
                        //  Avisar a Firebase (Cambiar estado y poner hora)
                        await ref.read(visitsRepositoryProvider).startVisit(visitId);

                        // Ir a la pantalla de Cronómetro
                        if (context.mounted) {
                           Navigator.pushReplacement( // Usamos Replacement para que no pueda volver atrás fácilmente
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
                  
                  // Botón Secundario
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                        side: const BorderSide(color: AppTheme.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.navigation),
                      label: const Text("Abrir Mapa de Navegación"),
                    ),
                  ),
                ],
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
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.grey[600], size: 20),
        ),
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