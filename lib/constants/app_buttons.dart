import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Estilos de botões padronizados do aplicativo Notify SMS
/// 
/// Este arquivo centraliza todos os estilos de botões utilizados no app,
/// garantindo consistência visual e facilitando manutenção.
class AppButtons {
  // Construtor privado para evitar instanciação
  AppButtons._();
  
  // Dimensões padrão dos botões
  static const double buttonHeight = 50.0;
  static const double buttonWidth = 80.0;
  static const double iconSize = 20.0;
  static const double fontSize = 14.0;
  
  // Padding padrão dos botões
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    vertical: 12.0,
    horizontal: 8.0,
  );
  
  // Espaçamento entre botões
  static const double buttonSpacing = 12.0;
  
  // Forma dos botões (flat/quadrado)
  static const RoundedRectangleBorder flatShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
  );
  
  // Estilo base para todos os botões
  static ButtonStyle get baseStyle => ElevatedButton.styleFrom(
    padding: buttonPadding,
    minimumSize: const Size(buttonWidth, buttonHeight),
    shape: flatShape,
    elevation: 2,
    shadowColor: AppColors.shadow,
  );
  
  // Botão primário (azul)
  static ButtonStyle get primary => baseStyle.copyWith(
    backgroundColor: WidgetStateProperty.all(AppColors.primary),
    foregroundColor: WidgetStateProperty.all(Colors.white),
  );
  
  // Botão secundário (azul escuro)
  static ButtonStyle get secondary => baseStyle.copyWith(
    backgroundColor: WidgetStateProperty.all(AppColors.primaryDark),
    foregroundColor: WidgetStateProperty.all(Colors.white),
  );
  
  // Botão de sucesso (verde)
  static ButtonStyle get success => baseStyle.copyWith(
    backgroundColor: WidgetStateProperty.all(AppColors.success),
    foregroundColor: WidgetStateProperty.all(Colors.white),
  );
  
  // Botão de perigo (vermelho)
  static ButtonStyle get danger => baseStyle.copyWith(
    backgroundColor: WidgetStateProperty.all(AppColors.danger),
    foregroundColor: WidgetStateProperty.all(Colors.white),
  );
  
  // Botão de aviso (laranja)
  static ButtonStyle get warning => baseStyle.copyWith(
    backgroundColor: WidgetStateProperty.all(AppColors.warning),
    foregroundColor: WidgetStateProperty.all(Colors.white),
  );
  
  // Estilo para botões de texto (links)
  static ButtonStyle get textButton => TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    minimumSize: Size.zero,
    foregroundColor: AppColors.primary,
  );
  
  // Estilo para botões de texto de perigo
  static ButtonStyle get textButtonDanger => TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    minimumSize: Size.zero,
    foregroundColor: AppColors.danger,
  );
  
  // Estilo para botões de texto de sucesso
  static ButtonStyle get textButtonSuccess => TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    minimumSize: Size.zero,
    foregroundColor: AppColors.success,
  );
  
  // Estilo para botões desabilitados
  static ButtonStyle get disabled => baseStyle.copyWith(
    backgroundColor: WidgetStateProperty.all(AppColors.textDisabled),
    foregroundColor: WidgetStateProperty.all(AppColors.textSecondary),
  );
  
  // Estilo para botões de ícone
  static ButtonStyle get iconButton => ElevatedButton.styleFrom(
    padding: const EdgeInsets.all(12.0),
    minimumSize: const Size(48.0, 48.0),
    shape: flatShape,
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
  );
  
  // Estilo para botões de toggle
  static ButtonStyle get toggle => baseStyle.copyWith(
    backgroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.surface;
    }),
    foregroundColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return Colors.white;
      }
      return AppColors.primary;
    }),
    side: WidgetStateProperty.all(
      const BorderSide(color: AppColors.primary, width: 1.0),
    ),
  );
}
