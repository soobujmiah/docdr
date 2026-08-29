import 'package:flutter/material.dart';

import '../models/app_settings.dart';

class DocDrTheme {
  static ThemeData light() => ThemeData(useMaterial3: true, brightness: Brightness.light);

  static ThemeData dark() => ThemeData(useMaterial3: true, brightness: Brightness.dark);

  static ThemeData technology() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.cyan,
      );

  static ThemeData classic() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.indigo,
      );

  static ThemeData colorful() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      );

  static ThemeData from(DocDrThemeMode mode) {
    switch (mode) {
      case DocDrThemeMode.light:
        return light();
      case DocDrThemeMode.dark:
        return dark();
      case DocDrThemeMode.technology:
        return technology();
      case DocDrThemeMode.classic:
        return classic();
      case DocDrThemeMode.colorful:
        return colorful();
      case DocDrThemeMode.system:
        return light();
    }
  }
}
