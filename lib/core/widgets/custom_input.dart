// Encargado de cambiar ícono y su texto, "Email", "Contraseña", "Nombre", etc.

import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

class CustomInput extends StatelessWidget {
  final String hintText;       
  final IconData icon;      
  final bool isPassword;   
  final TextEditingController? controller; 

  const CustomInput({
    super.key,
    required this.hintText,
    required this.icon,
    this.isPassword = false, 
    this.controller,
  });

@override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppTheme.primaryColor.withOpacity(0.5), size: 22),
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}