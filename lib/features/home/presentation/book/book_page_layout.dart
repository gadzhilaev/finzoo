import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/finzo_book_tokens.dart';

/// Размер hero-слота: иллюстрация — отдельный блок между title и cards.
enum BookHeroSize { none, small, medium, large }

/// Единая вертикальная композиция страницы книжки / growth guide.
///
/// Title и counter рисует [BookChromeShell]. Здесь:
/// Flexible hero → body → trailing → breathing Spacer.
class BookPageLayout extends StatelessWidget {
  const BookPageLayout({
    super.key,
    this.hero,
    this.heroSize = BookHeroSize.medium,
    required this.body,
    this.trailing,
    this.scrollable = false,
  });

  final Widget? hero;
  final BookHeroSize heroSize;
  final Widget body;
  final Widget? trailing;
  final bool scrollable;

  /// Целевая высота hero (SVG-пропорции); фактическая может сжаться.
  static double heroHeight(BookHeroSize size) => switch (size) {
        BookHeroSize.none => 0,
        BookHeroSize.small => 72,
        BookHeroSize.medium => 110,
        // ~278 SVG-единиц × contentScale ≈ 261; оставляем запас под cards.
        BookHeroSize.large => 220,
      };

  @override
  Widget build(BuildContext context) {
    if (scrollable) {
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hero != null && heroSize != BookHeroSize.none) ...[
              SizedBox(
                height: heroHeight(heroSize),
                width: double.infinity,
                child: ClipRect(child: hero),
              ),
              const SizedBox(height: 8),
            ],
            body,
            if (trailing != null) ...[const SizedBox(height: 8), trailing!],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hero != null && heroSize != BookHeroSize.none) ...[
          Flexible(
            flex: 6,
            child: LayoutBuilder(
              builder: (context, c) {
                final target = heroHeight(heroSize);
                final h = c.maxHeight.clamp(0.0, target);
                if (h <= 0) return const SizedBox.shrink();
                return SizedBox(
                  height: h,
                  width: double.infinity,
                  child: ClipRect(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: FinzoBookTokens.chromePageWidth,
                        height: target,
                        child: hero,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 6),
        ],
        body,
        if (trailing != null) ...[const SizedBox(height: 6), trailing!],
        const Spacer(flex: 1),
      ],
    );
  }
}

/// Единая типографика книжки (измерено по макету).
abstract final class BookType {
  static TextStyle get pageTitle => AppFonts.rubik(
        fontWeight: FontWeight.w800,
        fontSize: FinzoBookTokens.titleSize,
        height: 1.15,
        color: FinzoBookTokens.titleGreen,
      );

  static TextStyle get section => AppFonts.rubik(
        fontWeight: FontWeight.w700,
        fontSize: 14,
        height: 1.25,
        color: FinzoBookTokens.titleGreen,
      );

  static TextStyle get cardTitle => AppFonts.rubik(
        fontWeight: FontWeight.w700,
        fontSize: FinzoBookTokens.cardTitleSize,
        height: 1.2,
        color: FinzoBookTokens.titleGreen,
      );

  static TextStyle get body => AppFonts.rubik(
        fontWeight: FontWeight.w500,
        fontSize: 15,
        height: 1.35,
        color: FinzoBookTokens.body,
      );

  static TextStyle get hint => AppFonts.rubik(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        height: 1.3,
        color: FinzoBookTokens.counter,
      );

  static TextStyle get callout => AppFonts.rubik(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 1.3,
        color: FinzoBookTokens.squirrelOrange,
      );

  static TextStyle get counter => AppFonts.rubik(
        fontWeight: FontWeight.w700,
        fontSize: FinzoBookTokens.counterSize,
        color: FinzoBookTokens.titleGreen,
      );

  static TextStyle get prompt => AppFonts.rubik(
        fontWeight: FontWeight.w600,
        fontSize: FinzoBookTokens.promptSize,
        height: 1.35,
        color: FinzoBookTokens.titleGreen,
      );
}

/// Hero из дизайнерского ассета (PNG/SVG-сцена, не Material Icon).
class BookAssetHero extends StatelessWidget {
  const BookAssetHero({super.key, required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    final w = FinzoBookTokens.chromePageWidth;
    final h = FinzoBookTokens.heroDesignHeight * FinzoBookTokens.contentScale;
    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        width: w,
        height: h,
        fit: BoxFit.contain,
      );
    }
    return Image.asset(
      asset,
      width: w,
      height: h,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
