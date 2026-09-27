import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../profile/player_profile.dart';
import 'wardrobe_catalog.dart';

/// Finzo с надетым комплектом (одежда + головной убор).
///
/// Одна поза дома и на улице. Не складывает два полных SVG белки:
/// — один слот → полный вариант вещи;
/// — оба слота → база + прозрачные слои (если слой готов).
class FinzoAvatar extends StatelessWidget {
  const FinzoAvatar({
    super.key,
    required this.profile,
    this.width = 151,
    this.height = 177,
    this.previewBodyKey,
    this.previewHeadKey,
    this.fit = BoxFit.contain,
  });

  final PlayerProfile profile;
  final double width;
  final double height;

  /// Примерка до покупки — не пишется в профиль.
  final String? previewBodyKey;
  final String? previewHeadKey;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final body = WardrobeCatalog.byKey(previewBodyKey ?? profile.equippedBodyKey);
    final head = WardrobeCatalog.byKey(previewHeadKey ?? profile.equippedHeadKey);

    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: fit,
        child: SizedBox(
          width: WardrobeCatalog.canvasW,
          height: WardrobeCatalog.canvasH,
          child: _compose(body: body, head: head),
        ),
      ),
    );
  }

  Widget _compose({WardrobeItem? body, WardrobeItem? head}) {
    if (body == null && head == null) {
      return _svg(WardrobeCatalog.baseAsset);
    }

    // Только одежда — полный чистый кадр.
    if (body != null && head == null) {
      return _svg(body.fullAsset);
    }

    // Только головной убор.
    if (body == null && head != null) {
      if (head.layerReady && head.layerAsset != null) {
        return Stack(
          fit: StackFit.expand,
          children: [
            _svg(WardrobeCatalog.baseAsset),
            _svg(head.layerAsset!),
          ],
        );
      }
      // Очки/шляпа без слоя: один полный кадр (не поверх другой белки).
      return _svg(head.fullAsset);
    }

    // Оба слота.
    final bodyItem = body!;
    final headItem = head!;

    if (bodyItem.layerReady &&
        bodyItem.layerAsset != null &&
        headItem.layerReady &&
        headItem.layerAsset != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _svg(WardrobeCatalog.baseAsset),
          _svg(bodyItem.layerAsset!),
          _svg(headItem.layerAsset!),
        ],
      );
    }

    // Есть слой одежды, головной убор без слоя — показываем одежду честно.
    if (bodyItem.layerReady && bodyItem.layerAsset != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _svg(WardrobeCatalog.baseAsset),
          _svg(bodyItem.layerAsset!),
        ],
      );
    }

    // Есть слой головы, одежда без слоя — полный кадр одежды + слой головы.
    if (headItem.layerReady && headItem.layerAsset != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _svg(bodyItem.fullAsset),
          _svg(headItem.layerAsset!),
        ],
      );
    }

    // Оба без комбинируемых слоёв — только одежда (не два полных кадра).
    return _svg(bodyItem.fullAsset);
  }

  Widget _svg(String asset) {
    return SvgPicture.asset(
      asset,
      width: WardrobeCatalog.canvasW,
      height: WardrobeCatalog.canvasH,
      fit: BoxFit.fill,
      placeholderBuilder: (_) => const SizedBox.expand(),
    );
  }
}
