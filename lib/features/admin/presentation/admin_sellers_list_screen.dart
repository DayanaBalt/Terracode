import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/admin_repository.dart';
import 'admin_seller_visits_screen.dart'; 

class AdminSellersListScreen extends ConsumerWidget {
  const AdminSellersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellersAsync = ref.watch(sellersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text("Equipo de Ventas", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
            ),
            Expanded(
              child: sellersAsync.when(
                data: (sellers) {
                  if (sellers.isEmpty) return const Center(child: Text("No hay vendedores registrados."));
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: sellers.length,
                    itemBuilder: (context, index) {
                      final seller = sellers[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15),
                          leading: const CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(seller['name'] ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(seller['email'] ?? 'Sin correo'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                            child: const Text("Ver Visitas", style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          onTap: () {
                            //  Ir a ver las visitas de este vendedor para calificar
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminSellerVisitsScreen(
                                  sellerId: seller['uid'], 
                                  sellerName: seller['name'] ?? 'Vendedor'
                                ),
                              ),
                            );
                          },
                        ),
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