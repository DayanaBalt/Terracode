import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), 
      appBar: AppBar(
        title: const Text("Términos y Condiciones", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), 
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 5, bottom: 15),
              child: Text(
                "Última actualización: Marzo 2026",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
            
            //  CONTENEDOR TIPO TARJETA 
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    "1. Aceptación",
                    "Al utilizar esta aplicación, aceptas regirte por los presentes términos y condiciones, así como por las políticas de la empresa administradora.",
                    Icons.check_circle_outline,
                  ),
                  const Divider(height: 30, color: Colors.black12),
                  
                  _buildSection(
                    "2. Uso de la Ubicación",
                    "La aplicación requiere acceso a tu ubicación GPS para verificar la llegada a los Puntos de Venta (PDVs) y calcular las distancias de las rutas asignadas.",
                    Icons.location_on_outlined,
                  ),
                  const Divider(height: 30, color: Colors.black12),
                  
                  _buildSection(
                    "3. Responsabilidad",
                    "El usuario es responsable de mantener la confidencialidad de sus credenciales de acceso. Cualquier actividad realizada desde tu cuenta será considerada tu responsabilidad.",
                    Icons.shield_outlined,
                  ),
                  const Divider(height: 30, color: Colors.black12),
                  
                  _buildSection(
                    "4. Privacidad",
                    "Las fotografías capturadas como evidencia y las notas ingresadas son propiedad exclusiva de la empresa y no deben contener información personal sensible de terceros sin su consentimiento.",
                    Icons.lock_outline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // WIDGET PARA CADA REGLA 
  Widget _buildSection(String title, String body, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icono decorativo a la izquierda
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 22, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 15),
        
        // Textos a la derecha
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText)
              ),
              const SizedBox(height: 6),
              Text(
                body, 
                style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 13)
              ),
            ],
          ),
        ),
      ],
    );
  }
}