import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/budget_plan.dart';
import '../../../core/profile/economy.dart';
import '../../../core/profile/game_controller.dart';
import '../../../core/profile/house_catalog.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/wardrobe/finzo_avatar.dart';
import '../../../core/wardrobe/wardrobe_catalog.dart';
import 'growth_guide_page.dart';
import 'widgets/finzo_feedback.dart';
import 'widgets/hub_hud_overlay.dart';
import 'widgets/pet_stats_panel.dart';
import 'widgets/savings_dialog.dart';
import 'widgets/svg_scene_page.dart';

/// Дом — кухня / одежда / душ + панели «Доступно» / «Накоплено».
class HousePage extends StatefulWidget {
  const HousePage({
    super.key,
    required this.controller,
    this.onOpenStreet,
    this.onOpenMessages,
    this.onOpenBook,
    this.onOpenResults,
    this.onChooseNextGoal,
    this.onOpenAdult,
  });

  final GameController controller;
  final VoidCallback? onOpenStreet;
  final VoidCallback? onOpenMessages;
  final VoidCallback? onOpenBook;
  final VoidCallback? onOpenResults;
  final VoidCallback? onChooseNextGoal;
  final VoidCallback? onOpenAdult;

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  HouseItemCategory _category = HouseItemCategory.kitchen;

  /// Размер превью предмета (каталог) в диалогах одежды.
  static const double _dialogItemPreviewSize = 128;

  /// Краткий неблокирующий прирост настроения у шкалы (после первого надевания).
  double? _moodFlash;

