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
  // —— Обед ——
  static const lunchBudget = 80;
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

  // —— Копим ——
  static const dreamGoal = 90;
  static const dreamDays = 3;
  static const dreamIncome = 60;
  static const dreamNeed = 30;

  // —— Изменились планы ——
  static const changeFree = 40;
  static const changeSaved = 70;
  static const changeNeedCost = 55;
  static const changeGoalLeft = 80;

  // —— Выгодная покупка ——
  static const dealBudget = 100;
  static const dealNeedRacket = 1;
  static const dealNeedBalls = 2;

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
