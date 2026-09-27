import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_fonts.dart';

/// Общие цвета книжки.
abstract final class BookStyle {
  static const cream = Color(0xFFFEF7E6);
  static const green = Color(0xFF1B6943);
  static const arrowGreen = Color(0xFF4B946A);
  static const arrowMuted = Color(0xFFA8C4B2);
  static const mint = Color(0xFFEBF4EE);
  static const orange = Color(0xFFDF9548);
  static const body = Color(0xFF4A4643);
  static const counter = Color(0xFF8A8070);
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
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          SvgPicture.asset(
            AppAssets.squirrel2,
            height: height * 0.92,
            fit: BoxFit.contain,
            allowDrawingOutsideViewBox: true,
          ),
          Positioned(
            right: 0,
            top: height * 0.08,
            child: Icon(
              Icons.search_rounded,
              size: height * 0.38,
              color: BookStyle.orange,
            ),
          ),
        ],
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
      Rect.fromLTWH(size.width * 0.08, size.height * 0.28, size.width * 0.84, size.height * 0.45),
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

/// Сценка: сверху персонаж/предмет, без пересечения с текстом страницы.
class BookHeroScene extends StatelessWidget {
  const BookHeroScene({
    super.key,
    required this.kind,
    this.compact = false,
  });

  final BookSceneKind kind;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final h = compact ? 120.0 : 168.0;
    // Для карточек сообщений даём больше высоты — текст не режется.
    final sceneH = kind == BookSceneKind.compareMessages ? h + 56 : h;
    return SizedBox(
      height: sceneH,
      width: double.infinity,
      child: switch (kind) {
        BookSceneKind.coverLoupe => _cover(h),
        BookSceneKind.compareMessages => _compare(sceneH),
        BookSceneKind.phoneLock => _phoneLock(h),
        BookSceneKind.inspectMessage => _inspect(h),
        BookSceneKind.prize => _prop(h, AppAssets.goalHeadphones, 'цель'),
        BookSceneKind.order => _prop(h, AppAssets.goalPlaystation, 'покупка'),
        BookSceneKind.calm => _squirrelOnly(h, AppAssets.squirrel2),
        BookSceneKind.alert => _bang(h),
        BookSceneKind.coins => _coins(h),
        BookSceneKind.plan => _plan(h),
      },
    );
  }

  Widget _cover(double h) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 5, child: BookFinzoLoupe(height: h - 28)),
              Expanded(flex: 4, child: BookLetterProp(height: h * 0.75)),
            ],
          ),
        ),
        Text(
          'Проверяй, чтоб быть в плюсе!',
          textAlign: TextAlign.center,
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: BookStyle.orange,
          ),
        ),
      ],
    );
  }

  Widget _compare(double h) {
    // Карточки сообщений — полный текст, без обрезки в крошечном Expanded.
    return SingleChildScrollView(
      child: Column(
        children: [
          BookFinzoLoupe(height: (h * 0.45).clamp(48, 80)),
          const SizedBox(height: 6),
          _miniMsg('Магазин', 'Ваш заказ готов', ok: true),
          const SizedBox(height: 6),
          _miniMsg('«Магазин»', 'Пришлите код из SMS…', ok: false),
        ],
      ),
    );
  }

  Widget _miniMsg(String from, String body, {required bool ok}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ok ? BookStyle.mint : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ok ? BookStyle.green : BookStyle.orange,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            from,
            softWrap: true,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: ok ? BookStyle.green : BookStyle.orange,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            body,
            softWrap: true,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              height: 1.3,
              color: BookStyle.body,
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneLock(double h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppAssets.squirrel2,
          height: h * 0.92,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Container(
          width: 72,
          height: h * 0.85,
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BookStyle.green, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, color: BookStyle.orange, size: h * 0.28),
              const SizedBox(height: 4),
              Text(
                '•••',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
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
        BookLetterProp(height: h * 0.72),
      ],
    );
  }

  Widget _prop(double h, String image, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          AppAssets.squirrel,
          height: h * 0.9,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 12),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, height: h * 0.55, fit: BoxFit.contain),
            Text(
              label,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: BookStyle.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _squirrelOnly(double h, String asset) {
    return Center(
      child: SvgPicture.asset(asset, height: h * 0.95, fit: BoxFit.contain),
    );
  }

  Widget _coins(double h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(AppAssets.squirrel2, height: h * 0.88, fit: BoxFit.contain),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.savings_outlined, size: h * 0.4, color: BookStyle.orange),
            Text('остаток', style: AppFonts.rubik(fontWeight: FontWeight.w600, fontSize: 12, color: BookStyle.green)),
          ],
        ),
      ],
    );
  }

  Widget _plan(double h) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(AppAssets.squirrel, height: h * 0.85, fit: BoxFit.contain),
        const SizedBox(width: 8),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _chip('нужное'),
            _chip('желания'),
            _chip('копилка'),
          ],
        ),
      ],
    );
  }

  Widget _chip(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: BookStyle.mint,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BookStyle.green),
      ),
      child: Text(
        t,
        style: AppFonts.rubik(
          fontWeight: FontWeight.w700,
          fontSize: 12,
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
        Icon(Icons.priority_high_rounded, size: h * 0.55, color: BookStyle.orange),
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
    final bg = enabled ? BookStyle.arrowGreen : BookStyle.arrowMuted;
    final arrow = enabled ? Colors.white : const Color(0xFFF3F9F5);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Center(
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
        ),
      ),
    );
  }
}
