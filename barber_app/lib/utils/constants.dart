import 'package:flutter/material.dart';

// Cores do aplicativo
class AppColors {
  static const Color primary = Color(0xFF1E1E24);
  static const Color secondary = Color(0xFFD4AF37); // Dourado
  static const Color accent = Color(0xFF8B0000); // Vermelho escuro
  static const Color background = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color divider = Color(0xFF3A3A3A);
}

// Estilos de texto
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
  
  static const TextStyle price = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.secondary,
  );
  
  static const TextStyle priceDiscount = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    decoration: TextDecoration.lineThrough,
  );
}

// Dimensões e espaçamentos
class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double iconSize = 24.0;
}

// Duração de animações
class AppDurations {
  static const Duration splashScreen = Duration(seconds: 3);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration buttonAnimation = Duration(milliseconds: 200);
}