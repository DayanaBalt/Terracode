// Pantalla intermedia. Esta pantalla se muestra mientras se redirege al usuario segun su rol

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../../admin/presentation/admin_dashboard_screen.dart';
import '../../seller/presentation/seller_dashboard_screen.dart';
import '../data/auth_repository.dart';

class CheckRoleScreen extends ConsumerStatefulWidget {
  const CheckRoleScreen({super.key});

  @override
  ConsumerState<CheckRoleScreen> createState() => _CheckRoleScreenState();
}

class _CheckRoleScreenState extends ConsumerState<CheckRoleScreen> {
  
  @override
  void initState() {
    super.initState();
    _checkRoleAndNavigate();
  }

  void _checkRoleAndNavigate() async {
    // Preguntamos a Firebase qué rol tiene el usuario
    final role = await ref.read(authRepositoryProvider).getUserRole();

    // Si el widget ya no existe (el usuario cerró la app), no hacemos nada
    if (!mounted) return;

    // Decidimos a dónde ir
    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
      );
    } else {
      // Si es 'seller' (o null), va al panel de Vendedor
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SellerDashboardScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mostramos un logo cargando mientras decidimos
    return const Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}