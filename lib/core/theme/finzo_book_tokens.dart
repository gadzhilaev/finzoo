import 'package:flutter/material.dart';

/// Design tokens, измеренные по SVG дизайнера
/// `/Downloads/svg/обучение/Книжка *.svg` (эталон: «Книжка 2 стр.svg»).
///
/// Геометрия экрана: 393 × ~846.
/// Карточки сравнения (стр. 2): 160×170 / 152×170, rx=13.5, y≈488.5.
/// Badge: r=12.5, частично выходит за верхнюю границу карточки.
/// Nav: 126×63, rx=11, fill `#4B946A`.
abstract final class FinzoBookTokens {
  // --- palette ---
  static const Color pageCream = Color(0xFFFEFCF4);
  static const Color notebookCream = Color(0xFFFEF7E6);
  static const Color arrowGreen = Color(0xFF4B946A);
  static const Color titleGreen = Color(0xFF1B6943);
  static const Color ink = Color(0xFF3D3D3D);
  static const Color inkSoft = Color(0xFF4B4A48);
  static const Color body = Color(0xFF4A4643);
  static const Color mint = Color(0xFFEBF4EE);
  static const Color decorYellow = Color(0xFFFCD788);
  static const Color squirrelOrange = Color(0xFFDF9951);
  static const Color dangerFill = Color(0xFFFCEDE8);
  static const Color dangerStroke = Color(0xFFDF5953);
  static const Color dangerBadge = Color(0xFFDF514F);
  static const Color safeFill = Color(0xFFEBF4EE);
  static const Color safeStroke = Color(0xFF1B6943);
  static const Color safeBadge = Color(0xFF4B946A);
  static const Color counter = Color(0xFF8A8070);

  // --- design canvas ---
  static const Size canvas = Size(393, 846);

  /// Внутренняя «тетрадь» Flutter chrome (book.svg).
  static const double chromePageLeft = 40;
  static const double chromePageTop = 136;
  static const double chromePageWidth = 313;
  static const double chromePageBottom = 748;

  /// Ширина контента в эталонном SVG (карточки 30.5…363.5).
  static const double svgContentWidth = 333;

  /// Масштаб контента chrome → SVG.
  static double get contentScale => chromePageWidth / svgContentWidth;

  // --- cards (SVG units, «Книжка 2») ---
  static const double cardRadius = 13.5;
  static const double cardBorderWidth = 1.0;
  static const double cardHeight = 170;
  static const double cardDangerWidth = 160;
  static const double cardSafeWidth = 152;
  static const double cardGap = 19; // 211.5 - (30.5 + 160)
  static const double badgeRadius = 12.5;
  /// Центр badge почти на верхнем крае карточки → ~половина снаружи.
  static const double badgeOverflow = 11;
  static const double badgeLeftInset = 6; // 36.5 - 30.5

  // --- typography (читаемый body ≥ ~16 visual на chrome scale) ---
  static const double titleSize = 18;
  static const double cardTitleSize = 15;
  /// Body карточек: после contentScale ≈ 0.94 даёт ~15–16 sp.
  static const double cardBodySize = 16;
  static const double counterSize = 14;
  static const double promptSize = 15;

  // --- nav ---
  static const double arrowWidth = 126;
  static const double arrowHeight = 63;
  static const double arrowRadius = 11;

  // --- hero scene (между title и cards, SVG y≈200…478) ---
  static const double heroDesignHeight = 278;

  static Color fillFor(BookCardTone tone) => switch (tone) {
        BookCardTone.danger => dangerFill,
        BookCardTone.safe => safeFill,
        BookCardTone.mint => mint,
      };

  static Color strokeFor(BookCardTone tone) => switch (tone) {
        BookCardTone.danger => dangerStroke,
        BookCardTone.safe => safeStroke,
        BookCardTone.mint => titleGreen,
      };

  static Color badgeFor(BookCardTone tone) => switch (tone) {
        BookCardTone.danger => dangerBadge,
        BookCardTone.safe => safeBadge,
        BookCardTone.mint => arrowGreen,
      };
}

enum BookCardTone { danger, safe, mint }
