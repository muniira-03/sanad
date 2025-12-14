import 'package:flutter/material.dart';

ThemeData buildTheme() {
  const primary = Color(0xFF5B6EF5);
  const secondary = Color(0xFF00B894);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
    ),
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}
