/// Гардероб Finzo: слоты, слои и полные варианты из исходников Group 102–112.
///
/// Холст всех SVG: viewBox `0 0 151 177`. Поза одна (жёлудь в лапах).
abstract final class WardrobeCatalog {
  static const canvasW = 151.0;
  static const canvasH = 177.0;

  static const baseAsset = 'assets/images/wardrobe/finzo_base.svg';

  /// Порядок = [ShopCatalog.clothesTitles] / индексы `c0…c7`.
  static const items = <WardrobeItem>[
    WardrobeItem(
      index: 0,
      title: 'Свитер',
      slot: WardrobeSlot.body,
      fullAsset: 'assets/images/wardrobe/full_sweater.svg',
      layerAsset: 'assets/images/wardrobe/layer_sweater.svg',
      layerReady: true,
    ),
    WardrobeItem(
      index: 1,
      title: 'Футболка',
      slot: WardrobeSlot.body,
      fullAsset: 'assets/images/wardrobe/full_tee.svg',
      layerAsset: 'assets/images/wardrobe/layer_tee.svg',
      layerReady: true,
    ),
    WardrobeItem(
      index: 2,
      title: 'Платье',
      slot: WardrobeSlot.body,
      fullAsset: 'assets/images/wardrobe/full_dress.svg',
      layerAsset: 'assets/images/wardrobe/layer_dress.svg',
      layerReady: true,
    ),
    WardrobeItem(
      index: 3,
      title: 'Очки',
      slot: WardrobeSlot.head,
      fullAsset: 'assets/images/wardrobe/full_goggles.svg',
      layerAsset: null,
      layerReady: false,
      designerNote: 'Нужен прозрачный слой очков без тела (цвета смешаны с контуром).',
    ),
    WardrobeItem(
      index: 4,
      title: 'Бант',
      slot: WardrobeSlot.head,
      fullAsset: 'assets/images/wardrobe/full_bow.svg',
      layerAsset: 'assets/images/wardrobe/layer_bow.svg',
      layerReady: true,
    ),
    WardrobeItem(
      index: 5,
      title: 'Худи',
      slot: WardrobeSlot.body,
      fullAsset: 'assets/images/wardrobe/full_hoodie.svg',
      layerAsset: 'assets/images/wardrobe/layer_hoodie.svg',
      layerReady: true,
    ),
    WardrobeItem(
      index: 6,
      title: 'Шляпа',
      slot: WardrobeSlot.head,
      fullAsset: 'assets/images/wardrobe/full_hat.svg',
      layerAsset: null,
      layerReady: false,
      designerNote:
          'Нужен прозрачный слой шляпы без тела (поля совпадают с цветом меха).',
    ),
    WardrobeItem(
      index: 7,
      title: 'Костюм',
      slot: WardrobeSlot.body,
      fullAsset: 'assets/images/wardrobe/full_suit.svg',
      layerAsset: 'assets/images/wardrobe/layer_suit.svg',
      layerReady: true,
    ),
  ];

  static WardrobeItem byIndex(int index) => items[index];

  static WardrobeItem? byKey(String? key) {
    if (key == null || key.isEmpty) return null;
    final m = RegExp(r'^c(\d+)$').firstMatch(key);
    if (m == null) return null;
    final i = int.tryParse(m.group(1)!);
    if (i == null || i < 0 || i >= items.length) return null;
    return items[i];
  }

  static String keyForIndex(int index) => 'c$index';
}

enum WardrobeSlot { body, head }

class WardrobeItem {
  const WardrobeItem({
    required this.index,
    required this.title,
    required this.slot,
    required this.fullAsset,
    required this.layerAsset,
    required this.layerReady,
    this.designerNote,
  });

  final int index;
  final String title;
  final WardrobeSlot slot;
  final String fullAsset;

  /// Прозрачный слой на общем холсте; null если нужен дизайнер.
  final String? layerAsset;
  final bool layerReady;
  final String? designerNote;

  String get shopKey => WardrobeCatalog.keyForIndex(index);
}
