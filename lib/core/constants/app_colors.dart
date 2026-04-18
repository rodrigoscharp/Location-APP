import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary — coral vibrante
  static const coral = Color(0xFFFF5A5F);
  static const coralLight = Color(0xFFFF7E82);
  static const coralDark = Color(0xFFE0484D);

  // Accent — teal
  static const teal = Color(0xFF00A699);
  static const tealLight = Color(0xFF33C4BA);
  static const tealDark = Color(0xFF007F75);

  // Neutros
  static const charcoal = Color(0xFF222222);
  static const darkGray = Color(0xFF484848);
  static const warmGray = Color(0xFF717171);
  static const mediumGray = Color(0xFFB0B0B0);
  static const lightGray = Color(0xFFDDDDDD);
  static const paleGray = Color(0xFFF7F7F7);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // Semantic
  static const success = Color(0xFF008A05);
  static const warning = Color(0xFFE88B00);
  static const error = Color(0xFFC13515);

  // Special
  static const starYellow = Color(0xFFFF9C00);
  static const overlay = Color(0x80000000);

  // Gradientes
  static const gradientCoral = LinearGradient(
    colors: [Color(0xFFFF5A5F), Color(0xFFFF385C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const gradientImage = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
