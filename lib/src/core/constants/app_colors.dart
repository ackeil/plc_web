import 'package:flutter/material.dart';

class AppColors {
  // Cores primárias
  static const Color primary = Color(0xFF2196F3); // Azul Alfatronic
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  
  // Cores secundárias
  static const Color secondary = Color(0xFF4CAF50); // Verde
  static const Color accent = Color(0xFF00BCD4); // Ciano
  
  // Cores de status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Cores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  
  // Cores de fundo
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF8F9FA);
  
  // Cores de borda
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  
  // Cores de status de equipamento
  static const Color equipmentOnline = Color(0xFF4CAF50);
  static const Color equipmentOffline = Color(0xFF9E9E9E);
  static const Color equipmentAlert = Color(0xFFFF9800);
  static const Color equipmentError = Color(0xFFF44336);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F7FA), Color(0xFFE3E7EB)],
  );
}