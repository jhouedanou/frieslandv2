import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static const Color primaryColor = Color(AppConstants.bonnetRougeColor);
  static const Color secondaryColor = Color(0xFF2D3748);
  static const Color backgroundColor = Color(0xFFF7FAFC);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color successColor = Color(0xFF38A169);
  static const Color warningColor = Color(0xFFD69E2E);
  
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: _createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      textTheme: GoogleFonts.interTextTheme().copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: secondaryColor,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: secondaryColor,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: secondaryColor,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: secondaryColor,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: secondaryColor,
        ),
      ),
      
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      
      cardTheme: const CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shadowColor: Color(0x1A000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
  
  static MaterialColor _createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    final int r = (color.r * 255).round(), g = (color.g * 255).round(), b = (color.b * 255).round();
    
    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.toARGB32(), swatch);
  }
}