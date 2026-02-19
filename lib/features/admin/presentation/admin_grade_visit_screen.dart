import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/admin_repository.dart';

class AdminGradeVisitScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> visitData;

  const AdminGradeVisitScreen({super.key, required this.visitData});

  @override
  ConsumerState<AdminGradeVisitScreen> createState() => _AdminGradeVisitScreenState();
}

class _AdminGradeVisitScreenState extends ConsumerState<AdminGradeVisitScreen> {
  final _pointsCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.visitData['points'] != null && widget.visitData['points'] > 0) {
      _pointsCtrl.text = widget.visitData['points'].toString();
    }
  }

  Future<void> _savePoints() async {
    if (_pointsCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final points = int.parse(_pointsCtrl.text);
      await ref.read(adminRepositoryProvider).assignPointsToVisit(widget.visitData['id'], points);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Calificación guardada!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.visitData['photoUrl'] != null;
    final notes = widget.visitData['notes'] ?? 'Sin observaciones';
    
    // Formatear fecha
    String dateStr = "Fecha desconocida";
    if (widget.visitData['endTime'] != null) {
       // Intentamos formatear si es Timestamp
       try {
         final date = widget.visitData['endTime'].toDate();
         dateStr = DateFormat('dd MMM yyyy, HH:mm').format(date);
       } catch (e) { dateStr = "Hoy"; }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), 
      appBar: AppBar(
        title: const Text("Evaluación de Visita", style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // TARJETA DE INFO DEL CLIENTE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.store, color: Colors.blue),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.visitData['clientName'] ?? 'Cliente', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(widget.visitData['address'] ?? 'Dirección', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text("Realizada: $dateStr", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            //  EVIDENCIA Y NOTAS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Evidencia en Campo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  // FOTO
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: hasPhoto
                        ? Image.network(
                            widget.visitData['photoUrl'],
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: double.infinity,
                            height: 150,
                            color: Colors.grey[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey[400]),
                                const SizedBox(height: 10),
                                Text("El vendedor no adjuntó foto", style: TextStyle(color: Colors.grey[500])),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 20),
                  const Text("Notas del Vendedor:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(10)),
                    child: Text(notes, style: const TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //ZONA DE CALIFICACIÓN 
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xFF004D40), 
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: const Color(0xFF004D40).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars, color: Colors.amber, size: 28),
                      SizedBox(width: 10),
                      Text("Asignar Puntaje", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text("Define los puntos ganados por esta ejecución.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 20),
                  
                  // INPUT DE PUNTOS
                  TextField(
                    controller: _pointsCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      hintText: "0",
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                      suffixText: "PTS",
                      suffixStyle: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // BOTÓN GUARDAR
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _savePoints,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF004D40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : const Text("GUARDAR CALIFICACIÓN", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}