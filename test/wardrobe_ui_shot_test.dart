import 'dart:io';

import 'package:finzoo/core/profile/economy.dart';
import 'package:finzoo/core/profile/house_catalog.dart';
import 'package:finzoo/core/wardrobe/wardrobe_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog titles, thumbs, full SVG and accessory layers', () {
    expect(WardrobeCatalog.byIndex(1).title, 'Одежда');
    expect(WardrobeCatalog.byIndex(6).title, 'Цилиндр');
    expect(ShopCatalog.clothesTitles[1], 'Одежда');
    expect(ShopCatalog.clothesTitles[6], 'Цилиндр');
    expect(WardrobeCatalog.unequipTitle(WardrobeCatalog.byIndex(3)), 'Снять очки?');
    expect(WardrobeCatalog.unequipTitle(WardrobeCatalog.byIndex(1)), 'Снять одежду?');

    for (final item in WardrobeCatalog.items) {
      expect(item.shopKey, 'c${item.index}');
      expect(item.thumbAsset, contains('house_inv_clothes/item_${item.index}'));
      expect(File(item.fullAsset).existsSync(), isTrue, reason: item.fullAsset);
      expect(File(item.thumbAsset).existsSync(), isTrue);
      expect(item.fullAsset.toLowerCase().endsWith('.svg'), isTrue);
      if (item.slot == WardrobeSlot.head && item.accessoryLayerReady) {
        expect(item.accessoryLayerAsset, isNotNull);
        expect(File(item.accessoryLayerAsset!).existsSync(), isTrue);
        expect(item.accessoryLayerAsset!.toLowerCase().endsWith('.svg'), isTrue);
      }
    }

    expect(WardrobeCatalog.byIndex(3).accessoryLayerReady, isTrue);
    expect(WardrobeCatalog.byIndex(3).accessoryLayerAsset, endsWith('layer_goggles.svg'));
    expect(WardrobeCatalog.byIndex(4).accessoryLayerReady, isTrue);
    expect(WardrobeCatalog.byIndex(6).accessoryLayerReady, isTrue);
    expect(WardrobeCatalog.bodyAnchorX, lessThan(WardrobeCatalog.canvasW / 2));
    expect(
      WardrobeCatalog.bodyAxisOffsetX(displayWidth: 156, displayHeight: 182),
      greaterThan(20),
    );
    expect(HouseCatalog.key(HouseItemCategory.clothes, 3), 'c3');
  });
}
