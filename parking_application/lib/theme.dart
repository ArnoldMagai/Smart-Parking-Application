import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.red[600],
    scaffoldBackgroundColor: const Color(0xFF0A0A0A), // neutral-950
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0A0A),
      elevation: 0,
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.red[600]!,
      secondary: Colors.redAccent,
      surface: const Color(0xFF171717), // neutral-900
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.red[600],
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.red[600]!,
      secondary: Colors.redAccent,
      surface: Colors.grey[100]!,
    ),
  );
}
