import 'package:flutter/material.dart';
import 'palette.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: Palette.primary,
        secondary: Palette.secondary,
        background: Palette.background,
      ),

      scaffoldBackgroundColor: Palette.background,

      /// AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Palette.secondary,
        foregroundColor: Palette.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Palette.primary,
        ),
      ),

      /// Cards
      cardTheme: CardThemeData(
        color: Palette.cardBackground,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Palette.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      /// Text
      textTheme: const TextTheme(
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Palette.textPrimary,
        ),
        bodyMedium: TextStyle(fontSize: 14, color: Palette.textSecondary),
        labelMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Palette.accent,
        ),
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Palette.accent,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Palette.textPrimary,
        ),
      ),

      /// Bottom Nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Palette.primary,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Palette.cardBackground,
        elevation: 8,
      ),

      /// Inputs
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Palette.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Palette.primary, width: 2),
        ),
        labelStyle: TextStyle(color: Palette.textSecondary),
      ),

      /// Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Palette.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      /// Icons
      iconTheme: const IconThemeData(color: Palette.accent),

      /// Sliders
      sliderTheme: SliderThemeData(
        activeTrackColor: Palette.primary,
        inactiveTrackColor: Palette.secondary,
        thumbColor: Palette.primary,
        overlayColor: Palette.primary.withOpacity(0.2),
        valueIndicatorColor: Palette.primary,
      ),
    );
  }
}