  @override
  void initState() {
    super.initState();
    const shot = String.fromEnvironment('UI_SHOT');
    if (shot.startsWith('wardrobe')) {
      _category = HouseItemCategory.clothes;
    }
    if (shot == 'available' ||
        shot == 'saved' ||
        shot == 'sleep' ||
        shot == 'savings' ||
        shot.startsWith('wardrobe_dialog_')) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        if (shot == 'available') {
          await showAvailableBottomSheet(context, widget.controller);
        } else if (shot == 'saved') {
          await showSavingsBottomSheet(context, widget.controller);
        } else if (shot == 'savings') {
          await showSavingsDialog(context, widget.controller);
        } else if (shot == 'sleep') {
          await _onSleepTap();
        } else if (shot.startsWith('wardrobe_dialog_')) {
          await _openWardrobeShotDialog(shot);
        }
      });
    }
  }

  Future<void> _openWardrobeShotDialog(String shot) async {
    // wardrobe_dialog_buy_c3 / wear_c3 / unequip_c3 / bought_c3
    final m = RegExp(r'c(\d+)').firstMatch(shot);
    final index = int.tryParse(m?.group(1) ?? '') ?? 3;
    final wardrobe = WardrobeCatalog.byIndex(index);
    final asset = wardrobe.thumbAsset;
    if (shot.contains('unequip')) {
      await _showUnequipDialog(wardrobe: wardrobe);
      return;
    }
    if (shot.contains('bought')) {
      await _showHouseDialog(
        title: 'Куплено!',
        body: '${wardrobe.title} теперь твоя. Надеть сейчас?',
        asset: asset,
        confirmLabel: 'Надеть сейчас',
        showCancel: true,
        cancelLabel: 'Позже',
        previewItemKey: wardrobe.shopKey,
      );
      return;
    }
    if (shot.contains('wear')) {
      await _showHouseDialog(
        title: 'Надеть?',
        body: '${wardrobe.title}\nНадеть бесплатно.',
        asset: asset,
        confirmLabel: 'Надеть',
        showCancel: true,
        previewItemKey: wardrobe.shopKey,
      );
      return;
    }
    // buy (default)
    await _showHouseDialog(
      title: 'Купить?',
      body: '${wardrobe.title}\nКатегория: Желания\nЦена: 40 ₽',
      asset: asset,
      confirmLabel: 'Купить',
      showCancel: true,
      previewItemKey: wardrobe.shopKey,
    );
  }

  void _openAvailableSheet() {
    showAvailableBottomSheet(context, widget.controller);
  }

  void _openSavedSheet() {
    showSavingsBottomSheet(
      context,
      widget.controller,
      onChooseNextGoal: widget.onChooseNextGoal,
    );
  }

  void _selectCategory(HouseItemCategory next) {
    setState(() => _category = next);
  }

  String get _asset => switch (_category) {
    HouseItemCategory.kitchen => AppAssets.house,
    HouseItemCategory.clothes => AppAssets.houseClothes,
    HouseItemCategory.shower => AppAssets.houseShower,
  };

  Future<void> _onSleepTap() async {
    final p = widget.controller.profile;
    if (p.periodPhase != PeriodPhase.playing) {
      if (p.periodPhase == PeriodPhase.results) {
        widget.onOpenResults?.call();
      }
      return;
    }

    final choice = await showDialog<_SleepChoice>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFFFEF7E6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1B6943), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.nightlight_round,
                color: Color(0xFF1B6943),
                size: 36,
              ),
              const SizedBox(height: 10),
              Text(
                'Закончить день?',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: const Color(0xFF1B6943),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                p.dayEndIntroShown
                    ? 'Можно закончить день в любой момент — '
                          'необязательно тратить все деньги или отвечать на всё.'
                    : 'Посмотрим, на что ушли деньги. '
                          'Потом можно сразу начать новый игровой день.',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  height: 1.35,
                  color: const Color(0xFF4A4643),
                ),
              ),
              const SizedBox(height: 18),
              _DialogButton(
                label: 'Ещё поиграть',
                filled: false,
                onTap: () => Navigator.pop(ctx, _SleepChoice.keepPlaying),
              ),
              const SizedBox(height: 10),
              _DialogButton(
                label: 'Посмотреть итоги',
                filled: true,
                onTap: () => Navigator.pop(ctx, _SleepChoice.finish),
              ),
            ],
          ),
        ),
      ),
    );
    if (choice != _SleepChoice.finish || !mounted) return;
    if (!p.dayEndIntroShown) {
      await widget.controller.markDayEndIntroShown();
    }
    final ok = await widget.controller.finishPeriod();
    if (ok) widget.onOpenResults?.call();
  }

  Future<void> _onSlotTap({
    required HouseItemCategory category,
    required int index,
    required String asset,
  }) async {
    final key = HouseCatalog.key(category, index);
    final qty = widget.controller.profile.inventoryQty(key);

    if (category == HouseItemCategory.kitchen && qty > 0) {
      await _confirmUseFood(index: index, asset: asset);
      return;
    }

    if (category == HouseItemCategory.clothes) {
      await _onClothesTap(index: index, asset: asset);
      return;
    }

    if (qty > 0 && category == HouseItemCategory.shower) {
      await _confirmApplyWearableOrCare(
        category: category,
        index: index,
        asset: asset,
      );
      return;
    }

    await _confirmBuy(category: category, index: index, asset: asset);
  }

  Future<void> _onClothesTap({
    required int index,
    required String asset,
  }) async {
    final shop = ShopCatalog.item(HouseItemCategory.clothes, index);
    final owned = widget.controller.profile.inventoryQty(shop.key) > 0;
    final equipped = widget.controller.profile.isEquipped(shop.key);

    if (!owned) {
      await _confirmBuyClothes(index: index, asset: asset);
      return;
    }

    if (equipped) {
      final wardrobe = WardrobeCatalog.byIndex(index);
      final ok = await _showUnequipDialog(wardrobe: wardrobe);
      if (ok != true) return;
      await widget.controller.unequipClothesKey(shop.key);
      return;
    }

    final alreadyBoosted = widget.controller.profile.boostedItemKeys.contains(
      shop.key,
    );
    final moodRoom = (100 - widget.controller.profile.mood).clamp(0, 5);
    final body = alreadyBoosted
        ? '${shop.title}\nНадеть бесплатно. Бонус настроения уже был.'
        : '${shop.title}\nПри первом надевании: +${moodRoom.toStringAsFixed(0)} к настроению'
              '${moodRoom < 5 ? ' (до максимума)' : ''}.';

    final ok = await _showHouseDialog(
      title: 'Надеть?',
      body: body,
      asset: asset,
      confirmLabel: 'Надеть',
      showCancel: true,
      previewItemKey: shop.key,
    );
    if (ok != true) return;

    final result = await widget.controller.equipClothes(index);
    if (!mounted) return;
    if (!result.ok) return;
    _flashMoodIfNeeded(result);
    if (result.firstBoost && result.moodGain > 0) {
      showFinzoStateNote(
        context,
        icon: Icons.sentiment_satisfied_alt_rounded,
        message:
            'Настроение Finzo повысилось (+${result.moodGain.round()}): '
            'ты надел «${shop.title}».',
      );
    }
  }

  void _flashMoodIfNeeded(EquipClothesResult result) {
    if (!result.firstBoost || result.moodGain <= 0) return;
    setState(() => _moodFlash = result.moodGain);
    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      setState(() => _moodFlash = null);
    });
  }

  Future<void> _confirmBuyClothes({
    required int index,
    required String asset,
  }) async {
    final shop = ShopCatalog.item(HouseItemCategory.clothes, index);
    final balance = widget.controller.profile.availableBalance;

    if (widget.controller.profile.periodPhase != PeriodPhase.playing) {
      if (!mounted) return;
      await showFinzoFeedback(
        context,
        title: 'Сначала план',
        what: 'Покупка пока недоступна.',
        why: 'День начинается с плана бюджета: нужное, желания и копилка.',
        next: 'Открой улицу и нажми «План бюджета».',
      );
      return;
    }

    if (balance < shop.price) {
      if (!mounted) return;
      await showFinzoFeedback(
        context,
        title: 'Не хватает монет',
        what: '«${shop.title}» не куплена.',
        why: 'Нужно ${shop.price} ₽, а доступно только $balance ₽.',
        next: 'Заработай на упражнении или купи что-то дешевле.',
      );
      return;
    }

    final overHint = widget.controller.overPlanHint(shop.bucket, shop.price);
    final ok = await _showHouseDialog(
      title: 'Купить?',
      body:
          '${shop.title}\n'
          'Категория: ${shop.bucketLabel}\n'
          '${shop.effectLabel}\n'
          'Цена: ${shop.price} ₽'
          '${overHint != null ? '\n\n$overHint' : ''}',
      asset: asset,
      confirmLabel: 'Купить',
      showCancel: true,
      previewItemKey: shop.key,
    );
    if (ok != true) return;

    final bought = await widget.controller.buyHouseItem(
      category: HouseItemCategory.clothes,
      index: index,
      quantity: 1,
    );
    if (!bought && mounted) {
      await showFinzoFeedback(
        context,
        title: 'Не куплено',
        what: 'Вещь не добавилась в шкаф.',
        why: 'Баланс или план дня не позволяют эту покупку.',
        next: 'Проверь «Доступно» и категории плана.',
      );
      return;
    }
    if (!mounted) return;

    final wearNow = await _showHouseDialog(
      title: 'Куплено!',
      body: '${shop.title} теперь твоя. Надеть сейчас?',
      asset: asset,
      confirmLabel: 'Надеть сейчас',
      showCancel: true,
      cancelLabel: 'Позже',
      previewItemKey: shop.key,
    );
    if (wearNow == true) {
      final result = await widget.controller.equipClothes(index);
      if (!mounted) return;
      _flashMoodIfNeeded(result);
      if (result.firstBoost && result.moodGain > 0) {
        showFinzoStateNote(
          context,
          icon: Icons.sentiment_satisfied_alt_rounded,
          message:
              'Настроение Finzo повысилось (+${result.moodGain.round()}): '
              'ты купил и надел «${shop.title}».',
        );
      }
    }
  }

  Future<void> _confirmBuy({
    required HouseItemCategory category,
    required int index,
    required String asset,
  }) async {
    final shop = ShopCatalog.item(category, index);
    final balance = widget.controller.profile.availableBalance;
    final maxBuy = ShopCatalog.maxAffordable(category, index, balance);

    if (widget.controller.profile.periodPhase != PeriodPhase.playing) {
      if (!mounted) return;
      await showFinzoFeedback(
        context,
        title: 'Сначала план',
        what: 'Покупка пока недоступна.',
        why: 'День начинается с плана бюджета: нужное, желания и копилка.',
        next: 'Открой улицу и нажми «План бюджета».',
      );
      return;
    }

    if (maxBuy <= 0) {
      if (!mounted) return;
      await showFinzoFeedback(
        context,
        title: 'Не хватает монет',
        what: '«${shop.title}» не куплена.',
        why: 'Нужно ${shop.price} ₽, а доступно только $balance ₽.',
        next: 'Сделай упражнение или выбери товар дешевле.',
      );
      return;
    }

    var quantity = 1;
    final overHint = widget.controller.overPlanHint(shop.bucket, shop.price);
    final bodyBase =
        '${shop.title}\n'
        'Категория: ${shop.bucketLabel}\n'
        'Эффект: ${shop.effectLabel}\n'
        'Цена: ${shop.price} ₽'
        '${overHint != null ? '\n\n$overHint' : ''}';

    final ok = await _showHouseDialog(
      title: 'Купить?',
      body: category == HouseItemCategory.kitchen
          ? '$bodyBase\n\nВыбери количество порций.'
          : bodyBase,
      asset: asset,
      confirmLabel: 'Купить',
      showCancel: true,
      quantityBuilder: category == HouseItemCategory.kitchen
          ? (setLocal) {
              return _QuantityStepper(
                value: quantity,
                min: 1,
                max: maxBuy,
                onChanged: (v) {
                  quantity = v;
                  setLocal(() {});
                },
              );
            }
          : null,
      totalBuilder: () {
        final q = category == HouseItemCategory.kitchen ? quantity : 1;
        return 'К оплате: ${shop.price * q} ₽ · останется '
            '${balance - shop.price * q} ₽';
      },
    );
    if (ok != true) return;

    final bought = await widget.controller.buyHouseItem(
      category: category,
      index: index,
      quantity: category == HouseItemCategory.kitchen ? quantity : 1,
    );
    if (!bought && mounted) {
      await showFinzoFeedback(
        context,
        title: 'Не куплено',
        what: 'Покупка не прошла.',
        why: 'Баланс или план дня не позволяют эту покупку.',
        next: 'Проверь «Доступно» и категории плана.',
      );
    }
  }

  Future<void> _confirmApplyWearableOrCare({
    required HouseItemCategory category,
    required int index,
    required String asset,
  }) async {
    final shop = ShopCatalog.item(category, index);

    final ok = await _showHouseDialog(
      title: 'Применить?',
      body:
          '${shop.title}\n'
          'Категория: ${shop.bucketLabel}\n'
          'Результат: ${shop.effectLabel}',
      asset: asset,
      confirmLabel: 'Применить',
      showCancel: true,
    );
    if (ok != true) return;

    final beforeMood = widget.controller.profile.mood;
    final beforeSatiety = widget.controller.profile.satiety;
    final applied = await widget.controller.useWearableOrCare(
      category: category,
      index: index,
    );
    if (!mounted) return;
    if (!applied) {
      await showFinzoFeedback(
        context,
        title: 'Не вышло',
        what: 'Предмет не применился.',
        why: 'Возможно, его уже нет в инвентаре.',
        next: 'Купи ещё раз или выбери другой предмет.',
      );
      return;
    }
    final moodGain =
        (widget.controller.profile.mood - beforeMood).clamp(0, 100);
    final satietyGain =
        (widget.controller.profile.satiety - beforeSatiety).clamp(0, 100);
    if (moodGain > 0) {
      showFinzoStateNote(
        context,
        icon: Icons.sentiment_satisfied_alt_rounded,
        message:
            'Настроение Finzo повысилось (+${moodGain.round()}): '
            'ты использовал «${shop.title}».',
      );
    } else if (satietyGain > 0) {
      showFinzoStateNote(
        context,
        icon: Icons.restaurant_rounded,
        message:
            'Сытость Finzo выросла (+${satietyGain.round()}): '
            'ты использовал «${shop.title}».',
      );
    }
  }

  Future<void> _confirmUseFood({
    required int index,
    required String asset,
  }) async {
    final shop = ShopCatalog.item(HouseItemCategory.kitchen, index);

    if (widget.controller.isFullyFed) {
      if (!mounted) return;
      await showFinzoFeedback(
        context,
        title: 'Finzo сыт',
        what: 'Еда не потратилась.',
        why: 'Сытость уже полная — больше кормить не нужно.',
        next: 'Загляни позже или займись уходом и целью.',
      );
      return;
    }

    final ok = await _showHouseDialog(
      title: 'Покормить?',
      body: '${shop.title}\nРезультат: ${shop.effectLabel}',
      asset: asset,
      confirmLabel: 'Применить',
      showCancel: true,
    );
    if (ok != true) return;

    final beforeSatiety = widget.controller.profile.satiety;
    final beforeMood = widget.controller.profile.mood;
    final used = await widget.controller.useKitchenItem(index);
    if (!mounted) return;
    if (!used && widget.controller.isFullyFed) {
      await showFinzoFeedback(
        context,
        title: 'Finzo сыт',
        what: 'Еда не потратилась.',
        why: 'Сытость уже полная — больше кормить не нужно.',
        next: 'Загляни позже или займись уходом и целью.',
      );
      return;
    }
    if (!used) return;
    final satietyGain =
        (widget.controller.profile.satiety - beforeSatiety).clamp(0, 100);
    final moodGain =
        (widget.controller.profile.mood - beforeMood).clamp(0, 100);
    if (satietyGain > 0 && moodGain > 0) {
      showFinzoStateNote(
        context,
        icon: Icons.restaurant_rounded,
        message:
            'Сытость и настроение Finzo выросли: ты дал «${shop.title}».',
      );
    } else if (satietyGain > 0) {
      showFinzoStateNote(
        context,
        icon: Icons.restaurant_rounded,
        message:
            'Сытость Finzo выросла (+${satietyGain.round()}): '
            'ты дал «${shop.title}».',
      );
    } else if (moodGain > 0) {
      showFinzoStateNote(
        context,
        icon: Icons.sentiment_satisfied_alt_rounded,
        message:
            'Настроение Finzo повысилось (+${moodGain.round()}): '
            'ты дал «${shop.title}».',
      );
    }
  }

  /// Компактное снятие: только миниатюра предмета из каталога, без белки.
  Future<bool?> _showUnequipDialog({required WardrobeItem wardrobe}) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFFFEF7E6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF1B6943), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  WardrobeCatalog.unequipTitle(wardrobe),
                  textAlign: TextAlign.center,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFF1B6943),
                  ),
                ),
                const SizedBox(height: 12),
                _ClothesItemPreview(asset: wardrobe.thumbAsset),
                const SizedBox(height: 10),
                Text(
                  'Вещь останется у тебя.',
                  textAlign: TextAlign.center,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.25,
                    color: const Color(0xFF4A4643),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Отмена',
                        filled: false,
                        onTap: () => Navigator.pop(ctx, false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DialogButton(
                        label: 'Снять',
                        filled: true,
                        onTap: () => Navigator.pop(ctx, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _showHouseDialog({
    required String title,
    required String body,
    required String asset,
    required String confirmLabel,
    required bool showCancel,
    String cancelLabel = 'Отмена',
    Widget Function(void Function(VoidCallback) setLocal)? quantityBuilder,
    String Function()? totalBuilder,

    /// Стабильный ID вещи (`c0`…`c7`) — превью предмета из каталога, без белки.
    String? previewItemKey,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final wardrobe = WardrobeCatalog.byKey(previewItemKey);
            final previewAsset = wardrobe?.thumbAsset ?? asset;

            return Dialog(
              backgroundColor: const Color(0xFFFEF7E6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF1B6943), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: const Color(0xFF1B6943),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ClothesItemPreview(
                      asset: previewAsset,
                      size: wardrobe != null ? _dialogItemPreviewSize : 72,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      body,
                      textAlign: TextAlign.center,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.25,
                        color: const Color(0xFF4A4643),
                      ),
                    ),
                    if (quantityBuilder != null) ...[
                      const SizedBox(height: 14),
                      quantityBuilder(setLocal),
                    ],
                    if (totalBuilder != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        totalBuilder(),
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: const Color(0xFF5B4300),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        if (showCancel) ...[
                          Expanded(
                            child: _DialogButton(
                              label: cancelLabel,
                              filled: false,
                              onTap: () => Navigator.pop(ctx, false),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: _DialogButton(
                            label: confirmLabel,
                            filled: true,
                            onTap: () => Navigator.pop(ctx, true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SvgScenePage(
      asset: _asset,
      backgroundColor: const Color(0xFFFEFCF4),
      overlays: [
        HubHudOverlay(
          controller: widget.controller,
          showSavedCard: true,
          balanceTop: 130,
          coverHeaderLabels: false,
          showStreetHeaderIcons: true,
          onOpenAdult: widget.onOpenAdult,
        ),
        PetStatsPanel(
          controller: widget.controller,
          top: 528,
          moodDeltaFlash: _moodFlash,
        ),
        // Белка вырезана из фоновых SVG — один FinzoAvatar на всех вкладках дома.
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            // Лапы на коврике: зона бывшей baked-белки ≈ (138,321)–(286,494).
            return Stack(
              children: [
                Positioned(
                  left: 106,
                  top: 288,
                  width: 156,
                  height: 182,
                  child: IgnorePointer(
                    child: FinzoAvatar(
                      profile: widget.controller.profile,
                      width: 156,
                      height: 182,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 256,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PetNameBadge(
                        name: widget.controller.profile.petName,
                      ),
                      const SizedBox(height: 4),
                      FinzoGrowthChip(
                        profile: widget.controller.profile,
                        onTap: () => GrowthGuidePage.open(
                          context,
                          widget.controller.profile,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        _HouseInventoryOverlay(
          controller: widget.controller,
          category: _category,
          onSlotTap: (category, index, asset) =>
              _onSlotTap(category: category, index: index, asset: asset),
        ),
        ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) {
            final phase = widget.controller.profile.periodPhase;
            return _SleepButton(
              visible:
                  phase == PeriodPhase.playing || phase == PeriodPhase.results,
              onTap: _onSleepTap,
            );
          },
        ),
      ],
      hits: [
        SvgHitArea(
          left: 14,
          top: 444,
          width: 52,
          height: 52,
          semanticsLabel: 'Улица',
          onTap: () => widget.onOpenStreet?.call(),
        ),
        SvgHitArea(
          left: 327,
          top: 383,
          width: 52,
          height: 52,
          semanticsLabel: 'Сообщения',
          onTap: () => widget.onOpenMessages?.call(),
        ),
        SvgHitArea(
          left: 327,
          top: 443,
          width: 52,
          height: 52,
          semanticsLabel: 'Книга',
          onTap: () => widget.onOpenBook?.call(),
        ),
        SvgHitArea(
          left: 14,
          top: 130.2,
          width: 177.3,
          height: 57.6,
          semanticsLabel: 'Доступно',
          onTap: _openAvailableSheet,
        ),
        SvgHitArea(
          left: 201.7,
          top: 130.2,
          width: 177.3,
          height: 57.6,
          semanticsLabel: 'Накоплено',
          onTap: _openSavedSheet,
        ),
        SvgHitArea(
          left: 10,
          top: 604,
          width: 76,
          height: 48,
          semanticsLabel: 'Кухня',
          onTap: () => _selectCategory(HouseItemCategory.kitchen),
        ),
        SvgHitArea(
          left: 86,
          top: 604,
          width: 76,
          height: 48,
          semanticsLabel: 'Одежда',
          onTap: () => _selectCategory(HouseItemCategory.clothes),
        ),
        SvgHitArea(
          left: 162,
          top: 604,
          width: 76,
          height: 48,
          semanticsLabel: 'Душ',
          onTap: () => _selectCategory(HouseItemCategory.shower),
        ),
      ],
    );
  }
}

enum _SleepChoice { keepPlaying, finish }

class _SleepButton extends StatelessWidget {
  const _SleepButton({required this.visible, required this.onTap});

  final bool visible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned(
      right: 14,
      top: 200,
      child: Material(
        color: const Color(0xFFFEFCF4),
        elevation: 2,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1B6943), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.nightlight_round,
                  color: Color(0xFF1B6943),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Закончить день',
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFF1B6943),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Крупный превью предмета из каталога (без белки) для диалогов одежды.
class _ClothesItemPreview extends StatelessWidget {
  const _ClothesItemPreview({required this.asset, this.size = 128});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? const Color(0xFF4B946A) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: filled
                ? null
                : Border.all(color: const Color(0xFF4B946A), width: 1.5),
          ),
          child: Text(
            label,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: filled ? Colors.white : const Color(0xFF4B946A),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepBtn('−', value > min, () => onChanged(value - 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$value',
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: const Color(0xFF1B6943),
            ),
          ),
        ),
        _stepBtn('+', value < max, () => onChanged(value + 1)),
      ],
    );
  }

  Widget _stepBtn(String label, bool enabled, VoidCallback onTap) {
    return Material(
      color: enabled ? const Color(0xFF4B946A) : const Color(0xFFD5D0D0),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Text(
              label,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Картинки слотов + затемнение/цена или количество.
class _HouseInventoryOverlay extends StatelessWidget {
  const _HouseInventoryOverlay({
    required this.controller,
    required this.category,
    required this.onSlotTap,
  });

  final GameController controller;
  final HouseItemCategory category;
  final void Function(HouseItemCategory category, int index, String asset)
  onSlotTap;

  static const _frames8 = <(double left, double top, double size)>[
    (38.5, 670.5, 64.4),
    (121.5, 670.5, 64.4),
    (204.5, 670.5, 64.4),
    (287.5, 670.5, 64.4),
    (38.5, 749.5, 64.4),
    (121.5, 749.5, 64.4),
    (204.5, 749.5, 64.4),
    (287.5, 749.5, 64.4),
  ];

  static const _frames4 = <(double left, double top, double size)>[
    (38.5, 670.5, 64.4),
    (121.5, 670.5, 64.4),
    (204.5, 670.5, 64.4),
    (287.5, 670.5, 64.4),
  ];

  static const _imageInset = 6.5;
  static const _badgeW = 36.0;
  static const _badgeH = 12.1;
  static const _rubleSize = 7.0;

  @override
  Widget build(BuildContext context) {
    final items = switch (category) {
      HouseItemCategory.kitchen => AppAssets.houseInventory,
      HouseItemCategory.clothes => AppAssets.houseClothesInventory,
      HouseItemCategory.shower => AppAssets.houseShowerInventory,
    };
    final frames = category == HouseItemCategory.shower ? _frames4 : _frames8;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Stack(
          children: [
            for (var i = 0; i < items.length && i < frames.length; i++)
              _slot(index: i, asset: items[i], frame: frames[i]),
          ],
        );
      },
    );
  }

  Widget _slot({
    required int index,
    required String asset,
    required (double left, double top, double size) frame,
  }) {
    final key = HouseCatalog.key(category, index);
    final qty = controller.profile.inventoryQty(key);
    final owned = qty > 0;
    final equipped =
        category == HouseItemCategory.clothes &&
        controller.profile.isEquipped(key);
    final price = ShopCatalog.priceOf(category, index);
    final left = frame.$1;
    final top = frame.$2;
    final size = frame.$3;
    final badgeLeft = left + size - _badgeW - 1.5;
    final badgeTop = top + size - _badgeH - 3.1;
    final wardrobe = category == HouseItemCategory.clothes
        ? WardrobeCatalog.byIndex(index)
        : null;
    final thumbAsset = wardrobe?.thumbAsset ?? asset;
    final semanticsLabel = wardrobe == null
        ? null
        : (!owned
              ? '${wardrobe.title}, цена $price'
              : (equipped
                    ? '${wardrobe.title}, надето'
                    : '${wardrobe.title}, надеть'));

    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: Semantics(
        button: true,
        label: semanticsLabel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSlotTap(category, index, asset),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                left: _imageInset,
                top: _imageInset - 0.5,
                width: size - _imageInset * 2,
                height: size - _imageInset * 2,
                child: Image.asset(
                  thumbAsset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              if (!owned)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D3D3D).withValues(alpha: 0.44),
                      borderRadius: BorderRadius.circular(8.18),
                    ),
                  ),
                ),
              Positioned(
                left: badgeLeft - left,
                top: badgeTop - top,
                width: _badgeW,
                height: _badgeH,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: equipped
                        ? const Color(0xFF4B946A)
                        : const Color(0xFFDF9548),
                    borderRadius: BorderRadius.circular(6.07),
                    border: Border.all(
                      color: const Color(0xFFFDD889),
                      width: 0.53,
                    ),
                  ),
                  child: Center(
                    child: equipped
                        ? const Icon(
                            Icons.check_rounded,
                            size: 10,
                            color: Color(0xFFFCD788),
                          )
                        : owned
                        ? Text(
                            category == HouseItemCategory.clothes
                                ? 'Надеть'
                                : '${qty}x',
                            style: AppFonts.rubik(
                              fontWeight: FontWeight.w700,
                              fontSize: 7.5,
                              height: 1,
                              color: const Color(0xFFFCD788),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$price',
                                style: AppFonts.rubik(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 8,
                                  height: 1,
                                  color: const Color(0xFFFCD788),
                                ),
                              ),
                              const SizedBox(width: 1.5),
                              SvgPicture.asset(
                                AppAssets.rubleMark,
                                width: _rubleSize,
                                height: _rubleSize,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
