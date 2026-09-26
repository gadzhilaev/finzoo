import 'package:flutter/material.dart';

/// Локальный Rubik из `assets/fonts/` — без runtime GoogleFonts,
/// иначе SemiBold рисуется faux-bold и текст «двоится».
abstract final class AppFonts {
  static const family = 'Rubik';

  static TextStyle rubik({
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    Color? color,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
      decoration: decoration,
    );
  }
}
