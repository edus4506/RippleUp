import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,

      /// 🔹 Background geral da app
      scaffoldBackgroundColor: const Color(0xFFF7F7F7),

      /// 🔹 AppBar (barra superior)
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFC9CFB6),
        foregroundColor: Color(0xFF4A693D),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A693D),
        ),
      ),

      /// 🔹 Cards (eventos + filtros)
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),

          /// borda para caixas (Objectives)
          side: BorderSide(
            color: Color(0xFFE0E0E0), 
            width: 1,
          ),
        ),

        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      /// 🔹 Tipografia global
      textTheme: const TextTheme(
        /// 🔹 Título do evento
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4A693D),
        ),

        /// 🔹 Descrição (localização + objetivos)
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Colors.black,
        ),

        /// 🔹 FULL
        labelMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 69, 138, 40),
        ),

        /// 🔹 Número de participantes
        bodyLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 69, 138, 40),
        ),

        /// "Show Full Events"
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold, 
          color: Color(0xFF4A693D), 
        ),
      ),

      /// 🔹 Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF4A693D),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        backgroundColor: Colors.white,
        elevation: 8,
      ),

      /// 🔹 Inputs (TextField)
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        labelStyle: TextStyle(color: Colors.grey),
      ),

      /// 🔹 Botões
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4A693D),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconTheme: const IconThemeData(
        color: Color.fromARGB(255, 66, 139, 35),
      ),
      /// sliders
      sliderTheme: SliderThemeData(
        activeTrackColor: Color(0xFF4A693D),   // barra ativa
        inactiveTrackColor: Color(0xFFC9CFB6), // barra fundo
        thumbColor: Color(0xFF4A693D),         // bolinha
        overlayColor: Color(0x334A693D),       // efeito ao tocar
        valueIndicatorColor: Color(0xFF4A693D),
      ),
    );
  }
}