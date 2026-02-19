import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../../../core/constants/app_theme.dart';
import '../data/visits_repository.dart';
//  PANTALLAS
import 'seller_home_screen.dart';
import 'seller_history_screen.dart'; 
import 'seller_profile_screen.dart'; 
import 'visit_detail_screen.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(sellerNavIndexProvider);

    final List<Widget> pages = [
      const SellerHomeScreen(),
      const VisitTabManager(),
      const SellerHistoryScreen(), 
      const SellerProfileScreen(), 
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Rutas'),
            BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Visita'),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: 'Historial'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
          currentIndex: selectedIndex,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          onTap: (index) {
            ref.read(sellerNavIndexProvider.notifier).state = index;
          },
        ),
      ),
    );
  }
}

// ---  Muestra la visita seleccionada en la pestaña ---
class VisitTabManager extends ConsumerWidget {
  const VisitTabManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeId = ref.watch(activeVisitIdProvider);

    if (activeId == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app, size: 60, color: Colors.grey),
            const SizedBox(height: 20),
            const Text("Selecciona una ruta primero", style: TextStyle(color: Colors.grey)),
            TextButton(
              onPressed: () => ref.read(sellerNavIndexProvider.notifier).state = 0,
              child: const Text("Ir a Rutas"),
            )
          ],
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('visits').doc(activeId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        // Obtenemos los datos 
        final data = snapshot.data!.data() as Map<String, dynamic>;
        
        return VisitDetailScreen(
          visitId: activeId,
          clientName: data['clientName'] ?? 'Cliente',
          address: data['address'] ?? 'Dirección',
          status: data['status'] ?? 'pending',
          phone: data['phone'] ?? 'No registrado',
          schedule: data['schedule'] ?? 'No especificado',
        );
      },
    );
  }
}