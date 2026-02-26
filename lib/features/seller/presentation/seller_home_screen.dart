import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/visits_repository.dart';
import '../../auth/data/auth_repository.dart'; 

class SellerHomeScreen extends ConsumerWidget {
  const SellerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitsAsyncValue = ref.watch(userVisitsProvider);
    
    // perfil del usuario para sacar su nombre
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final userName = userProfileAsync.value?['name'] ?? 'Vendedor';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: visitsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (visits) {
          final pendingCount = visits.where((v) => v['status'] == 'pending').length;
          final completedCount = visits.where((v) => v['status'] == 'completed').length;

          return Column(
            children: [
              // HEADER MEJORADO 
              Container(
                width: double.infinity, 
                padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor, 
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(35), 
                    bottomRight: Radius.circular(35)
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //  Textos de la Izquierda 
                    Expanded( // Usamos Expanded para que textos largos no rompan la fila
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Hola $userName', 
                                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min, 
                              children: [
                                Icon(Icons.directions_run, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('Tu ruta está lista', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ]
                      ),
                    ),
                    const SizedBox(width: 15), 
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // RESUMEN
                      Row(children: [
                        Expanded(child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(children: [const Icon(Icons.access_time, color: Colors.orange), Text(pendingCount.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const Text("Pendientes")]))),
                        const SizedBox(width: 15),
                        Expanded(child: Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(children: [const Icon(Icons.check_circle, color: Colors.green), Text(completedCount.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const Text("Listas")])))
                      ]),
                      
                      const SizedBox(height: 25),
                      const Align(alignment: Alignment.centerLeft, child: Text("Ruta de Hoy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkText))),
                      const SizedBox(height: 15),

                      if (visits.isEmpty)
                        const Padding(padding: EdgeInsets.all(20), child: Text("No hay rutas hoy"))
                      else
                        Column(
                          children: visits.map((visit) {
                            
                            // Lógica de colores y estado
                            final isCompleted = visit['status'] == 'completed';
                            final isUrgent = visit['isUrgent'] == true;
                            
                            // Color del pin
                            final iconColor = isCompleted ? Colors.green : AppTheme.primaryColor;

                            return GestureDetector(
                              onTap: () {
                                ref.read(activeVisitIdProvider.notifier).state = visit['id'];
                                ref.read(sellerNavIndexProvider.notifier).state = 1; // Cambiar a Pestaña Visita
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(color: Colors.white, 
                                  borderRadius: BorderRadius.circular(15), 
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                                child: Row(children: [
                                  // ICONO IZQUIERDO (PIN)
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                                    child: Icon(Icons.location_on, color: iconColor),
                                  ),
                                  const SizedBox(width: 15),
                                  
                                  // TEXTOS CENTRALES
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(visit['clientName'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                        if (isUrgent && !isCompleted) ...[
                                          const SizedBox(width: 8),
                                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red[100], borderRadius: BorderRadius.circular(4)), child: const Text("Urgente", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)))
                                        ]
                                      ],
                                    ),
                                    Text(visit['address'] ?? 'Dirección', style: const TextStyle(color: Colors.grey, fontSize: 12))
                                  ])),
                                  
                                  // --- EL PUNTITO / CHECK A LA DERECHA ---
                                  if (isCompleted)
                                    Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(color: Colors.green[100], borderRadius: BorderRadius.circular(8)), // Cuadradito verde claro
                                      child: const Icon(Icons.check, color: Colors.green, size: 20), // Check verde oscuro
                                    )
                                  else
                                    const Icon(Icons.chevron_right, color: Colors.grey)
                                ]),
                              ),
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
}