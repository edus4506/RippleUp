import 'package:flutter/material.dart';
import 'palette.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primary, 


      /// Background
      scaffoldBackgroundColor: AppColors.background,


      /// Upper AppBar 
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),


      /// Basic Cards 
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 3,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),

          side: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),


      /// Global text
      textTheme: const TextTheme(

        /// Title (event name)
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),

        /// Description (location, objectives)
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),

        /// Status label (e.g. FULL)
        labelMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.accent,
        ),

        /// Highlight numbers (participants count)
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.accent,
        ),

        /// Action text (e.g. "Show Full Events")
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),


      /// Bottom navigation bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,

        /// Selected icon color
        selectedItemColor: AppColors.primary,

        /// Unselected icon color
        unselectedItemColor: Colors.grey,

        /// Hide labels (icons only)
        showSelectedLabels: false,
        showUnselectedLabels: false,

        /// Background color
        backgroundColor: AppColors.cardBackground,

        /// Shadow elevation
        elevation: 8,
      ),


      /// Input fields (TextField / TextFormField)
      inputDecorationTheme: const InputDecorationTheme(

        /// Default border (inactive)
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.inputBorder,
          ),
        ),

        /// Border when focused (active)
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),

        /// Label text style (Email, Password, etc.)
        labelStyle: TextStyle(
          color: AppColors.textSecondary,
        ),
      ),


      /// Buttons (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.cardBackground,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      /// Icons
      iconTheme: const IconThemeData(
        color: AppColors.accent,
      ),

      /// Sliders
      sliderTheme: SliderThemeData(
        /// Active track (filled part)
        activeTrackColor: AppColors.primary,

        /// Inactive track (background)
        inactiveTrackColor: AppColors.secondary,

        /// Thumb (draggable circle)
        thumbColor: AppColors.primary,

        /// Touch overlay effect
        overlayColor: AppColors.primary.withOpacity(0.2),

        /// Value indicator (tooltip)
        valueIndicatorColor: AppColors.primary,
      ),
    );
  }
}