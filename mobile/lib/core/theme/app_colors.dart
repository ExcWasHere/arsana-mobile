import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna Arsana.
/// Primary  = Cyan cerah → warna brand utama & CTA
/// Secondary = Teal       → aksen pendukung
/// White     = background utama
class AppColors {
  AppColors._();

  // ===== PRIMARY — Cyan cerah =====
  static const Color primary = Color(0xFF06B6D4);
  static const Color primaryDark = Color(0xFF0891B2);
  static const Color primaryLight = Color(0xFFCFFAFE);

  // ===== SECONDARY — Teal =====
  static const Color secondary = Color(0xFF0F766E);
  static const Color secondaryLight = Color(0xFFCCFBF1);

  // ===== Neutral =====
  static const Color white = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF0B1F1D);
  static const Color mist = Color(0xFFF4FBFB);
  static const Color error = Color(0xFFE53935);
  static const Color primaryTeal = secondary;
  static const Color cyanAccent = primary;
  static const Color lightCyan = primaryLight;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.mist,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.white,
    ),
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: TextTheme(
      displaySmall: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: AppColors.ink),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.ink.withOpacity(0.7),
      ),
      labelLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.ink),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        side: const BorderSide(color: AppColors.primary, width: 1.4),
        foregroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.4),
      ),
      hintStyle: GoogleFonts.inter(color: AppColors.ink.withOpacity(0.4)),
      labelStyle: GoogleFonts.inter(color: AppColors.ink.withOpacity(0.6)),
    ),
  );
}