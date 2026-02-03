import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Paleta colores 
  static const Color primaryColor = Color(0xFF006D77); 
  static const Color secondaryColor = Color(0xFF83C5BE);
  static const Color lightBackground = Color(0xFFF1F5F4); 
  static const Color darkText = Color(0xFF2D3142);
  
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: primaryColor, 
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: lightBackground,
      ),
      textTheme: GoogleFonts.interTextTheme(),
    );
  }
}