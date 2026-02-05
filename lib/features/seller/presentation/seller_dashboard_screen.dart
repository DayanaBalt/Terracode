// Pantalla Vendedor
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../auth/presentation/login_screen.dart'; 
import 'seller_home_screen.dart'; 

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  int _selectedIndex = 0;

  // Definimos las pantallas
  static final List<Widget> _pages = <Widget>[
    const SellerHomeScreen(), 
    const Center(child: Text('Pantalla de VISITA ACTIVA')),
    const Center(child: Text('Pantalla de HISTORIAL')),
    const SellerProfileTab(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Rutas'),
            BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Visita'),
            BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: 'Historial'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
    );
  }
}

// Widget pequeño para el perfil y el botón de Salir
class SellerProfileTab extends StatelessWidget {
  const SellerProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 40, backgroundColor: AppTheme.primaryColor, child: Icon(Icons.person, size: 40, color: Colors.white)),
          const SizedBox(height: 20),
          const Text('Perfil de Vendedor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              // Lógica de logout segura
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}