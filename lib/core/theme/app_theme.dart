import 'package:flutter/material.dart';
import 'light_theme.dart';
import 'dark_theme.dart';

class AppTheme {
  static ThemeData lightTheme = getLightTheme();
  static ThemeData darkTheme = getDarkTheme();
  
  // Method to get current theme based on system settings
  static ThemeData getTheme(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? darkTheme
        : lightTheme;
  }
}
