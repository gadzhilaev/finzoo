import 'package:flutter/material.dart';

class PracticeGoods {
  const PracticeGoods({
    required this.id,
    required this.title,
    required this.price,
    required this.icon,
    this.tag = '',
    this.required = false,
    this.group = '',
    this.imageAsset,
  });

  final String id;
  final String title;
  final int price;
  final IconData icon;
  final String tag;
  final bool required;
  final String group;
  final String? imageAsset;
}

abstract final class PracticeContent {
  static int _level(int periodIndex) => periodIndex >= 3 ? 3 : periodIndex >= 2 ? 2 : 1;

  // —— Обед ——
  static const lunchBudget = 80;
  static int lunchBudgetFor(int periodIndex) => switch (_level(periodIndex)) {
        1 => lunchBudget,
        2 => 70,
        _ => 65,
      };
  static const lunchItems = <PracticeGoods>[
    PracticeGoods(
      id: 'soup',
      title: 'Суп',
      price: 35,
      icon: Icons.soup_kitchen,
      tag: 'блюдо',
      group: 'main',
      imageAsset: 'assets/images/house_inv/item_0.png',
    ),
    PracticeGoods(
      id: 'pasta',
      title: 'Паста',
      price: 40,
      icon: Icons.dinner_dining,
      tag: 'блюдо',
      group: 'main',
      imageAsset: 'assets/images/house_inv/item_1.png',
    ),
    PracticeGoods(
      id: 'tea',
      title: 'Чай',
      price: 15,
      icon: Icons.emoji_food_beverage,
      tag: 'напиток',
      group: 'drink',
      imageAsset: 'assets/images/house_inv/item_6.png',
    ),
    PracticeGoods(
      id: 'juice',
      title: 'Сок',
      price: 25,
      icon: Icons.local_cafe,
      tag: 'напиток',
      group: 'drink',
      imageAsset: 'assets/images/house_inv/item_7.png',
    ),
    PracticeGoods(
      id: 'cake',
      title: 'Пирожное',
      price: 20,
      icon: Icons.cake_outlined,
      tag: 'десерт',
      group: 'extra',
      imageAsset: 'assets/images/house_inv/item_5.png',
    ),
    PracticeGoods(
      id: 'gum',
      title: 'Жвачка',
      price: 10,
      icon: Icons.bubble_chart_outlined,
      tag: 'десерт',
      group: 'extra',
      imageAsset: 'assets/images/house_inv/item_4.png',
    ),
  ];

  // —— План на день ——
  static const planBudget = 100;
  static const planNeedMin = 50;
  static int planBudgetFor(int periodIndex) => switch (_level(periodIndex)) {
        1 => planBudget,
        2 => 120,
        _ => 140,
      };
  static int planNeedMinFor(int periodIndex) => switch (_level(periodIndex)) {
        1 => planNeedMin,
        2 => 60,
        _ => 80,
      };

  // —— Копим ——
  static const dreamGoal = 90;
  static const dreamDays = 3;
  static const dreamIncome = 60;
  static const dreamNeed = 30;
  static int dreamGoalFor(int periodIndex) => switch (_level(periodIndex)) {
        1 => dreamGoal,
        2 => 120,
        _ => 150,
      };
  static int dreamDaysFor(int periodIndex) => _level(periodIndex) == 1 ? dreamDays : 4;
  static int dreamIncomeFor(int periodIndex) => switch (_level(periodIndex)) {
        1 => dreamIncome,
        2 => 65,
        _ => 75,
      };
  static int dreamNeedFor(int periodIndex) => switch (_level(periodIndex)) {
        1 => dreamNeed,
        2 => 30,
        _ => 35,
      };

