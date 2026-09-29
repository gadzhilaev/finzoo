import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/finzo_book_tokens.dart';
import 'book_lesson_card.dart';
import 'book_page_layout.dart';

/// Общие цвета книжки (алиасы на [FinzoBookTokens]).
abstract final class BookStyle {
  static const pageCream = FinzoBookTokens.pageCream;
  static const cream = FinzoBookTokens.notebookCream;
  static const green = FinzoBookTokens.titleGreen;
  static const greenDark = FinzoBookTokens.titleGreen;
  static const arrowGreen = FinzoBookTokens.arrowGreen;
  static const arrowMuted = Color(0xFFA8C4B2);
  static const mint = FinzoBookTokens.mint;
  static const orange = FinzoBookTokens.squirrelOrange;
  static const body = FinzoBookTokens.body;
  static const ink = FinzoBookTokens.ink;
  static const inkSoft = FinzoBookTokens.inkSoft;
  static const stroke = FinzoBookTokens.arrowGreen;
  static const counter = FinzoBookTokens.counter;
  static const quizDangerFill = FinzoBookTokens.dangerFill;
  static const quizDangerStroke = FinzoBookTokens.dangerStroke;
}

/// Мятная info-карточка: заголовок + короткий текст.
class BookInfoCard extends StatelessWidget {
  const BookInfoCard({super.key, required this.body, this.title});

  final String body;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return BookTipCard(title: title, text: body);
  }
}

/// Крупная зелёная CTA внизу страницы книжки.
class BookPrimaryButton extends StatelessWidget {
  const BookPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: BookStyle.arrowGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          label,
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Одна мятная плашка с несколькими пунктами (не отдельная карточка на каждую фразу).
class BookTipGroup extends StatelessWidget {
  const BookTipGroup({super.key, required this.items});

  final List<({String? title, String text})> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: BookStyle.mint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BookStyle.green.withValues(alpha: 0.55)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: BookStyle.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: items[i].title == null
                      ? Text(
                          items[i].text,
                          style: AppFonts.rubik(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.3,
                            color: BookStyle.body,
                          ),
                        )
                      : Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${items[i].title!} ',
                                style: AppFonts.rubik(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: BookStyle.green,
                                ),
                              ),
                              TextSpan(
                                text: items[i].text,
                                style: AppFonts.rubik(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  height: 1.3,
                                  color: BookStyle.body,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Отдельная мятная карточка (обложка / варианты ответа).
class BookTipCard extends StatelessWidget {
  const BookTipCard({
    super.key,
    required this.text,
    this.title,
    this.selected = false,
    this.onTap,
    this.trailing,
  });

  final String text;
  final String? title;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFDCEFE3) : BookStyle.mint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? BookStyle.green
              : BookStyle.green.withValues(alpha: 0.55),
          width: selected ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 3),
            decoration: const BoxDecoration(
              color: BookStyle.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    softWrap: true,
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      height: 1.25,
                      color: BookStyle.green,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  text,
                  softWrap: true,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.35,
                    color: BookStyle.body,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );
    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
    );
  }
}

/// Вырезка из полноэкранного SVG (393×852) без крошечных артефактов масштаба.
class BookArtCrop extends StatelessWidget {
  const BookArtCrop({
    super.key,
    required this.asset,
    required this.src,
    required this.height,
    this.width,
  });

  final String asset;
  final Rect src;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final w = width ?? height * (src.width / src.height);
    return SizedBox(
      width: w,
      height: height,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: 393,
          maxHeight: 852,
          alignment: Alignment.topLeft,
          child: Transform.translate(
            offset: Offset(-src.left, -src.top),
            child: SvgPicture.asset(
              asset,
              width: 393,
              height: 852,
              fit: BoxFit.fill,
              allowDrawingOutsideViewBox: true,
            ),
          ),
        ),
      ),
    );
  }
}

