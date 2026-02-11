import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import 'add_visit_screen.dart'; 
import '../../auth/presentation/login_screen.dart';
import 'admin_sellers_list_screen.dart';// Vendedores
import 'admin_home_dashboard.dart';//  Dashboard
import 'admin_settings_screen.dart'; //AJUSTES 

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> get _pages => <Widget>[
    const AdminHomeDashboard(),
    const AdminSellersListScreen(),
    const Center(child: Text('REPORTES Y GRÁFICOS')),
    const AdminSettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos el getter _pages
      body: _pages[_selectedIndex],
      
      // BOTÓN FLOTANTE 
      floatingActionButton: _selectedIndex == 1 
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddVisitScreen()));
              },
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add_location_alt, color: Colors.white),
              label: const Text("Nueva Ruta", style: TextStyle(color: Colors.white)),
            )
          : null, 

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Vendedores'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reportes'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Ajustes'),
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