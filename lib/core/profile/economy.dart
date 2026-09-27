import 'budget_plan.dart';
import 'house_catalog.dart';

/// Экономика периода и каталог цен — вне UI.
abstract final class EconomyRules {
  /// Один объяснённый доход за период (карманные от родителей).
  static const periodIncome = 420;
  static const periodIncomeLabel = 'Карманные от родителей';

  /// Награда за учебное задание больше не денежная (навык в UI).
  /// Константа оставлена для совместимости старых тестов/доков.
  @Deprecated('Учебные задания не дают валюту')
  static const taskReward = 0;

  /// Стартовый баланс при онбординге = доход первого периода (не 650+300).
  static const onboardingBalance = periodIncome;
}

/// Позиция магазина дома.
class ShopItem {
  const ShopItem({
    required this.category,
    required this.index,
    required this.title,
    required this.price,
    required this.bucket,
    required this.satietyDelta,
    required this.moodDelta,
    required this.effectLabel,
  });

  final HouseItemCategory category;
  final int index;
  final String title;
  final int price;
  final BudgetBucket bucket;
  final double satietyDelta;
  final double moodDelta;
  final String effectLabel;

  String get key => HouseCatalog.key(category, index);

  String get bucketLabel => bucket.titleRu;

  bool get isStackable => category == HouseItemCategory.kitchen;

  int get maxQty => HouseCatalog.maxQty(category);
}

/// Каталог товаров с разными ценами (нельзя купить всё на один доход).
abstract final class ShopCatalog {
  /// Порядок = `AppAssets.houseInventory` (item_0…item_7).
  static const kitchenTitles = <String>[
    'Суп',
    'Паста',
    'Салат',
    'Пицца',
    'Мороженое',
    'Торт',
    'Вода',
    'Сок',
  ];

  static const clothesTitles = <String>[
    'Свитер',
    'Футболка',
    'Платье',
    'Очки',
    'Бант',
    'Худи',
    'Шляпа',
    'Костюм',
  ];

  static const showerTitles = <String>[
    'Шампунь',
    'Мыло',
    'Полотенце',
    'Зубная паста',
  ];

  /// Цены еды (необходимое), порядок = kitchenTitles / house_inv.
  static const kitchenPrices = <int>[50, 55, 45, 70, 40, 65, 25, 40];

  /// Цены одежды (желания) — дорого относительно дохода 420.
  static const clothesPrices = <int>[140, 110, 160, 90, 80, 150, 120, 200];

  /// Уход (необходимое).
  static const showerPrices = <int>[60, 75, 55, 50];

  static ShopItem item(HouseItemCategory category, int index) {
    return switch (category) {
      HouseItemCategory.kitchen => ShopItem(
          category: category,
          index: index,
          title: kitchenTitles[index],
          price: kitchenPrices[index],
          bucket: BudgetBucket.necessary,
          satietyDelta: 12 + (index % 3) * 2,
          moodDelta: index == 4 || index == 5 || index == 3 ? 4.0 : 0.0,
          effectLabel: index == 4 || index == 5
              ? 'Сытость +${12 + (index % 3) * 2}%, настроение +4%'
              : 'Сытость +${12 + (index % 3) * 2}%',
        ),
      HouseItemCategory.clothes => ShopItem(
          category: category,
          index: index,
          title: clothesTitles[index],
          price: clothesPrices[index],
          bucket: BudgetBucket.wants,
          satietyDelta: 0,
          moodDelta: 5.0,
          effectLabel: 'При первом надевании: +5 к настроению',
        ),
      HouseItemCategory.shower => ShopItem(
          category: category,
          index: index,
          title: showerTitles[index],
          price: showerPrices[index],
          bucket: BudgetBucket.necessary,
          satietyDelta: 0,
          moodDelta: 8.0 + index,
          effectLabel: 'Настроение +${8 + index}%, свежесть',
        ),
    };
  }

  static int priceOf(HouseItemCategory category, int index) =>
      item(category, index).price;

  static int maxAffordable(
    HouseItemCategory category,
    int index,
    int balance,
  ) {
    final price = priceOf(category, index);
    if (balance < price) return 0;
    if (category != HouseItemCategory.kitchen) return 1;
    return (balance ~/ price).clamp(1, HouseCatalog.maxQty(category));
  }

  /// Сумма всех товаров по 1 шт — для тестов «нельзя купить всё».
  static int get totalOneOfEach {
    var sum = 0;
    for (var i = 0; i < kitchenPrices.length; i++) {
      sum += kitchenPrices[i];
    }
    for (var i = 0; i < clothesPrices.length; i++) {
      sum += clothesPrices[i];
    }
    for (var i = 0; i < showerPrices.length; i++) {
      sum += showerPrices[i];
    }
    return sum;
  }
}
