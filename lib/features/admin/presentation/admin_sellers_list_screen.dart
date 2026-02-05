import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/admin_repository.dart'; 
import 'widgets/seller_card.dart'; 

class AdminSellersListScreen extends ConsumerWidget {
  const AdminSellersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos la lista de vendedores en tiempo real
    final sellersListAsync = ref.watch(sellersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Vendedores en Campo"),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white, 
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: AppTheme.darkText, 
          fontSize: 20, 
          fontWeight: FontWeight.bold
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título decorativo
            const Text(
              "Equipo Activo",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 15),

            // LISTA DINÁMICA
            Expanded(
              child: sellersListAsync.when(
                data: (sellers) {
                  if (sellers.isEmpty) {
                    return const Center(child: Text("No hay vendedores registrados aún."));
                  }
                  
                  return ListView.builder(
                    itemCount: sellers.length,
                    itemBuilder: (context, index) {
                      final seller = sellers[index];
                      return SellerCard(
                        name: seller['name'] ?? 'Sin Nombre',
                        email: seller['email'] ?? 'Sin Correo',
                        onTap: () {
                          // AQUÍ ES DONDE SUCEDERÁ LA MAGIA DEL INTERLAZADO
                          // Al dar clic, iremos a ver las rutas de ESTE vendedor específico
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Viendo detalles de ${seller['name']}")),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Error: $e")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}