import 'package:flutter/material.dart';

/// Минимальная зона нажатия для ребёнка (ориентир ТЗ §3.6: 48×48 dp).
/// Визуальная иконка может быть меньше — расширяется только hit area.
abstract final class FinzoHitTarget {
  static const double minSize = 48;

  static ButtonStyle iconButtonStyle({Color? foregroundColor}) {
    return IconButton.styleFrom(
      foregroundColor: foregroundColor,
      minimumSize: const Size(minSize, minSize),
      tapTargetSize: MaterialTapTargetSize.padded,
      padding: const EdgeInsets.all(12),
    );
  }

  /// Оборачивает child в непрозрачную зону ≥ [minSize].
  static Widget wrap({
    required Widget child,
    required VoidCallback? onTap,
    String? semanticLabel,
    Alignment alignment = Alignment.center,
  }) {
    final body = SizedBox(
      width: minSize,
      height: minSize,
      child: Align(alignment: alignment, child: child),
    );
    final tappable = onTap == null
        ? body
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: body,
          );
    if (semanticLabel == null) return tappable;
    return Semantics(
      button: onTap != null,
      label: semanticLabel,
      child: tappable,
    );
  }
}
