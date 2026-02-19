import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/admin_repository.dart';

class AddVisitScreen extends ConsumerStatefulWidget {
  const AddVisitScreen({super.key});

  @override
  ConsumerState<AddVisitScreen> createState() => _AddVisitScreenState();
}

class _AddVisitScreenState extends ConsumerState<AddVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // CONTROLADORES
  final nameCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final phoneCtrl = TextEditingController(); 
  final scheduleCtrl = TextEditingController(); 
  
  String? _selectedSellerId;
  bool _isUrgent = false;
  bool _isLoading = false;

  void _saveVisit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedSellerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un vendedor')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(adminRepositoryProvider).createVisit(
        sellerId: _selectedSellerId!,
        clientName: nameCtrl.text.trim(),
        address: addressCtrl.text.trim(),
        isUrgent: _isUrgent,
        lat: 0.0, 
        lng: 0.0, 
        phone: phoneCtrl.text.trim(),       
        schedule: scheduleCtrl.text.trim(), 
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ruta creada exitosamente")));
        Navigator.pop(context); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sellersAsync = ref.watch(sellersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Nueva Ruta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              const Text("Datos del Cliente", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),

              // CLIENTE
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    _buildFancyInput(
                      controller: nameCtrl,
                      label: "Nombre del Cliente / Tienda",
                      icon: Icons.store_mall_directory,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildFancyInput(
                      controller: addressCtrl,
                      label: "Dirección Exacta",
                      icon: Icons.map,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildFancyInput(
                      controller: phoneCtrl,
                      label: "Teléfono de Contacto",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),
              const Text("Detalles de la Visita", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 10),

              // VISITA
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    // CAMPO DE HORARIO MEJORADO
                    _buildFancyInput(
                      controller: scheduleCtrl,
                      label: "Horario de Atención",
                      hint: "Ej: 9:00 AM - 6:00 PM",
                      icon: Icons.access_time_filled,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    
                    const SizedBox(height: 20),

                    // DROPDOWN VENDEDORES
                    sellersAsync.when(
                      data: (sellers) {
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Asignar a Vendedor",
                            prefixIcon: const Icon(Icons.person_search, color: AppTheme.primaryColor),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          value: _selectedSellerId,
                          items: sellers.map<DropdownMenuItem<String>>((seller) {
                            return DropdownMenuItem(
                              value: seller['uid'],
                              child: Text(seller['name'] ?? 'Sin nombre'),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedSellerId = val),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => Text("Error: $e"),
                    ),

                    const SizedBox(height: 20),

                    // SWITCH URGENTE
                    Container(
                      decoration: BoxDecoration(
                        color: _isUrgent ? Colors.red[50] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isUrgent ? Colors.red.withOpacity(0.3) : Colors.transparent)
                      ),
                      child: SwitchListTile(
                        title: Text("¿Es Prioritario? (Urgente)", style: TextStyle(fontWeight: FontWeight.bold, color: _isUrgent ? Colors.red : Colors.black87)),
                        subtitle: const Text("Marcar con alerta roja"),
                        value: _isUrgent,
                        activeColor: Colors.red,
                        secondary: Icon(Icons.warning_amber_rounded, color: _isUrgent ? Colors.red : Colors.grey),
                        onChanged: (val) => setState(() => _isUrgent = val),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              
              // BOTÓN GUARDAR 
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor, 
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _saveVisit,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("CREAR RUTA", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET AUXILIAR PARA LOS CAMPOS DE TEXTO
  Widget _buildFancyInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        filled: true,
        fillColor: Colors.grey[50], 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
      ),
    );
  }
}