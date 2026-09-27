import 'package:flutter/material.dart';

/// Карточка практики «Практика с Finzo».
class PracticeItem {
  const PracticeItem({
    required this.id,
    required this.title,
    required this.topic,
    required this.blurb,
    required this.icon,
    required this.theme,
    this.imageAsset,
  });

  final String id;
  final String title;
  final String topic;
  final String blurb;
  final IconData icon;
  final PracticeTheme theme;
  final String? imageAsset;
}

enum PracticeTheme { budget, savings, payments }

/// Каталог из 6 финансовых заданий (ТЗ §2.5.8).
abstract final class PracticeCatalog {
  static const lunch = 'practice_lunch';
  static const dayPlan = 'practice_day_plan';
  static const dreamSave = 'practice_dream_save';
  static const planChange = 'practice_plan_change';
  static const deal = 'practice_deal';
  static const receipt = 'practice_receipt';

  /// Старые аркадные / ещё более старые ID → новое задание (только для открытия ссылок).
  /// Не используются для засчёта прогресса.
  static const openAliases = <String, String>{
    'park_bike': dayPlan,
    'park_club': lunch,
    'park_music': dreamSave,
    'park_boat': planChange,
    'park_tennis': deal,
    'park_fish': receipt,
    'budget_split': dayPlan,
    'budget_fun': lunch,
    'save_pick': dreamSave,
    'save_withdraw': planChange,
    'shop_basket': deal,
    'shop_compare': receipt,
  };

  static const all = <PracticeItem>[
    PracticeItem(
      id: lunch,
      title: 'Собери обед',
      topic: 'Бюджет',
      blurb: 'Блюдо и напиток в пределах 80 монет.',
      icon: Icons.lunch_dining_rounded,
      theme: PracticeTheme.budget,
      imageAsset: 'assets/images/house_inv/item_0.png',
    ),
    PracticeItem(
      id: dayPlan,
      title: 'План на день',
      topic: 'Бюджет',
      blurb: 'Разложи монеты: нужное, желания, копилка.',
      icon: Icons.pie_chart_outline_rounded,
      theme: PracticeTheme.budget,
      imageAsset: 'assets/images/ruble_mark.svg',
    ),
    PracticeItem(
      id: dreamSave,
      title: 'Копим на мечту',
      topic: 'Сбережения',
      blurb: 'Отложи после нужного — копилка растёт.',
      icon: Icons.savings_outlined,
      theme: PracticeTheme.savings,
      imageAsset: 'assets/images/goals/bicycle.png',
    ),
    PracticeItem(
      id: planChange,
      title: 'Изменились планы',
      topic: 'Сбережения',
      blurb: 'Свободные деньги, покупка и остаток копилки.',
      icon: Icons.event_busy_rounded,
      theme: PracticeTheme.savings,
      imageAsset: 'assets/images/house_inv/item_3.png',
    ),
    PracticeItem(
      id: deal,
      title: 'Выгодная покупка',
      topic: 'Платежи',
      blurb: 'Два прилавка — сравни сумму комплекта.',
      icon: Icons.storefront_rounded,
      theme: PracticeTheme.payments,
      imageAsset: 'assets/images/goals/tennis.png',
    ),
    PracticeItem(
      id: receipt,
      title: 'Проверь чек',
      topic: 'Платежи',
      blurb: 'Сверь предметы с чеком и убери лишнее.',
      icon: Icons.receipt_long_rounded,
      theme: PracticeTheme.payments,
      imageAsset: 'assets/images/goals/fishing.png',
    ),
  ];

  static PracticeItem? byId(String id) {
    final resolved = resolveOpenId(id);
    for (final i in all) {
      if (i.id == resolved) return i;
    }
    return null;
  }

  /// Для навигации из книжки / UI_SHOT / старых ссылок.
  static String resolveOpenId(String id) => openAliases[id] ?? id;

  /// Прогресс новых заданий: старые park_* не считаются выполненными.
  static Set<String> completedIds(Iterable<String> stored) {
    final known = all.map((e) => e.id).toSet();
    return stored.where(known.contains).toSet();
  }

  static PracticeItem nextIncomplete(Iterable<String> stored) {
    final done = completedIds(stored);
    return all.where((e) => !done.contains(e.id)).firstOrNull ?? all.first;
  }

  /// Три понятных уровня: первый знакомит с механикой, далее условия
  /// становятся теснее, но остаются решаемыми без калькулятора.
  static int levelForPeriod(int periodIndex) {
    if (periodIndex >= 3) return 3;
    if (periodIndex >= 2) return 2;
    return 1;
  }
}
