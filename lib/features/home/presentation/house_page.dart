import 'package:flutter/material.dart';
import '../../../core/theme/app_fonts.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/game_controller.dart';
import '../../../core/profile/player_profile.dart';
import '../../../core/profile/player_rules.dart';
import 'goals_page.dart';
import 'widgets/hub_hud_overlay.dart';
import 'widgets/svg_scene_page.dart';

enum _HouseExpand { none, available, saved }

enum _HouseCategory { kitchen, clothes, shower }

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
  _HouseCategory _category = _HouseCategory.kitchen;

  void _toggleExpand(_HouseExpand next) {
    setState(() {
      _expand = _expand == next ? _HouseExpand.none : next;
    });
  }

  void _selectCategory(_HouseCategory next) {
    setState(() {
      _category = next;
      // Панели доступно/накоплено — в макетах кухни; при смене вкладки закрываем.
      _expand = _HouseExpand.none;
    });
  }

  String get _asset {
    if (_expand == _HouseExpand.available) return AppAssets.houseAvailable;
    if (_expand == _HouseExpand.saved) return AppAssets.houseSaved;
    return switch (_category) {
      _HouseCategory.kitchen => AppAssets.house,
      _HouseCategory.clothes => AppAssets.houseClothes,
      _HouseCategory.shower => AppAssets.houseShower,
    };
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
          category: _expand == _HouseExpand.none
              ? _category
              : _HouseCategory.kitchen,
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
        // Карточка «Доступно»
        SvgHitArea(
          left: 14,
          top: 130.2,
          width: 177.3,
          height: 57.6,
          onTap: () => _toggleExpand(_HouseExpand.available),
        ),
        // Карточка «Накоплено»
        SvgHitArea(
          left: 201.7,
          top: 130.2,
          width: 177.3,
          height: 57.6,
          onTap: () => _toggleExpand(_HouseExpand.saved),
        ),
        // Вкладки: кухня / одежда / душ
        SvgHitArea(
          left: 12.5,
          top: 607.5,
          width: 70,
          height: 42,
          onTap: () => _selectCategory(_HouseCategory.kitchen),
        ),
        SvgHitArea(
          left: 88.5,
          top: 607.5,
          width: 70,
          height: 42,
          onTap: () => _selectCategory(_HouseCategory.clothes),
        ),
        SvgHitArea(
          left: 164.5,
          top: 607.5,
          width: 70,
          height: 42,
          onTap: () => _selectCategory(_HouseCategory.shower),
        ),
      ],
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
        // Уровень доверия 1…3 — пока от стрика (как в макете 2/3).
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

  /// Блок «Цель накоплений» + название цели.
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
            // 0/6.000 — к правому краю полосы, по центру блока заголовка.
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
  // Фоллбек по цене, если старый профиль без goalImageAsset.
  for (final g in GoalsPage.goals) {
    final price =
        int.tryParse(g.price.replaceAll(RegExp(r'[^\d]'), '')) ?? -1;
    if (price == p.goalPrice) return g.imageAsset;
  }
  return AppAssets.goalBicycle;
}

/// Картинки слотов инвентаря поверх рамок из SVG.
class _HouseInventoryOverlay extends StatelessWidget {
  const _HouseInventoryOverlay({required this.category});

  final _HouseCategory category;

  /// Рамки слотов — картинка у верхнего края (как в макете).
  static const _slots8 = <(double left, double top, double size)>[
    (45, 671, 52),
    (128, 671, 52),
    (212, 671, 52),
    (295, 671, 52),
    (46, 752, 52),
    (128, 752, 52),
    (212, 752, 52),
    (294, 752, 52),
  ];

  static const _slots4 = <(double left, double top, double size)>[
    (45, 671, 52),
    (128, 671, 52),
    (212, 671, 52),
    (295, 671, 52),
  ];

  @override
  Widget build(BuildContext context) {
    final items = switch (category) {
      _HouseCategory.kitchen => AppAssets.houseInventory,
      _HouseCategory.clothes => AppAssets.houseClothesInventory,
      _HouseCategory.shower => AppAssets.houseShowerInventory,
    };
    final slots = category == _HouseCategory.shower ? _slots4 : _slots8;

    return Stack(
      children: [
        for (var i = 0; i < items.length && i < slots.length; i++)
          Positioned(
            left: slots[i].$1,
            top: slots[i].$2,
            width: slots[i].$3,
            height: slots[i].$3,
            child: Image.asset(
              items[i],
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
      ],
    );
  }
}
