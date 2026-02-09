import 'dart:async';
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
  Timer? _timer;
  int _secondsElapsed = 0;
  final notesCtrl = TextEditingController();
  
  // VARIABLES PARA LA FOTO
  File? _imageFile; 
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _startLocalTimer();
  }

  void _startLocalTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _secondsElapsed++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsElapsed % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  // FUNCIÓN PARA TOMAR FOTO
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
      });
    }
  }

  //  FUNCIÓN PARA FINALIZAR Y SUBIR
  void _finishVisit() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes tomar una foto de evidencia')));
      return;
    }

    setState(() => _isUploading = true); 

    try {
      // Subimos la foto primero
      final photoUrl = await ref.read(visitsRepositoryProvider).uploadVisitPhoto(widget.visitId, _imageFile!);

      //  Cerramos la visita guardando la nota y el link de la foto
      await ref.read(visitsRepositoryProvider).completeVisit(
        widget.visitId, 
        notesCtrl.text.trim(),
        photoUrl
      );
      
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isUploading = false);
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
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: _isUploading 
        ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 20), Text("Subiendo evidencia...")]))
        : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(widget.clientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 30),

            // CRONÓMETRO
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
                  Text(_formattedTime, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // SECCIÓN FOTO (Interactiva)
            const Align(alignment: Alignment.centerLeft, child: Text("Evidencias Fotográficas", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            
            if (_imageFile != null) 
              // Si ya hay foto, la mostramos
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_imageFile!, height: 200, width: double.infinity, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.close, color: Colors.red)),
                    onPressed: () => setState(() => _imageFile = null),
                  )
                ],
              )
            else
              // Si no hay foto, mostramos el botón
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Tomar Foto"),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
                ),
              ),

            const SizedBox(height: 30),

            const Align(alignment: Alignment.centerLeft, child: Text("Notas de la visita", style: TextStyle(fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            TextField(
              controller: notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Escribe observaciones...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
              ),
            ),

            const SizedBox(height: 40),

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