import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores globales
  static const Color primaryColor = Color(0xFF00695C); // El verde azulado oscuro
  static const Color secondaryColor = Color(0xFF26A69A); // El verde más claro de los botones
  static const Color darkBackground = Color(0xFF0F172A); // Fondo oscuro del Login
  static const Color lightBackground = Color(0xFFF1F5F9); // Fondo claro de los Dashboards
  static const Color errorColor = Color(0xFFD32F2F);
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        background: lightBackground,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      // Configuracion la fuente 
      textTheme: GoogleFonts.interTextTheme(),
      
      // Estilo por defecto de los botones 
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      // Estilo de los Inputs (Cajas de texto del Login)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}