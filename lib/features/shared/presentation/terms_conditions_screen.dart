import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Términos y Condiciones",
       style: TextStyle(color: Colors.white)), 
       backgroundColor: AppTheme.primaryColor,
       iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildSection("1. Aceptación",
             "Al utilizar esta aplicación, aceptas regirte por los presentes términos y condiciones, así como por las políticas de la empresa administradora."),
            _buildSection("2. Uso de la Ubicación",
             "La aplicación requiere acceso a tu ubicación GPS para verificar la llegada a los Puntos de Venta (PDVs) y calcular las distancias de las rutas asignadas."),
            _buildSection("3. Responsabilidad",
             "El usuario es responsable de mantener la confidencialidad de sus credenciales de acceso. Cualquier actividad realizada desde tu cuenta será considerada tu responsabilidad."),
            _buildSection("4. Privacidad",
             "Las fotografías capturadas como evidencia y las notas ingresadas son propiedad exclusiva de la empresa y no deben contener información personal sensible de terceros sin su consentimiento."),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(color: Colors.black87, height: 1.5)),
        ],
      ),
    );
  }
}