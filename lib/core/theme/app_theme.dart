import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Backgrounds
  static const background = Color(0xFF0E0F1A);
  static const surface = Color(0xFF161728);
  static const card = Color(0xFF1C1E32);
  static const cardBorder = Color(0xFF2A2C45);

  // Accent
  static const primary = Color(0xFF7C6FF7);
  static const primaryLight = Color(0xFF9D98FF);

  // Category gradients
  static const List<List<Color>> categoryGradients = [
    [Color(0xFF4F8EF7), Color(0xFF2D5BE3)],   // length  – blue
    [Color(0xFF6C63FF), Color(0xFF4A3FD4)],   // weight  – indigo
    [Color(0xFFFF7043), Color(0xFFE64A19)],   // temperature – orange
    [Color(0xFF26C6DA), Color(0xFF0097A7)],   // area    – cyan
    [Color(0xFFEC407A), Color(0xFFC2185B)],   // speed   – pink
    [Color(0xFFFFCA28), Color(0xFFFFB300)],   // currency – amber
    [Color(0xFF66BB6A), Color(0xFF388E3C)],   // data storage – green
  ];

  static const List<Color> categoryIconBg = [
    Color(0xFF1A2540),
    Color(0xFF1E1A40),
    Color(0xFF401A12),
    Color(0xFF0D3038),
    Color(0xFF40102A),
    Color(0xFF403010),
    Color(0xFF0F3010),
  ];

  static const textPrimary = Color(0xFFEEEEFF);
  static const textSecondary = Color(0xFF8B8FAD);
  static const divider = Color(0xFF252740);
}

class AppTheme {
  static ThemeData dark() {
    const cs = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.card,
      outline: AppColors.cardBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return TextStyle(
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final active = states.contains(WidgetState.selected);
          return IconThemeData(
            color: active ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          );
        }),
        elevation: 0,
        height: 64,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      textTheme: const TextTheme(
        displaySmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: AppColors.textPrimary),
        titleLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
        bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        labelSmall: TextStyle(color: AppColors.textSecondary, fontSize: 11),
      ),
    );
  }

  // Keep a light variant for system compat — same dark look
  static ThemeData light() => dark();
}
