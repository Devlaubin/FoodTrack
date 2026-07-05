import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:foodtruck_app/theme/colors.dart';

ThemeData buildFoodtrackTheme() {
  final baseTextTheme = GoogleFonts.poppinsTextTheme();

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: FoodtrackColors.cremeVintage,
    colorScheme: const ColorScheme.light(
      primary: FoodtrackColors.rougeKetchup,
      secondary: FoodtrackColors.jauneMoutarde,
      tertiary: FoodtrackColors.vertPickle,
      surface: FoodtrackColors.cremeVintage,
      onSurface: FoodtrackColors.noirBrule,
      onPrimary: FoodtrackColors.cremeVintage,
    ),
    textTheme: baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(
        color: FoodtrackColors.noirBrule,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        color: FoodtrackColors.noirBrule,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        color: FoodtrackColors.noirBrule,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FoodtrackColors.jauneMoutarde,
        foregroundColor: FoodtrackColors.noirBrule,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: FoodtrackColors.noirBrule, width: 2),
        ),
        elevation: 0,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: FoodtrackColors.cremeVintage,
      foregroundColor: FoodtrackColors.noirBrule,
      elevation: 0,
    ),
  );
}
