import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../profile/player_profile.dart';
import 'wardrobe_catalog.dart';

/// Finzo с надетым комплектом (одежда + головной убор).
///
/// Единый способ для дома и улицы:
/// — ничего: [WardrobeCatalog.baseAsset];
/// — только одежда / только аксессуар: целый исходный SVG вещи;
/// — оба слота: целый SVG одежды + слой аксессуара.
///
/// Горизонталь: ось туловища ([WardrobeCatalog.bodyAnchorX]), не bbox с хвостом.
/// Не складывает две полные белки и не использует растровые вырезки.
class FinzoAvatar extends StatelessWidget {
  const FinzoAvatar({
    super.key,
    required this.profile,
    this.width = 151,
    this.height = 177,
    this.previewBodyKey,
    this.previewHeadKey,
    this.fit = BoxFit.contain,
    this.alignBodyAxis = true,
    this.bodyAxisFactor = 1.0,
  });

  final PlayerProfile profile;
  final double width;
  final double height;

  /// Превью — подменяет слот; второй слот из профиля.
  final String? previewBodyKey;
  final String? previewHeadKey;
  final BoxFit fit;

  /// Сдвигать так, чтобы ось тела была в центре [width], хвост справа.
  final bool alignBodyAxis;

  /// Доля сдвига по оси тела: `1` — полное центрирование туловища,
  /// `0` — центр bbox. Для компактных карточек удобно ~0.5–0.6.
  final double bodyAxisFactor;

  @override
  Widget build(BuildContext context) {
    final body = WardrobeCatalog.byKey(
      previewBodyKey ?? profile.equippedBodyKey ?? profile.starterBodyKey,
    );
    final head = WardrobeCatalog.byKey(
      previewHeadKey ?? profile.equippedHeadKey ?? profile.starterHeadKey,
    );

    final child = Align(
      alignment: Alignment.bottomCenter,
      child: Transform.scale(
        scale: profile.growthVisualScale,
        alignment: Alignment.bottomCenter,
        child: FittedBox(
          fit: fit,
          child: SizedBox(
            width: WardrobeCatalog.canvasW,
            height: WardrobeCatalog.canvasH,
            child: _compose(body: body, head: head),
          ),
        ),
      ),
    );

    if (!alignBodyAxis) {
      return SizedBox(width: width, height: height, child: child);
    }

    final dx = WardrobeCatalog.bodyAxisOffsetX(
      displayWidth: width,
      displayHeight: height,
    ) * bodyAxisFactor.clamp(0.0, 1.0);

    // Без ClipRect: хвост может выйти за правый край бокса (сцена Clip.none).
    return SizedBox(
      width: width,
      height: height,
      child: Transform.translate(offset: Offset(dx, 0), child: child),
    );
  }

  Widget _compose({WardrobeItem? body, WardrobeItem? head}) {
    if (body == null && head == null) {
      return _svg(WardrobeCatalog.baseAsset);
    }

    if (body != null && head == null) {
      return _svg(body.fullAsset);
    }

    if (body == null && head != null) {
      return _svg(head.fullAsset);
    }

    final bodyItem = body!;
    final headItem = head!;

    // В исходнике очков оправа не отделена от меха отдельными path. Вместо
    // самодельной круглой оправы используем точно тот же участок исходного
    // SVG: прямоугольник покрывает только лицо и очки, не добавляя вторую
    // белку или часть одежды поверх комплекта.
    if (headItem.shopKey == 'c3') {
      return Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          _svg(bodyItem.fullAsset),
          ClipPath(
            clipper: const _GogglesSourceClipper(),
            child: _svg(headItem.fullAsset),
          ),
        ],
      );
    }

    if (headItem.accessoryLayerReady && headItem.accessoryLayerAsset != null) {
      return Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          _svg(bodyItem.fullAsset),
          _svg(headItem.accessoryLayerAsset!),
        ],
      );
    }

    // Слой не готов — не прячем слот молча подменой и не кладём вторую белку.
    return _svg(bodyItem.fullAsset);
  }

  Widget _svg(String asset) {
    return SvgPicture.asset(
      asset,
      width: WardrobeCatalog.canvasW,
      height: WardrobeCatalog.canvasH,
      fit: BoxFit.fill,
      placeholderBuilder: (_) => const SizedBox.expand(),
      alignment: Alignment.center,
    );
  }
}

/// Область исходной оправы `Group 102.svg` на полотне 151×177.
class _GogglesSourceClipper extends CustomClipper<Path> {
  const _GogglesSourceClipper();

  @override
  Path getClip(Size size) {
    const source = Rect.fromLTWH(4, 59, 94, 37);
    final sx = size.width / WardrobeCatalog.canvasW;
    final sy = size.height / WardrobeCatalog.canvasH;
    return Path()..addRect(
      Rect.fromLTWH(
        source.left * sx,
        source.top * sy,
        source.width * sx,
        source.height * sy,
      ),
    );
  }

  @override
  bool shouldReclip(covariant _GogglesSourceClipper oldClipper) => false;
}

/// Короткая подпись стадии, которую ребёнок видит рядом с питомцем.
class FinzoGrowthChip extends StatelessWidget {
  const FinzoGrowthChip({super.key, required this.profile, this.onTap});

  final PlayerProfile profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final stage = profile.growthStage;
    final icon = switch (stage) {
      PetGrowthStage.little => Icons.looks_one_rounded,
      PetGrowthStage.growing => Icons.looks_two_rounded,
      PetGrowthStage.confident => Icons.looks_3_rounded,
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF7E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1B6943), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF1B6943)),
              const SizedBox(width: 3),
              Text(
                stage.title.replaceFirst(' Finzo', ''),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B6943),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
