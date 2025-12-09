import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // A more modern, slightly softer primary color
  static const Color _primaryColor = Color(0xFF7E57C2); 

  static final ThemeData lightTheme = _buildTheme(
    brightness: Brightness.light,
    seedColor: _primaryColor,
    surface: Colors.white, // Cards will be white
    scaffold: const Color(0xFFF0F2F5), // Background will be a light grey
  );

  static final ThemeData darkTheme = _buildTheme(
    brightness: Brightness.dark,
    seedColor: _primaryColor,
    surface: const Color(0xFF2C2C34), // Cards will be a lighter grey
    scaffold: const Color(0xFF1A1A24), // Background will be a darker grey
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color seedColor,
    required Color surface,
    required Color scaffold,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
      surface: surface,
      // Define text colors for better contrast and hierarchy
      onSurface: brightness == Brightness.dark ? const Color(0xFFE0E0E0) : const Color(0xFF333333),
      onPrimary: Colors.white,
    );

    // Use the Inter font via google_fonts, and customize sizes
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme.copyWith(
        // Large, bold headlines for page titles
        headlineLarge: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        // Slightly smaller, but still bold headlines
        headlineMedium: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        // Standard headlines for sections
        headlineSmall: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),

        // Titles for cards and list items
        titleLarge: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),

        // Standard body text for descriptions and paragraphs
        bodyLarge: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),

        // Smaller labels for subtitles and captions
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
      ),
    ).apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffold,
      textTheme: textTheme,
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: MaterialStateProperty.all(
          textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: surface,
        foregroundColor: colorScheme.onSurface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: textTheme.headlineSmall, // Use theme's headline style
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surface,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark ? const Color(0xFF3C3C44) : const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // No border by default
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
