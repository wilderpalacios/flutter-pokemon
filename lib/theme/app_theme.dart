import 'package:flutter/material.dart';

class AppTheme {
  static const _primary   = Color(0xFF274DEA);
  static const _secondary = Color(0xFF8EB9FC);
  static const _tertiary  = Color(0xFFEBFFDC);
  static const _error     = Color(0xFFFF513D);

  static final ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: _secondary,
      tertiary: _tertiary,
      error: _error,
      inversePrimary: _primary,
      brightness: Brightness.light,
    ),
    textTheme: _textTheme,
    useMaterial3: true,
  );

  static final ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      inversePrimary: _secondary,
      brightness: Brightness.dark,
    ),
    textTheme: _textTheme,
    useMaterial3: true,
  );

  static const TextTheme _textTheme = TextTheme(
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(fontSize: 15),
  );
}
