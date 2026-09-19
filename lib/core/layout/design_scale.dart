import 'package:flutter/widgets.dart';

/// Макет Figma: 393 × 852.
class DesignScale {
  DesignScale._(this.width, this.height);

  factory DesignScale.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return DesignScale._(size.width, size.height);
  }

  static const double designWidth = 393;
  static const double designHeight = 852;

  final double width;
  final double height;

  double get scale => width / designWidth;

  double s(double value) => value * scale;
}
