// lib/config/app_colors.dart

import 'package:flutter/material.dart';

/// Definição centralizada de todas as cores do aplicativo AFT-PLC-WEB
/// 
/// Baseado na identidade visual da Alfatronic com cores profissionais
/// adequadas para um sistema industrial
class AppColors {
  // Cores principais
  static const Color primary = Color(0xFF0066CC);        // Azul Alfatronic
  static const Color primaryDark = Color(0xFF004499);    // Azul escuro
  static const Color primaryLight = Color(0xFF3399FF);   // Azul claro
  
  // Cores secundárias
  static const Color secondary = Color(0xFF00C853);      // Verde sucesso
  static const Color accent = Color(0xFF00ACC1);         // Ciano
  
  // Cores de status
  static const Color success = Color(0xFF4CAF50);        // Verde
  static const Color warning = Color(0xFFFF9800);        // Laranja
  static const Color error = Color(0xFFF44336);          // Vermelho
  static const Color info = Color(0xFF2196F3);           // Azul info
  
  // Cores de texto
  static const Color textPrimary = Color(0xFF212121);    // Preto
  static const Color textSecondary = Color(0xFF757575);  // Cinza escuro
  static const Color textHint = Color(0xFFBDBDBD);       // Cinza claro
  static const Color textOnPrimary = Colors.white;       // Branco
  
  // Cores de fundo
  static const Color background = Color(0xFFF5F5F5);     // Cinza muito claro
  static const Color surface = Colors.white;             // Branco
  static const Color surfaceVariant = Color(0xFFFAFAFA); // Branco acinzentado
  
  // Cores de borda e divisores
  static const Color border = Color(0xFFE0E0E0);         // Cinza borda
  static const Color divider = Color(0xFFEEEEEE);        // Cinza divisor
  
  // Cores específicas para equipamentos
  static const Color equipmentActive = Color(0xFF4CAF50);      // Verde
  static const Color equipmentMaintenance = Color(0xFFFF9800); // Laranja
  static const Color equipmentInactive = Color(0xFF9E9E9E);    // Cinza
  static const Color equipmentError = Color(0xFFF44336);       // Vermelho
  
  // Cores para gráficos e dashboards
  static const Color chartBlue = Color(0xFF2196F3);
  static const Color chartGreen = Color(0xFF4CAF50);
  static const Color chartOrange = Color(0xFFFF9800);
  static const Color chartRed = Color(0xFFF44336);
  static const Color chartPurple = Color(0xFF9C27B0);
  static const Color chartTeal = Color(0xFF009688);
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF5F7FA), Color(0xFFE9ECEF)],
  );
  
  // Sombras
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primary.withOpacity(0.2),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Método para obter cor de status do equipamento
  static Color getEquipmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'ativo':
        return equipmentActive;
      case 'maintenance':
      case 'manutencao':
      case 'manutenção':
        return equipmentMaintenance;
      case 'inactive':
      case 'inativo':
        return equipmentInactive;
      case 'error':
      case 'erro':
        return equipmentError;
      default:
        return textSecondary;
    }
  }
  
  // Método para obter cor de severidade de alerta
  static Color getAlertSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'crítico':
        return error;
      case 'warning':
      case 'aviso':
        return warning;
      case 'info':
      case 'informação':
        return info;
      default:
        return textSecondary;
    }
  }
}