import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/game_controller.dart';
import '../../../core/profile/house_catalog.dart';
import '../../../core/profile/player_profile.dart';
import '../../../core/profile/player_rules.dart';
import '../../../core/theme/app_fonts.dart';
import 'goals_page.dart';
import 'widgets/hub_hud_overlay.dart';
import 'widgets/svg_scene_page.dart';

enum _HouseExpand { none, available, saved }

/// Дом — кухня / одежда / душ + панели «Доступно» / «Накоплено».
class HousePage extends StatefulWidget {
  const HousePage({
    super.key,
    required this.controller,
    this.onOpenStreet,
    this.onOpenBook,
  });

  final GameController controller;
  final VoidCallback? onOpenStreet;
  final VoidCallback? onOpenBook;

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  _HouseExpand _expand = _HouseExpand.none;
  HouseItemCategory _category = HouseItemCategory.kitchen;

  void _toggleExpand(_HouseExpand next) {
    setState(() {
      _expand = _expand == next ? _HouseExpand.none : next;
    });
  }

  void _selectCategory(HouseItemCategory next) {
    setState(() {
      _category = next;
      _expand = _HouseExpand.none;
    });
  }

  String get _asset {
    if (_expand == _HouseExpand.available) return AppAssets.houseAvailable;
    if (_expand == _HouseExpand.saved) return AppAssets.houseSaved;
    return switch (_category) {
      HouseItemCategory.kitchen => AppAssets.house,
      HouseItemCategory.clothes => AppAssets.houseClothes,
      HouseItemCategory.shower => AppAssets.houseShower,
    };
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

    if (qty > 0) return; // одежда/душ уже куплены

    await _confirmBuy(category: category, index: index, asset: asset);
  }

  Future<void> _confirmBuy({
    required HouseItemCategory category,
    required int index,
    required String asset,
  }) async {
    final balance = widget.controller.profile.availableBalance;
    final maxBuy = category == HouseItemCategory.kitchen
        ? HouseCatalog.maxAffordableFood(balance)
        : (balance >= HouseCatalog.itemPrice ? 1 : 0);

    if (maxBuy <= 0) {
      if (!mounted) return;
      await _showHouseDialog(
        title: 'Не хватает монет',
        body: 'Нужно ${HouseCatalog.itemPrice} ₽ на балансе.',
        asset: asset,
        confirmLabel: 'Понятно',
        showCancel: false,
      );
      return;
    }

    var quantity = 1;
    final ok = await _showHouseDialog(
      title: 'Купить?',
      body: category == HouseItemCategory.kitchen
          ? 'Вы уверены, что хотите купить?\nВыбери количество порций.'
          : 'Вы уверены, что хотите купить\nза ${HouseCatalog.itemPrice} ₽?',
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
      totalBuilder: category == HouseItemCategory.kitchen
          ? () => 'К оплате: ${HouseCatalog.itemPrice * quantity} ₽'
          : null,
    );
    if (ok != true) return;

    await widget.controller.buyHouseItem(
      category: category,
      index: index,
      quantity: category == HouseItemCategory.kitchen ? quantity : 1,
    );
  }

