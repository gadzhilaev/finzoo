/// Ключи слотов дома (совместимость с инвентарём профиля).
enum HouseItemCategory { kitchen, clothes, shower }

abstract final class HouseCatalog {
  static const kitchenCount = 8;
  static const clothesCount = 8;
  static const showerCount = 4;

  /// Сколько сытости даёт еда по умолчанию (точные значения — в ShopCatalog).
  static const foodSatietyBoost = 15.0;

  static int countFor(HouseItemCategory category) => switch (category) {
        HouseItemCategory.kitchen => kitchenCount,
        HouseItemCategory.clothes => clothesCount,
        HouseItemCategory.shower => showerCount,
      };

  /// Еда — стопка; одежда и душ — максимум 1.
  static int maxQty(HouseItemCategory category) =>
      category == HouseItemCategory.kitchen ? 99 : 1;

  static String key(HouseItemCategory category, int index) {
    final prefix = switch (category) {
      HouseItemCategory.kitchen => 'k',
      HouseItemCategory.clothes => 'c',
      HouseItemCategory.shower => 's',
    };
    return '$prefix$index';
  }
}
