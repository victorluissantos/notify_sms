import 'package:flutter/material.dart';

/// Cores padronizadas do aplicativo Notify SMS
/// 
/// Este arquivo centraliza todas as cores utilizadas no app,
/// garantindo consistência visual e facilitando manutenção.
class AppColors {
  // Construtor privado para evitar instanciação
  AppColors._();
  
  // Cores primárias
  static const Color primary = Color(0xFF2196F3);      // Azul principal
  static const Color primaryLight = Color(0xFF64B5F6); // Azul claro
  static const Color primaryDark = Color(0xFF1976D2);  // Azul escuro
  
  // Cores de status
  static const Color success = Color(0xFF4CAF50);      // Verde
  static const Color successLight = Color(0xFF81C784); // Verde claro
  static const Color successDark = Color(0xFF388E3C);  // Verde escuro
  
  static const Color danger = Color(0xFFF44336);       // Vermelho
  static const Color dangerLight = Color(0xFFE57373);  // Vermelho claro
  static const Color dangerDark = Color(0xFFD32F2F);   // Vermelho escuro
  
  static const Color warning = Color(0xFFFF9800);      // Laranja
  static const Color warningLight = Color(0xFFFFB74D); // Laranja claro
  static const Color warningDark = Color(0xFFF57C00);  // Laranja escuro
  
  // Cores neutras
  static const Color background = Color(0xFFE3F2FD);  // Azul muito claro (combinando com primary)
  static const Color surface = Color(0xFFFFFFFF);      // Branco
  static const Color card = Color(0xFFFFFFFF);         // Branco para cards
  
  // Cores de texto
  static const Color textPrimary = Color(0xFF212121);  // Texto principal
  static const Color textSecondary = Color(0xFF757575); // Texto secundário
  static const Color textDisabled = Color(0xFFBDBDBD); // Texto desabilitado
  
  // Cores de borda e divisores
  static const Color border = Color(0xFFE0E0E0);       // Borda
  static const Color divider = Color(0xFFBDBDBD);      // Divisor
  
  // Cores de sombra
  static const Color shadow = Color(0x1F000000);       // Sombra sutil
  
  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient dangerGradient = LinearGradient(
    colors: [danger, dangerDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
