// Muestra el formulario que se llena solo con los nombres de los vendedores

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_input.dart';
import '../data/admin_repository.dart';

class AddVisitScreen extends ConsumerStatefulWidget {
  const AddVisitScreen({super.key});

  @override
  ConsumerState<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends ConsumerState<AddVisitScreen> {
  final clientCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  String? selectedSellerId; // Guarda el ID del vendedor seleccionado
  bool isUrgent = false;
  bool isLoading = false;

  void _saveRoute() async {
    // Validamos que no haya campos vacíos
    if (clientCtrl.text.isEmpty || addressCtrl.text.isEmpty || selectedSellerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor llena todos los campos')));
      return;
    }

    setState(() => isLoading = true);
    try {
      // LLAMAMOS AL REPOSITORIO PARA GUARDAR
      await ref.read(adminRepositoryProvider).createVisit(
        sellerId: selectedSellerId!,
        clientName: clientCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        isUrgent: isUrgent,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Ruta asignada con éxito!')));
        Navigator.pop(context);// Cerramos la pantalla al terminar
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

@override
  Widget build(BuildContext context) {
    // lista de vendedores en tiempo real
    final sellersList = ref.watch(sellersListProvider);

    return Scaffold(
      backgroundColor: AppTheme.lightBackground,
      appBar: AppBar(title: const Text("Asignar Nueva Ruta"), backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Seleccionar Vendedor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            
            // Menu desplegable Muestra los usuarios registrados
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: sellersList.when(
                data: (sellers) {
                  if (sellers.isEmpty) return const Padding(padding: EdgeInsets.all(16), child: Text("No hay vendedores registrados"));
                  
                  return DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text("Elige un vendedor"),
                      value: selectedSellerId,
                      items: sellers.map((seller) {
                        return DropdownMenuItem<String>(
                          value: seller['uid'], // El valor oculto es el ID
                          child: Text(seller['name'] ?? 'Sin Nombre'), // Lo que se ve es el Nombre
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => selectedSellerId = value),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text("Error cargando vendedores: $e"),
              ),
            ),

            const SizedBox(height: 20),
            const Text("Datos del Cliente", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            CustomInput(hintText: "Nombre del Negocio", icon: Icons.store, controller: clientCtrl),
            CustomInput(hintText: "Dirección", icon: Icons.map, controller: addressCtrl),

            SwitchListTile(
              title: const Text("¿Es Urgente?", style: TextStyle(fontWeight: FontWeight.bold)),
              value: isUrgent,
              activeColor: Colors.red,
              onChanged: (val) => setState(() => isUrgent = val),
            ),

            const SizedBox(height: 30),
            CustomButton(text: "Guardar y Asignar", isLoading: isLoading, onPressed: _saveRoute),
          ],
        ),
      ),
    );
  }
}