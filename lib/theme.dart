import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF2196F3),
  scaffoldBackgroundColor: const Color(0xFFF2F7FB),
  cardColor: Colors.white,
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2196F3),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.all(Color(0xFF2196F3)),
  ),
  useMaterial3: true,
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF0D47A1),
  scaffoldBackgroundColor: const Color(0xFF121212),
  cardColor: const Color(0xFF1E1E1E),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D47A1),
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStatePropertyAll(Color(0xFF0D47A1)),
  ),
  useMaterial3: true,
);
