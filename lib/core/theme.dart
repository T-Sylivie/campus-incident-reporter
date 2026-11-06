import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const brown = Color(0xFF4A2410);
  static const orange = Color(0xFFF5A623);
  static const amber = Color(0xFFFFB22E);
  static const amberSoft = Color(0xFFFCD58A);
  static const card = Color(0xFFFFF4E3);
  static const border = Color(0xFFF1DDC0);
  static const ink = Color(0xFF2E1608);
  static const muted = Color(0xFF7A5A44);
  static const bgTop = Color(0xFFFFF6EA);
  static const bgBottom = Color(0xFFFBE4CB);

  // Status badge and stripe colors
  static const submittedBg = Color(0xFFEFE4DA);
  static const submittedFg = Color(0xFF5A3A28);
  static const submittedStripe = Color(0xFF8C6A55);
  static const progressBg = Color(0xFFFFC94D);
  static const progressFg = Color(0xFF4A2410);
  static const progressStripe = Color(0xFFF5A623);
  static const resolvedBg = Color(0xFFDDEBD8);
  static const resolvedFg = Color(0xFF2F6B3A);
  static const resolvedStripe = Color(0xFF4C8A5A);
}

class AppTheme {
  static ThemeData get light {
    final text = TextTheme(
      headlineLarge:
          GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w700),
      headlineMedium:
          GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge:
          GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium:
          GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall:
          GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.dmSans(fontSize: 16),
      bodyMedium: GoogleFonts.dmSans(fontSize: 14),
      bodySmall: GoogleFonts.dmSans(fontSize: 12),
      labelLarge:
          GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium:
          GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.dmSans(fontSize: 11),
    ).apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.orange,
        primary: AppColors.brown,
        secondary: AppColors.orange,
      ),
      scaffoldBackgroundColor: Colors.transparent, // gradient shows through
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.brown,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.brown,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border(AppColors.border),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.brown, 1.6),
        errorBorder: border(Colors.red.shade700),
        focusedErrorBorder: border(Colors.red.shade700, 1.6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brown,
          foregroundColor: AppColors.card,
          minimumSize: const Size.fromHeight(54),
          textStyle:
              GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.amber,
      ),
    );
  }
}