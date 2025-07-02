import 'package:flutter/material.dart';

class AppThemes {
  // Warna pastel pilihanmu
  static const Color primaryColor = Color(0xFF71C9CE);
  static const Color backgroundColor = Color(0xFFE3FDFD);
  static const Color cardColor = Color(0xFFCBF1F5);
  static const Color inputColor = Color(0xFFA6E3E9);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    brightness: Brightness.light,
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    colorScheme: ColorScheme(
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: primaryColor,
      onSecondary: Colors.white,
      surface: cardColor,
      onSurface: Colors.black,
      background: backgroundColor,
      onBackground: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: inputColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    cardColor: cardColor,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: ColorScheme(
      primary: primaryColor,
      onPrimary: Colors.black,
      secondary: primaryColor,
      onSecondary: Colors.black,
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
      background: const Color(0xFF121212),
      onBackground: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
    cardColor: const Color(0xFF1E1E1E),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
    ),
  );
}
