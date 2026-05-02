import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFFF6B47);
  static const Color primarySoft = Color(0xFFFFE8E0);
  static const Color secondary = Color(0xFF2D5F3F);
  static const Color secondarySoft = Color(0xFFE3F0E8);
  static const Color accent = Color(0xFFF4B942);
  static const Color accentSoft = Color(0xFFFFF3D6);
  static const Color purple = Color(0xFF6342B8);
  static const Color purpleSoft = Color(0xFFE8E0FF);
  static const Color bg = Color(0xFFFFF9F5);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFF0E5DC);
  static const Color text = Color(0xFF1A1A1A);
  static const Color textMuted = Color(0xFF6B6B6B);
  static const Color textLight = Color(0xFF9B9B9B);
  static const Color success = Color(0xFF2D9F4B);
  static const Color danger = Color(0xFFD94545);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: text,
          letterSpacing: -1.2,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: text,
          letterSpacing: -0.6,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: text,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: text,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: textMuted,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAF6F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
