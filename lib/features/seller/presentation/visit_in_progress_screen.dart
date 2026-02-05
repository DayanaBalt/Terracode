// esta pantalla Usa un Timer local solo para mostrar el paso del tiempo visualmente al usuario

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/visits_repository.dart';

class VisitInProgressScreen extends ConsumerStatefulWidget {
  final String visitId;
  final String clientName;

  const VisitInProgressScreen({
    super.key,
    required this.visitId,
    required this.clientName,
  });

  @override
  ConsumerState<VisitInProgressScreen> createState() => _VisitInProgressScreenState();
}

class _VisitInProgressScreenState extends ConsumerState<VisitInProgressScreen> {
  // Cronómetro visual
  Timer? _timer;
  int _secondsElapsed = 0;
  final notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startLocalTimer();
  }

  void _startLocalTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    super.dispose();
  }

  // Formato 00:00
  String get _formattedTime {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _finishVisit() async {
    // llamamos a Firebase para cerrar la visita
    await ref.read(visitsRepositoryProvider).completeVisit(
      widget.visitId, 
      notesCtrl.text.trim()
    );
    
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Visita en Curso"),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // Opción de cancelar visualmente
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header del Cliente
            Text(widget.clientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 5),
            const Text("Av. Principal 123, Centro", style: TextStyle(color: Colors.grey)),
            
            const SizedBox(height: 30),

            // CRONÓMETRO GIGANTE
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text("Tiempo transcurrido", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text(
                    _formattedTime,
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // SECCIÓN FOTOS (Placeholder)
            const Align(alignment: Alignment.centerLeft, child: Text("Evidencias Fotográficas", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { /* Lógica de cámara futura */ },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Tomar Foto"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.upload),
                    label: const Text("Subir"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // SECCIÓN NOTAS
            const Align(alignment: Alignment.centerLeft, child: Text("Notas de la visita", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Escribe observaciones, pedidos o comentarios...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
            ),

            const SizedBox(height: 40),

            // BOTÓN FINALIZAR
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, 
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _finishVisit,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Finalizar Visita", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}