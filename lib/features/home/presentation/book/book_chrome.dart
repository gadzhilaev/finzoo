import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/layout/design_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/presentation/widgets/onboarding_decor.dart';
import 'book_page_layout.dart';
import 'book_widgets.dart';

/// Каркас книжки: decor → book.svg → content column → arrows.
///
/// Внутренний fill страницы — из SVG (`#FEF7E6`). Отдельный почти-белый
/// прямоугольник не рисуем. Контент клипится, чтобы hero не утекал под карточки.
class BookChromeShell extends StatelessWidget {
  const BookChromeShell({
    super.key,
    required this.title,
    required this.pageLabel,
    required this.canBack,
    required this.canFwd,
    required this.onBack,
    required this.onFwd,
    required this.child,
    this.onHome,
    this.onBook,
    this.subtitle,
    this.bottomExtra,
  });

  final String title;
  final String? subtitle;
  final String pageLabel;
  final bool canBack;
  final bool canFwd;
  final VoidCallback onBack;
  final VoidCallback onFwd;
  final VoidCallback? onHome;
  final VoidCallback? onBook;
  final Widget child;
  final Widget? bottomExtra;

  /// Внутренняя «тетрадь» макета (внутри зелёной рамки).
  static const double pageLeft = 40;
  static const double pageTop = 136;
  static const double pageWidth = 313;
  static const double pageBottom = 748; // над стрелками
  static double get pageHeight => pageBottom - pageTop;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: DesignScale.designWidth,
              height: DesignScale.designHeight,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: IgnorePointer(child: OnboardingDecor()),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: SvgPicture.asset(
                        AppAssets.book,
                        fit: BoxFit.fill,
                        width: DesignScale.designWidth,
                        height: DesignScale.designHeight,
                      ),
                    ),
                  ),
                  // Кремовый fill страницы — из book.svg (#FEF7E6).
                  // Белка в book.svg — часть ассета дизайнера; не маскируем.
                  if (onHome != null)
                    Positioned(
                      left: 24,
                      top: 70,
                      width: 56,
                      height: 56,
                      child: Semantics(
                        button: true,
                        label: 'На главную',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onHome,
                        ),
                      ),
                    ),
                  if (onBook != null)
                    Positioned(
                      right: 24,
                      top: 70,
                      width: 56,
                      height: 56,
                      child: Semantics(
                        button: true,
                        label: 'Оглавление',
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onBook,
                        ),
                      ),
                    ),
                  Positioned(
                    left: pageLeft,
                    top: pageTop,
                    width: pageWidth,
                    height: pageHeight,
                    child: ColoredBox(
                      // Маска поверх book.svg: скрывает запечённую белку
                      // в зоне контента, не трогая исходный asset.
                      color: BookStyle.cream,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: BookType.pageTitle,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle!,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: BookType.callout,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Expanded(child: ClipRect(child: child)),
                          if (bottomExtra != null) ...[
                            const SizedBox(height: 8),
                            bottomExtra!,
                          ],
                          const SizedBox(height: 6),
                          Text(
                            pageLabel,
                            textAlign: TextAlign.center,
                            style: BookType.counter,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 64,
                    top: 764,
                    child: BookArrowButton(
                      forward: false,
                      enabled: canBack,
                      onTap: onBack,
                    ),
                  ),
                  Positioned(
                    left: 204,
                    top: 764,
                    child: BookArrowButton(
                      forward: true,
                      enabled: canFwd,
                      onTap: onFwd,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