  // —— Изменились планы ——
  static const changeFree = 40;
  static const changeSaved = 70;
  static const changeNeedCost = 55;
  static const changeGoalLeft = 80;
  static int changeFreeFor(int periodIndex) => switch (_level(periodIndex)) {
        1 => changeFree,
        2 => 35,
        _ => 30,
      };
  static int changeSavedFor(int periodIndex) => switch (_level(periodIndex)) {
        1 => changeSaved,
        2 => 70,
        _ => 90,
      };
  static int changeNeedCostFor(int periodIndex) => switch (_level(periodIndex)) {
        1 => changeNeedCost,
        2 => 60,
        _ => 75,
      };
  static int changeGoalLeftFor(int periodIndex) => switch (_level(periodIndex)) {
        1 => changeGoalLeft,
        2 => 90,
        _ => 100,
      };

  // —— Выгодная покупка ——
  static const dealBudget = 100;
  static const dealNeedRacket = 1;
  static const dealNeedBalls = 2;
  static int dealBudgetFor(int periodIndex) => switch (_level(periodIndex)) {
        1 => dealBudget,
        2 => 90,
        _ => 85,
      };

  static const dealShopA = <PracticeGoods>[
    PracticeGoods(
      id: 'racket',
      title: 'Ракетка',
      price: 55,
      icon: Icons.sports_tennis,
      tag: 'ракетка 1',
      group: 'racket',
      imageAsset: 'assets/images/goals/tennis.png',
    ),
    PracticeGoods(
      id: 'ball',
      title: 'Мяч',
      price: 15,
      icon: Icons.sports_baseball,
      tag: 'мяч 1',
      group: 'ball',
      imageAsset: 'assets/images/goals/tennis.png',
    ),
    PracticeGoods(
      id: 'pack2',
      title: 'Ракетка + мяч',
      price: 65,
      icon: Icons.inventory_2_outlined,
      tag: 'ракетка 1 · мяч 1',
      group: 'mix',
      imageAsset: 'assets/images/goals/tennis.png',
    ),
  ];

  static const dealShopB = <PracticeGoods>[
    PracticeGoods(
      id: 'balls3',
      title: '3 мяча',
      price: 40,
      icon: Icons.sports_baseball,
      tag: 'мяч 3',
      group: 'ball',
      imageAsset: 'assets/images/goals/tennis.png',
    ),
    PracticeGoods(
      id: 'full',
      title: 'Набор ракетка+2 мяча',
      price: 85,
      icon: Icons.card_giftcard,
      tag: 'ракетка 1 · мяч 2',
      group: 'mix',
      imageAsset: 'assets/images/goals/tennis.png',
    ),
  ];

  // —— Чек ——
  static const receiptBudget = 100;
  static int receiptBudgetFor(int periodIndex) => _level(periodIndex) == 1 ? receiptBudget : 95;
  static const receiptGear = <PracticeGoods>[
    PracticeGoods(
      id: 'rod',
      title: 'Удочка',
      price: 45,
      icon: Icons.phishing,
      required: true,
      imageAsset: 'assets/images/goals/fishing.png',
    ),
    PracticeGoods(
      id: 'hook',
      title: 'Крючки',
      price: 15,
      icon: Icons.anchor,
      required: true,
      imageAsset: 'assets/images/goals/fishing.png',
    ),
    PracticeGoods(
      id: 'bait',
      title: 'Наживка',
      price: 20,
      icon: Icons.set_meal,
      required: true,
      imageAsset: 'assets/images/house_inv/item_2.png',
    ),
    PracticeGoods(
      id: 'bucket',
      title: 'Ведро',
      price: 15,
      icon: Icons.shopping_basket_outlined,
      required: true,
      imageAsset: 'assets/images/house_inv/item_6.png',
    ),
    PracticeGoods(
      id: 'toy',
      title: 'Игрушка-утка',
      price: 25,
      icon: Icons.toys_outlined,
      required: false,
      tag: 'желание',
      imageAsset: 'assets/images/house_inv/item_4.png',
    ),
  ];
  static const sneakyId = 'chips_extra';
  static const sneakyTitle = 'Чипсы «случайно»';
  static const sneakyPrice = 18;
}
