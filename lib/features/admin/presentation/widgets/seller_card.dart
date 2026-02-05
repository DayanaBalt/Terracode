import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

class SellerCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onTap; // La acción al tocar la tarjeta

  const SellerCard({
    super.key,
    required this.name,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Row(
          children: [
            //  FOTO / AVATAR (Lado Izquierdo)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 24),
            ),
            
            const SizedBox(width: 15),

            // Texto (centro)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email, // Mostramos el correo por ahora
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Etiqueta de estado (Simulada por ahora)
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      const Text("Activo", style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),

            // BOTÓN "VER" (Lado Derecho)
            const Text(
              "Ver",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              ),
          ],
        ),
      ),
    );
  }
}