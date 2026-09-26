/// Каталог слотов дома: еда / одежда / душ.
enum HouseItemCategory { kitchen, clothes, shower }

abstract final class HouseCatalog {
  /// Цена слота в «доступно» (как в макете).
  static const itemPrice = 10;

  /// Сколько сытости даёт одна порция еды.
  static const foodSatietyBoost = 15.0;

  static const kitchenCount = 8;
  static const clothesCount = 8;
  static const showerCount = 4;

  static int countFor(HouseItemCategory category) => switch (category) {
        HouseItemCategory.kitchen => kitchenCount,
        HouseItemCategory.clothes => clothesCount,
        HouseItemCategory.shower => showerCount,
      };

  /// Еда — стопка; одежда и душ — максимум 1.
  static int maxQty(HouseItemCategory category) =>
      category == HouseItemCategory.kitchen ? 99 : 1;

  /// Сколько порций еды можно купить за текущий баланс.
  static int maxAffordableFood(int availableBalance) {
    if (availableBalance < itemPrice) return 0;
    return (availableBalance ~/ itemPrice).clamp(1, maxQty(HouseItemCategory.kitchen));
  }

  static String key(HouseItemCategory category, int index) {
    final prefix = switch (category) {
      HouseItemCategory.kitchen => 'k',
      HouseItemCategory.clothes => 'c',
      HouseItemCategory.shower => 's',
    };
    return '$prefix$index';
  }
}
