import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';

class AdminVisitDetailScreen extends StatelessWidget {
  final Map<String, dynamic> visit;

  const AdminVisitDetailScreen({super.key, required this.visit});

  String _formatDate(dynamic dateData) {
    if (dateData == null) return "Fecha no registrada";
    try {
      DateTime date;
      if (dateData is Timestamp) {
        date = dateData.toDate();
      } else {
        date = DateTime.parse(dateData.toString());
      }
      return DateFormat('dd/MM/yyyy - hh:mm a').format(date);
    } catch (e) {
      return "Fecha inválida";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = visit['status'] == 'completed';
    final hasPhoto = visit['photoUrl'] != null && visit['photoUrl'].toString().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Detalle de la Visita", style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TARJETA PRINCIPAL (Datos del Cliente)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                border: Border(top: BorderSide(color: isCompleted ? Colors.green : Colors.orange, width: 5))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          visit['clientName'] ?? 'Cliente Desconocido',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.darkText),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.green[50] : Colors.orange[50],
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(
                          isCompleted ? "Completado" : "Pendiente/En ruta",
                          style: TextStyle(color: isCompleted ? Colors.green : Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      )
                    ],
                  ),
                  const Divider(height: 30),
                  _buildInfoRow(Icons.location_on_outlined, "Dirección", visit['address'] ?? 'Sin dirección'),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.phone_outlined, "Teléfono", visit['phone'] ?? 'No registrado'),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.access_time, "Horario", visit['schedule'] ?? 'Cualquier hora'),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // TARJETA DE EJECUCIÓN (Tiempos y Notas)
            const Text("Detalles de Ejecución", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
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
                  _buildInfoRow(Icons.calendar_today, "Creada el", _formatDate(visit['createdAt'] ?? visit['date'])),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.play_circle_outline, "Inicio", _formatDate(visit['startTime'])),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.check_circle_outline, "Fin", _formatDate(visit['endTime'])),
                  const Divider(height: 30),
                  const Text("Notas del Vendedor:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 5),
                  Text(
                    visit['notes']?.toString().isNotEmpty == true ? visit['notes'] : 'No se dejaron notas.',
                    style: const TextStyle(color: AppTheme.darkText, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // EVIDENCIA FOTOGRÁFICA
            const Text("Evidencia Fotográfica", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            if (hasPhoto)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  visit['photoUrl'],
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250, width: double.infinity, color: Colors.grey[200],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Icon(Icons.broken_image, size: 50, color: Colors.grey), Text("Error cargando imagen")],
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
                child: const Column(
                  children: [
                    Icon(Icons.no_photography_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Sin fotografía", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, color: AppTheme.darkText, fontWeight: FontWeight.w500)),
            ],
          ),
        )
      ],
    );
  }
}