  Future<void> _confirmUseFood({
    required int index,
    required String asset,
  }) async {
    if (widget.controller.isFullyFed) {
      if (!mounted) return;
      await _showHouseDialog(
        title: 'Финзо сыт',
        body: 'Сытость полная — еду пока применять нельзя.',
        asset: asset,
        confirmLabel: 'Понятно',
        showCancel: false,
      );
      return;
    }

    final ok = await _showHouseDialog(
      title: 'Покормить?',
      body: 'Применить еду и повысить сытость?',
      asset: asset,
      confirmLabel: 'Применить',
      showCancel: true,
    );
    if (ok != true) return;

    final used = await widget.controller.useKitchenItem(index);
    if (!used && mounted && widget.controller.isFullyFed) {
      await _showHouseDialog(
        title: 'Финзо сыт',
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
    Widget Function(void Function(VoidCallback) setLocal)? quantityBuilder,
    String Function()? totalBuilder,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
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
                              label: 'Отмена',
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
        _HouseInventoryOverlay(
          controller: widget.controller,
          category: _expand == _HouseExpand.none
              ? _category
              : HouseItemCategory.kitchen,
          onSlotTap: (category, index, asset) =>
              _onSlotTap(category: category, index: index, asset: asset),
        ),
        if (_expand == _HouseExpand.available)
          _AvailableExpandOverlay(controller: widget.controller),
        if (_expand == _HouseExpand.saved)
          _SavedExpandOverlay(controller: widget.controller),
      ],
      hits: [
        SvgHitArea(
          left: 17.5,
          top: 448.5,
          width: 44,
          height: 44,
          onTap: () => widget.onOpenStreet?.call(),
        ),
        SvgHitArea(
          left: 331.5,
          top: 448.5,
          width: 44,
          height: 44,
          onTap: () => widget.onOpenBook?.call(),
        ),
        SvgHitArea(
          left: 14,
          top: 130.2,
          width: 177.3,
          height: 57.6,
          onTap: () => _toggleExpand(_HouseExpand.available),
        ),
        SvgHitArea(
          left: 201.7,
          top: 130.2,
          width: 177.3,
          height: 57.6,
          onTap: () => _toggleExpand(_HouseExpand.saved),
        ),
        SvgHitArea(
          left: 12.5,
          top: 607.5,
          width: 70,
          height: 42,
          onTap: () => _selectCategory(HouseItemCategory.kitchen),
        ),
        SvgHitArea(
          left: 88.5,
          top: 607.5,
          width: 70,
          height: 42,
          onTap: () => _selectCategory(HouseItemCategory.clothes),
        ),
        SvgHitArea(
          left: 164.5,
          top: 607.5,
          width: 70,
          height: 42,
          onTap: () => _selectCategory(HouseItemCategory.shower),
        ),
      ],
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

/// Панель «Доверие родителей» (макет «Дом если нажать на доступно»).
class _AvailableExpandOverlay extends StatelessWidget {
  const _AvailableExpandOverlay({required this.controller});

  final GameController controller;

  static const _fillLeft = 31.0;
  static const _fillTop = 240.48;
  static const _fillMaxWidth = 243.0;
  static const _fillHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.profile;
        final level = (1 + (p.streakDays ~/ 5)).clamp(1, 3);
        final progress = level / 3.0;
        final receive = p.availableBalance > 0
            ? p.availableBalance
            : PlayerRules.weeklyAllowance;

        return Stack(
          children: [
            Positioned(
              left: _fillLeft,
              top: _fillTop,
              width: (_fillMaxWidth * progress).clamp(0.0, _fillMaxWidth),
              height: _fillHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFB65C1C),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Positioned(
              left: 31,
              top: 255,
              width: 260,
              height: 22,
              child: Text(
                'Сейчас вы получаете ${_formatRu(receive)} р',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.1,
                  color: const Color(0xFF5B4300),
                ),
              ),
            ),
            Positioned(
              left: 330,
              top: 255,
              width: 40,
              height: 22,
              child: Text(
                '$level/3',
                textAlign: TextAlign.right,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  height: 1.1,
                  color: const Color(0xFF5B4300),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Панель цели накопления (макет «Дом если нажать на накоплено»).
class _SavedExpandOverlay extends StatelessWidget {
  const _SavedExpandOverlay({required this.controller});

  final GameController controller;

  static const _barLeft = 28.6651;
  static const _barWidth = 247.162;
  static const _fillLeft = 31.0;
  static const _fillTop = 252.48;
  static const _fillMaxWidth = 243.0;
  static const _fillHeight = 6.0;
  static const _titleTop = 210.0;
  static const _titleHeight = 40.0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.profile;
        final progress = p.goalProgress;
        final pct = (progress * 100).round();
        final goalImage = _goalImageFor(p);
        final barRight = _barLeft + _barWidth;

        return Stack(
          children: [
            Positioned(
              left: 30,
              top: _titleTop,
              width: 170,
              height: _titleHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Цель накоплений',
                    maxLines: 1,
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      height: 1,
                      color: const Color(0xFF404942),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.goalTitle.isEmpty ? 'Цель' : p.goalTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      height: 1.1,
                      color: const Color(0xFF1B6943),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: barRight - 110,
              top: _titleTop,
              width: 110,
              height: _titleHeight,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: _formatRu(p.savedBalance),
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1,
                          color: const Color(0xFF1B6943),
                        ),
                      ),
                      TextSpan(
                        text: '/${_formatRu(p.goalPrice)}',
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1,
                          color: const Color(0xFF4B4A48),
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Positioned(
              left: _fillLeft,
              top: _fillTop,
              width: (_fillMaxWidth * progress).clamp(0.0, _fillMaxWidth),
              height: _fillHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6943),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Positioned(
              left: 31,
              top: 266,
              width: 170,
              height: 20,
              child: Text(
                'Осталось ${_formatRu(p.remainingToGoal)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  height: 1.1,
                  color: const Color(0xFF4B4A48),
                ),
              ),
            ),
            Positioned(
              left: barRight - 100,
              top: 266,
              width: 100,
              height: 20,
              child: Text(
                '$pct% накоплено',
                maxLines: 1,
                textAlign: TextAlign.right,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  height: 1.1,
                  color: const Color(0xFF1B6943),
                ),
              ),
            ),
            Positioned(
              left: 295,
              top: 208,
              width: 74,
              height: 74,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7.22),
                child: ColoredBox(
                  color: const Color(0xFFFEF7E6),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      goalImage,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _formatRu(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  if (n < 0) buf.write('-');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

String _goalImageFor(PlayerProfile p) {
  if (p.goalImageAsset.isNotEmpty) return p.goalImageAsset;
  final title = p.goalTitle.replaceAll('\n', ' ').trim().toLowerCase();
  if (title.isEmpty) return AppAssets.goalBicycle;
  for (final g in GoalsPage.goals) {
    final gt = g.title.replaceAll('\n', ' ').trim().toLowerCase();
    if (gt == title || title.contains(gt) || gt.contains(title)) {
      return g.imageAsset;
    }
  }
  for (final g in GoalsPage.goals) {
    final price =
        int.tryParse(g.price.replaceAll(RegExp(r'[^\d]'), '')) ?? -1;
    if (price == p.goalPrice) return g.imageAsset;
  }
  return AppAssets.goalBicycle;
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
  static const _badgeW = 29.0;
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
    final left = frame.$1;
    final top = frame.$2;
    final size = frame.$3;
    final badgeLeft = left + size - _badgeW - 1.5;
    final badgeTop = top + size - _badgeH - 3.1;

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
              child: Image.asset(
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
            Positioned(
              left: badgeLeft - left,
              top: badgeTop - top,
              width: _badgeW,
              height: _badgeH,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFDF9548),
                  borderRadius: BorderRadius.circular(6.07),
                  border: Border.all(
                    color: const Color(0xFFFDD889),
                    width: 0.53,
                  ),
                ),
                child: Center(
                  child: owned
                      ? Text(
                          '${qty}x',
                          style: AppFonts.rubik(
                            fontWeight: FontWeight.w700,
                            fontSize: 8,
                            height: 1,
                            color: const Color(0xFFFCD788),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${HouseCatalog.itemPrice}',
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
