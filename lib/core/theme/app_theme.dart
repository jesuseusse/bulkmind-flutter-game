import 'package:flutter/material.dart';
import 'color_palette.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: 'Courier New',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.lightPrimary,
      brightness: Brightness.light,
      surface: AppColors.lightBackground,
      inversePrimary: AppColors.lightPrimary,
      inverseSurface: AppColors.darkBackground,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightText,
      titleTextStyle: TextStyle(
        color: AppColors.lightText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightText,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.lightPrimary),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.lightPrimary,
        side: const BorderSide(color: AppColors.lightPrimary),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightBackground2,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        color: AppColors.lightText,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: const BorderSide(color: AppColors.lightText, width: 1),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.lightText),
      bodyMedium: TextStyle(color: AppColors.lightText),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.lightText),
      labelStyle: TextStyle(color: AppColors.lightText),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightText),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.lightPrimary),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.lightText,
      iconColor: AppColors.lightText,
      titleTextStyle: TextStyle(color: AppColors.lightText),
      subtitleTextStyle: TextStyle(color: AppColors.lightText),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: 'Courier New',
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.darkPrimary,
      brightness: Brightness.dark,
      surface: AppColors.darkBackground,
      inversePrimary: AppColors.darkPrimary,
      inverseSurface: AppColors.lightBackground,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkText,
      titleTextStyle: TextStyle(
        color: AppColors.darkText,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1),
          side: BorderSide(color: AppColors.darkPrimary),
        ),
        textStyle: const TextStyle(
          color: AppColors.darkText,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.darkPrimary,
        side: const BorderSide(color: AppColors.darkPrimary),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkBackground2,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      contentTextStyle: const TextStyle(
        fontSize: 16,
        color: AppColors.darkText,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: const BorderSide(color: AppColors.darkText, width: 1),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.darkText),
      bodyMedium: TextStyle(color: AppColors.darkText),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: AppColors.darkText),
      labelStyle: TextStyle(color: AppColors.darkText),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.darkText),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.darkPrimary),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: AppColors.darkText,
      iconColor: AppColors.darkText,
      titleTextStyle: TextStyle(color: AppColors.darkText),
      subtitleTextStyle: TextStyle(color: AppColors.darkText),
    ),
  );
}
