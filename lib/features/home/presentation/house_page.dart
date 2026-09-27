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
    this.onOpenBook,
    this.onOpenResults,
  });

  final GameController controller;
  final VoidCallback? onOpenStreet;
  final VoidCallback? onOpenBook;
  final VoidCallback? onOpenResults;

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  HouseItemCategory _category = HouseItemCategory.kitchen;

  @override
  void initState() {
    super.initState();
    const shot = String.fromEnvironment('UI_SHOT');
    if (shot == 'available' ||
        shot == 'saved' ||
        shot == 'sleep' ||
        shot == 'savings') {
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
        }
      });
    }
  }

  void _openAvailableSheet() {
    showAvailableBottomSheet(context, widget.controller);
  }

  void _openSavedSheet() {
    showSavingsBottomSheet(context, widget.controller);
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
              const Icon(Icons.nightlight_round,
                  color: Color(0xFF1B6943), size: 36),
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
    final wardrobe = WardrobeCatalog.byIndex(index);

    if (!owned) {
      await _confirmBuyClothes(index: index, asset: asset);
      return;
    }

    if (equipped) {
      final ok = await _showHouseDialog(
        title: 'Снять?',
        body: '${shop.title} сейчас на Finzo.\n'
            'Снятие не снижает настроение. Вещь останется у тебя.',
        asset: asset,
        confirmLabel: 'Снять',
        showCancel: true,
        previewWardrobeIndex: index,
      );
      if (ok != true) return;
      await widget.controller.unequipClothesKey(shop.key);
      return;
    }

    final alreadyBoosted =
        widget.controller.profile.boostedItemKeys.contains(shop.key);
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
      previewWardrobeIndex: index,
      previewTryOn: true,
    );
    if (ok != true) return;

    final result = await widget.controller.equipClothes(index);
    if (!mounted) return;
    if (!result.ok) return;

    if (result.firstBoost) {
      final gain = result.moodGain.round();
      await _showHouseDialog(
        title: gain > 0 ? 'Finzo рад!' : 'Уже на максимуме',
        body: gain > 0
            ? 'Настроение +$gain. ${wardrobe.title} на Finzo.'
            : '${wardrobe.title} надета. Настроение уже 100.',
        asset: asset,
        confirmLabel: 'Отлично',
        showCancel: false,
        previewWardrobeIndex: index,
      );
    }
  }

  Future<void> _confirmBuyClothes({
    required int index,
    required String asset,
  }) async {
    final shop = ShopCatalog.item(HouseItemCategory.clothes, index);
    final balance = widget.controller.profile.availableBalance;

    if (widget.controller.profile.periodPhase != PeriodPhase.playing) {
      if (!mounted) return;
      await _showHouseDialog(
        title: 'Сначала план',
        body: 'Подтверди план бюджета на улице — потом можно покупать.',
        asset: asset,
        confirmLabel: 'Понятно',
        showCancel: false,
      );
      return;
    }

    if (balance < shop.price) {
      if (!mounted) return;
      await _showHouseDialog(
        title: 'Не хватает монет',
        body: 'Нужно ${shop.price} ₽. Сейчас доступно $balance ₽.',
        asset: asset,
        confirmLabel: 'Понятно',
        showCancel: false,
      );
      return;
    }

    final overHint = widget.controller.overPlanHint(shop.bucket, shop.price);
    final ok = await _showHouseDialog(
      title: 'Купить?',
      body: '${shop.title}\n'
          'Категория: ${shop.bucketLabel}\n'
          '${shop.effectLabel}\n'
          'Цена: ${shop.price} ₽'
          '${overHint != null ? '\n\n$overHint' : ''}\n\n'
          'Примерка до покупки не сохраняется как владение.',
      asset: asset,
      confirmLabel: 'Купить',
      showCancel: true,
      previewWardrobeIndex: index,
      previewTryOn: true,
    );
    if (ok != true) return;

    final bought = await widget.controller.buyHouseItem(
      category: HouseItemCategory.clothes,
      index: index,
      quantity: 1,
    );
    if (!bought && mounted) {
      await _showHouseDialog(
        title: 'Не куплено',
        body: 'Проверь баланс или план периода.',
        asset: asset,
        confirmLabel: 'Понятно',
        showCancel: false,
      );
      return;
    }
    if (!mounted) return;

    final wearNow = await _showHouseDialog(
      title: 'Куплено!',
      body: '${shop.title} теперь твоя.\nНадеть сейчас?',
      asset: asset,
      confirmLabel: 'Надеть сейчас',
      showCancel: true,
      cancelLabel: 'Позже',
      previewWardrobeIndex: index,
    );
    if (wearNow == true) {
      final result = await widget.controller.equipClothes(index);
      if (!mounted) return;
      if (result.firstBoost) {
        final gain = result.moodGain.round();
        await _showHouseDialog(
          title: gain > 0 ? 'Finzo рад!' : 'Уже на максимуме',
          body: gain > 0
              ? 'Настроение +$gain.'
              : 'Вещь надета. Настроение уже 100.',
          asset: asset,
          confirmLabel: 'Отлично',
          showCancel: false,
          previewWardrobeIndex: index,
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
      await _showHouseDialog(
        title: 'Сначала план',
        body: 'Подтверди план бюджета на улице — потом можно покупать.',
        asset: asset,
        confirmLabel: 'Понятно',
        showCancel: false,
      );
      return;
    }

    if (maxBuy <= 0) {
      if (!mounted) return;
      await _showHouseDialog(
        title: 'Не хватает монет',
        body: 'Нужно ${shop.price} ₽. Сейчас доступно $balance ₽.',
        asset: asset,
        confirmLabel: 'Понятно',
        showCancel: false,
      );
      return;
    }

    var quantity = 1;
    final overHint = widget.controller.overPlanHint(shop.bucket, shop.price);
    final bodyBase = '${shop.title}\n'
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
      await _showHouseDialog(
        title: 'Не куплено',
        body: 'Проверь баланс или план периода.',
        asset: asset,
        confirmLabel: 'Понятно',
        showCancel: false,
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
      body: '${shop.title}\n'
          'Категория: ${shop.bucketLabel}\n'
          'Результат: ${shop.effectLabel}',
      asset: asset,
      confirmLabel: 'Применить',
      showCancel: true,
    );
    if (ok != true) return;

    final applied = await widget.controller.useWearableOrCare(
      category: category,
      index: index,
    );
    if (!applied && mounted) {
      await _showHouseDialog(
        title: 'Не вышло',
        body: 'Не удалось применить предмет. Попробуй ещё раз.',
        asset: asset,
        confirmLabel: 'Понятно',
        showCancel: false,
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
      await _showHouseDialog(
        title: 'Finzo сыт',
        body: 'Сытость полная — еду пока применять нельзя.',
        asset: asset,
        confirmLabel: 'Понятно',
        showCancel: false,
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

    final used = await widget.controller.useKitchenItem(index);
    if (!used && mounted && widget.controller.isFullyFed) {
      await _showHouseDialog(
        title: 'Finzo сыт',
        body: 'Сытость полная — еду пока применять нельзя.',
        asset: asset,
        confirmLabel: 'Понятно',
        showCancel: false,
      );
    }
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
    int? previewWardrobeIndex,
    bool previewTryOn = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final wardrobe = previewWardrobeIndex != null
                ? WardrobeCatalog.byIndex(previewWardrobeIndex)
                : null;
            String? previewBody;
            String? previewHead;
            if (previewTryOn && wardrobe != null) {
              if (wardrobe.slot == WardrobeSlot.body) {
                previewBody = wardrobe.shopKey;
              } else {
                previewHead = wardrobe.shopKey;
              }
            }

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
                    if (wardrobe != null)
                      Column(
                        children: [
                          FinzoAvatar(
                            profile: widget.controller.profile,
                            width: 120,
                            height: 140,
                            previewBodyKey: previewBody ??
                                (previewTryOn
                                    ? null
                                    : widget.controller.profile.equippedBodyKey),
                            previewHeadKey: previewHead ??
                                (previewTryOn
                                    ? null
                                    : widget.controller.profile.equippedHeadKey),
                          ),
                          if (previewTryOn)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Примерка',
                                style: AppFonts.rubik(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  color: const Color(0xFFDF9548),
                                ),
                              ),
                            ),
                        ],
                      )
                    else
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: Image.asset(
                          asset,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                        ),
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
        ),
        PetStatsPanel(controller: widget.controller, top: 528),
        if (_category == HouseItemCategory.clothes)
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              return Positioned(
                left: 105,
                top: 210,
                width: 180,
                height: 210,
                child: IgnorePointer(
                  child: FinzoAvatar(
                    profile: widget.controller.profile,
                    width: 180,
                    height: 210,
                  ),
                ),
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
              visible: phase == PeriodPhase.playing ||
                  phase == PeriodPhase.results,
              onTap: _onSleepTap,
            );
          },
        ),
      ],
      hits: [
        SvgHitArea(
          left: 17.5,
          top: 448.5,
          width: 44,
          height: 44,
          semanticsLabel: 'Улица',
          onTap: () => widget.onOpenStreet?.call(),
        ),
        SvgHitArea(
          left: 331.5,
          top: 448.5,
          width: 44,
          height: 44,
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
          left: 12.5,
          top: 607.5,
          width: 70,
          height: 42,
          semanticsLabel: 'Кухня',
          onTap: () => _selectCategory(HouseItemCategory.kitchen),
        ),
        SvgHitArea(
          left: 88.5,
          top: 607.5,
          width: 70,
          height: 42,
          semanticsLabel: 'Одежда',
          onTap: () => _selectCategory(HouseItemCategory.clothes),
        ),
        SvgHitArea(
          left: 164.5,
          top: 607.5,
          width: 70,
          height: 42,
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
                const Icon(Icons.nightlight_round,
                    color: Color(0xFF1B6943), size: 20),
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
              _slot(
                index: i,
                asset: items[i],
                frame: frames[i],
              ),
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

    return Positioned(
      left: left,
      top: top,
      width: size,
      height: size,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSlotTap(category, index, asset),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: _imageInset,
              top: _imageInset - 0.5,
              width: size - _imageInset * 2,
              height: size - _imageInset * 2,
              child: wardrobe != null
                  ? SvgPicture.asset(
                      wardrobe.fullAsset,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      asset,
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
            if (equipped)
              Positioned(
                left: 4,
                top: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B946A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Надето',
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: badgeLeft - left,
              top: badgeTop - top,
              width: equipped ? _badgeW + 4 : _badgeW,
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
                  child: owned
                      ? Text(
                          equipped
                              ? 'Снять'
                              : (category == HouseItemCategory.clothes
                                  ? 'Надеть'
                                  : '${qty}x'),
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
    );
  }
}
