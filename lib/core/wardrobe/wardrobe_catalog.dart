/// Гардероб Finzo: слоты и исходные SVG (Group 102–112).
///
/// Холст: viewBox `0 0 151 177`. Поза одна (жёлудь в лапах).
/// Стабильный ID вещи = `c{index}` ([shopKey]).
///
/// Ресурсы:
/// — [WardrobeItem.thumbAsset] — предмет в каталоге и во всех диалогах;
/// — [WardrobeItem.fullAsset] — целая белка в вещи (сцена / один слот);
/// — [WardrobeItem.accessoryLayerAsset] — векторный аксессуар поверх одежды.
abstract final class WardrobeCatalog {
  static const canvasW = 151.0;
  static const canvasH = 177.0;

  /// Ось головы/туловища в координатах viewBox (хвост справа не учитывается).
  /// Общая для базы, всей одежды и аксессуаров — поза одна.
  static const bodyAnchorX = 50.0;

  static const baseAsset = 'assets/images/wardrobe/finzo_base.svg';

  /// Порядок = [ShopCatalog.clothesTitles] / индексы `c0…c7`.
  /// Сопоставление с исходниками — по визуалу, не по номеру файла.
  static const items = <WardrobeItem>[
    WardrobeItem(
      index: 0,
      title: 'Свитер',
      slot: WardrobeSlot.body,
      sourceLabel: 'Group 110',
      fullAsset: 'assets/images/wardrobe/full_sweater.svg',
      thumbAsset: 'assets/images/house_inv_clothes/item_0.png',
    ),
    WardrobeItem(
      index: 1,
      title: 'Одежда',
      slot: WardrobeSlot.body,
      sourceLabel: 'Group 104',
      fullAsset: 'assets/images/wardrobe/full_tee.svg',
      thumbAsset: 'assets/images/house_inv_clothes/item_1.png',
    ),
    WardrobeItem(
      index: 2,
      title: 'Платье',
      slot: WardrobeSlot.body,
      sourceLabel: 'Group 111',
      fullAsset: 'assets/images/wardrobe/full_dress.svg',
      thumbAsset: 'assets/images/house_inv_clothes/item_2.png',
    ),
    WardrobeItem(
      index: 3,
      title: 'Очки',
      slot: WardrobeSlot.head,
      sourceLabel: 'Group 102',
      fullAsset: 'assets/images/wardrobe/full_goggles.svg',
      thumbAsset: 'assets/images/house_inv_clothes/item_3.png',
      accessoryLayerAsset: 'assets/images/wardrobe/layer_goggles.svg',
      accessoryLayerReady: true,
    ),
    WardrobeItem(
      index: 4,
      title: 'Бант',
      slot: WardrobeSlot.head,
      sourceLabel: 'Group 103',
      fullAsset: 'assets/images/wardrobe/full_bow.svg',
      thumbAsset: 'assets/images/house_inv_clothes/item_4.png',
      accessoryLayerAsset: 'assets/images/wardrobe/layer_bow.svg',
      accessoryLayerReady: true,
    ),
    WardrobeItem(
      index: 5,
      title: 'Худи',
      slot: WardrobeSlot.body,
      sourceLabel: 'Group 106',
      fullAsset: 'assets/images/wardrobe/full_hoodie.svg',
      thumbAsset: 'assets/images/house_inv_clothes/item_5.png',
    ),
    WardrobeItem(
      index: 6,
      title: 'Цилиндр',
      slot: WardrobeSlot.head,
      sourceLabel: 'Group 108',
      fullAsset: 'assets/images/wardrobe/full_hat.svg',
      thumbAsset: 'assets/images/house_inv_clothes/item_6.png',
      accessoryLayerAsset: 'assets/images/wardrobe/layer_hat.svg',
      accessoryLayerReady: true,
    ),
    WardrobeItem(
      index: 7,
      title: 'Костюм',
      slot: WardrobeSlot.body,
      sourceLabel: 'Group 112',
      fullAsset: 'assets/images/wardrobe/full_suit.svg',
      thumbAsset: 'assets/images/house_inv_clothes/item_7.png',
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

  /// Сдвиг, чтобы [bodyAnchorX] оказался в центре области шириной [displayWidth]
  /// при масштабе contain по холсту (высота не влияет на горизонталь).
  static double bodyAxisOffsetX({
    required double displayWidth,
    required double displayHeight,
  }) {
    final scale = _containScale(displayWidth, displayHeight);
    return (canvasW / 2 - bodyAnchorX) * scale;
  }

  static double _containScale(double w, double h) {
    final sx = w / canvasW;
    final sy = h / canvasH;
    return sx < sy ? sx : sy;
  }

  /// Заголовок окна снятия: «Снять очки?»
  static String unequipTitle(WardrobeItem item) {
    const accusative = <String, String>{
      'Одежда': 'одежду',
    };
    final name = accusative[item.title] ?? item.title.toLowerCase();
    return 'Снять $name?';
  }
}

enum WardrobeSlot { body, head }

class WardrobeItem {
  const WardrobeItem({
    required this.index,
    required this.title,
    required this.slot,
    required this.sourceLabel,
    required this.fullAsset,
    required this.thumbAsset,
    this.accessoryLayerAsset,
    this.accessoryLayerReady = false,
    this.designerNote,
  });

  final int index;
  final String title;
  final WardrobeSlot slot;

  /// Имя исходного файла (для отчёта), не для логики.
  final String sourceLabel;

  /// Целая белка в этой вещи (исходный SVG).
  final String fullAsset;

  /// Миниатюра предмета (каталог / все диалоги одежды).
  final String thumbAsset;

  /// Векторный слой аксессуара на том же холсте; только для head-слота.
  final String? accessoryLayerAsset;
  final bool accessoryLayerReady;
  final String? designerNote;

  String get shopKey => WardrobeCatalog.keyForIndex(index);

  /// Обратная совместимость со старыми тестами/кодом.
  @Deprecated('Use accessoryLayerAsset')
  String? get layerAsset => accessoryLayerAsset;

  @Deprecated('Use accessoryLayerReady')
  bool get layerReady => accessoryLayerReady;
}
