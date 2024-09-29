import 'package:flutter/material.dart';

class AppColors {
  static const Color federalBlue = Color(0xFF03045E);
  static const Color honoluluBlue = Color(0xFF0077B6);
  static const Color pacificCyan = Color(0xFF00B4D8);
  static const Color nonPhotoBlue = Color(0xFF90E0EF);
  static const Color lightCyan = Color(0xFFCAF0F8);
  static const Color lightFontColor = Colors.white;
  static const Color darkFontColor = Colors.black87;
  static const List<Color> gradientColors = [
    federalBlue,
    honoluluBlue,
    pacificCyan,
    nonPhotoBlue,
    lightCyan,
  ];
  static const LinearGradient gradientVertical = LinearGradient(
    colors: gradientColors,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient gradientHorizontal = LinearGradient(
    colors: gradientColors,
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
  static const RadialGradient gradientRadial = RadialGradient(
    colors: gradientColors,
    center: Alignment.center,
    radius: 0.8,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: AppColors.honoluluBlue,
      scaffoldBackgroundColor: const Color.fromARGB(255, 26, 26, 26),
      colorScheme: const ColorScheme(
        primary: AppColors.honoluluBlue,
        primaryContainer: AppColors.pacificCyan,
        secondary: AppColors.nonPhotoBlue,
        secondaryContainer: AppColors.lightCyan,
        surface: Color.fromARGB(255, 26, 26, 26),
        error: Colors.red,
        onPrimary: AppColors.lightFontColor,
        onSecondary: AppColors.darkFontColor,
        onSurface: AppColors.lightFontColor,
        onError: AppColors.lightFontColor,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.lightFontColor),
        displayMedium: TextStyle(color: AppColors.lightFontColor),
        displaySmall: TextStyle(color: AppColors.lightFontColor),
        headlineMedium: TextStyle(color: AppColors.lightFontColor),
        headlineSmall: TextStyle(color: AppColors.lightFontColor),
        titleLarge: TextStyle(color: AppColors.lightFontColor),
        bodyLarge: TextStyle(color: AppColors.lightFontColor),
        bodyMedium: TextStyle(color: AppColors.lightFontColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.federalBlue,
        foregroundColor: AppColors.lightFontColor,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.honoluluBlue,
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.honoluluBlue,
        foregroundColor: AppColors.darkFontColor,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.honoluluBlue,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme(
        primary: AppColors.honoluluBlue,
        primaryContainer: AppColors.pacificCyan,
        secondary: AppColors.nonPhotoBlue,
        secondaryContainer: AppColors.lightCyan,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: AppColors.lightFontColor,
        onSecondary: AppColors.darkFontColor,
        onSurface: AppColors.darkFontColor,
        onError: AppColors.lightFontColor,
        brightness: Brightness.light,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.darkFontColor),
        displayMedium: TextStyle(color: AppColors.darkFontColor),
        displaySmall: TextStyle(color: AppColors.darkFontColor),
        headlineMedium: TextStyle(color: AppColors.darkFontColor),
        headlineSmall: TextStyle(color: AppColors.darkFontColor),
        titleLarge: TextStyle(color: AppColors.darkFontColor),
        bodyLarge: TextStyle(color: AppColors.darkFontColor),
        bodyMedium: TextStyle(color: AppColors.darkFontColor),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.honoluluBlue,
        foregroundColor: AppColors.lightFontColor,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.pacificCyan,
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.nonPhotoBlue,
        foregroundColor: AppColors.darkFontColor,
      ),
    );
  }
}