/// Finzo-персонаж: целый SVG белки, без прямоугольного кропа сцены.
class BookFinzoLoupe extends StatelessWidget {
  const BookFinzoLoupe({super.key, required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? height * 0.95,
      height: height,
      child: ClipRect(
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          children: [
            SvgPicture.asset(
              AppAssets.squirrel2,
              height: height * 0.9,
              fit: BoxFit.contain,
            ),
            Positioned(
              right: 0,
              top: height * 0.08,
              child: Icon(
                Icons.search_rounded,
                size: height * 0.32,
                color: BookStyle.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Конверт без непрозрачного прямоугольника из общей сцены.
class BookLetterProp extends StatelessWidget {
  const BookLetterProp({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: height * 0.85,
      height: height,
      child: CustomPaint(painter: _LetterPainter()),
    );
  }
}

class _LetterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFF4B4A48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fill = Paint()..color = const Color(0xFFFEFCF4);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.28,
        size.width * 0.84,
        size.height * 0.45,
      ),
      const Radius.circular(10),
    );
    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.5);
    canvas.rotate(-0.22);
    canvas.translate(-size.width * 0.5, -size.height * 0.5);
    canvas.drawRRect(r, fill);
    canvas.drawRRect(r, stroke);
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.42)
      ..lineTo(size.width * 0.5, size.height * 0.55)
      ..lineTo(size.width * 0.82, size.height * 0.38);
    canvas.drawPath(path, stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Сценка: отдельный layout-slot, всегда клипится, без watermark.
class BookHeroScene extends StatelessWidget {
  const BookHeroScene({
    super.key,
    required this.kind,
    this.size = BookHeroSize.medium,
  });

  final BookSceneKind kind;
  final BookHeroSize size;

  @override
  Widget build(BuildContext context) {
    if (size == BookHeroSize.none) return const SizedBox.shrink();
    final h = BookPageLayout.heroHeight(size);
    return SizedBox(
      height: h,
      width: double.infinity,
      child: ClipRect(
        child: switch (kind) {
          BookSceneKind.coverLoupe => _cover(h),
          BookSceneKind.compareMessages => _simpleSquirrel(h),
          BookSceneKind.phoneLock => _phoneLock(h),
          BookSceneKind.inspectMessage => _inspect(h),
          BookSceneKind.prize => _prop(h, AppAssets.goalHeadphones, 'цель'),
          BookSceneKind.order => _prop(h, AppAssets.goalPlaystation, 'покупка'),
          BookSceneKind.calm => _simpleSquirrel(h),
          BookSceneKind.alert => _bang(h),
          BookSceneKind.coins => _coins(h),
          BookSceneKind.plan => _plan(h),
        },
      ),
    );
  }

  Widget _cover(double h) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(flex: 5, child: BookFinzoLoupe(height: h * 0.95)),
        Expanded(flex: 4, child: BookLetterProp(height: h * 0.72)),
      ],
    );
  }

  Widget _simpleSquirrel(double h) {
    return Center(
      child: SvgPicture.asset(
        AppAssets.squirrel2,
        height: h * 0.92,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _phoneLock(double h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppAssets.squirrel2,
          height: h * 0.9,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Container(
          width: 56,
          height: h * 0.82,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: BookStyle.green, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, color: BookStyle.orange, size: h * 0.28),
              Text(
                '•••',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _inspect(double h) {
    return Row(
      children: [
        Expanded(child: BookFinzoLoupe(height: h * 0.95)),
        BookLetterProp(height: h * 0.7),
      ],
    );
  }

  Widget _prop(double h, String image, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppAssets.squirrel,
          height: h * 0.88,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: h * 0.48, fit: BoxFit.contain),
            Text(
              label,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: BookStyle.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _coins(double h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppAssets.squirrel2,
          height: h * 0.88,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: h * 0.36,
              color: BookStyle.orange,
            ),
            Text(
              'остаток',
              style: AppFonts.rubik(
                fontWeight: FontWeight.w600,
                fontSize: 11,
                color: BookStyle.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _plan(double h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppAssets.squirrel,
          height: h * 0.85,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [_chip('нужное'), _chip('желания'), _chip('копилка')],
        ),
      ],
    );
  }

  Widget _chip(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: BookStyle.mint,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BookStyle.green.withValues(alpha: 0.55)),
      ),
      child: Text(
        t,
        style: AppFonts.rubik(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: BookStyle.green,
        ),
      ),
    );
  }

  Widget _bang(double h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppAssets.squirrel2,
          height: h * 0.85,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.priority_high_rounded,
          size: h * 0.45,
          color: BookStyle.orange,
        ),
      ],
    );
  }
}

enum BookSceneKind {
  coverLoupe,
  compareMessages,
  phoneLock,
  inspectMessage,
  prize,
  order,
  calm,
  alert,
  coins,
  plan,
}

/// Две широкие кнопки: один SVG из макета, зеркало для влево.
class BookArrowButton extends StatelessWidget {
  const BookArrowButton({
    super.key,
    required this.forward,
    required this.enabled,
    required this.onTap,
  });

  final bool forward;
  final bool enabled;
  final VoidCallback onTap;

  static const size = Size(126, 63);

  @override
  Widget build(BuildContext context) {
    // Один слой: enabled → arrowGreen, disabled → muted. Без наложения.
    final bg = enabled ? BookStyle.arrowGreen : BookStyle.arrowMuted;
    final arrow = enabled ? Colors.white : const Color(0xFFE8F0EB);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: size.width,
        height: size.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(FinzoBookTokens.arrowRadius),
        ),
        child: Transform.flip(
          flipX: !forward,
          child: SvgPicture.asset(
            AppAssets.bookArrowRight,
            width: 50,
            height: 28,
            colorFilter: ColorFilter.mode(arrow, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

/// Нумерованная mint-карточка (обёртка над [BookLessonCard]).
class BookNumberedCard extends StatelessWidget {
  const BookNumberedCard({
    super.key,
    required this.number,
    required this.title,
    required this.text,
    this.illustration,
  });

  final int number;
  final String title;
  final String text;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    return BookLessonCard(
      number: number,
      tone: BookCardTone.mint,
      title: title,
      text: text,
      illustration: illustration,
    );
  }
}

/// Пара «опасно / безопасно» (обёртка над [BookLessonCard]).
class BookToneCard extends StatelessWidget {
  const BookToneCard({
    super.key,
    required this.danger,
    required this.title,
    required this.text,
    this.number,
    this.illustration,
  });

  final bool danger;
  final String title;
  final String text;
  final int? number;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    return BookLessonCard(
      number: number ?? (danger ? 1 : 2),
      tone: danger ? BookCardTone.danger : BookCardTone.safe,
      title: title,
      text: text,
      illustration: illustration,
    );
  }
}

/// Квиз-кнопка «Мошенник» / «Настоящий магазин» (референс обучение.zip).
class BookQuizChoice extends StatelessWidget {
  const BookQuizChoice({
    super.key,
    required this.label,
    required this.danger,
    required this.selected,
    required this.onTap,
    this.revealed = false,
  });

  final String label;
  final bool danger;
  final bool selected;
  final VoidCallback onTap;

  /// После «Проверить»: danger/safe цвет. До — нейтральный выбранный стиль.
  final bool revealed;

  static const _radius = 13.5; // FinzoBookTokens.cardRadius — «Книжка 4/5»

  @override
  Widget build(BuildContext context) {
    final Color stroke;
    final Color fill;
    if (revealed) {
      stroke = danger ? BookStyle.quizDangerStroke : BookStyle.green;
      fill = danger ? BookStyle.quizDangerFill : BookStyle.mint;
    } else if (selected) {
      stroke = BookStyle.green;
      fill = BookStyle.mint;
    } else {
      stroke = BookStyle.green.withValues(alpha: 0.35);
      fill = Colors.white.withValues(alpha: 0.55);
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: stroke, width: selected ? 2 : 1.2),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: revealed
                  ? stroke
                  : (selected ? BookStyle.green : BookStyle.body),
            ),
          ),
        ),
      ),
    );
  }
}
