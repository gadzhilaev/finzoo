import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_fonts.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/profile/game_controller.dart';
import '../../../../core/profile/player_rules.dart';
import '../../../../core/theme/app_colors.dart';

/// Патчи поверх SVG: имя, стрик, цифры баланса и статусов.
/// Иконки, рамки бейджа и огонь — из макета.
class HubHudOverlay extends StatelessWidget {
  const HubHudOverlay({
    super.key,
    required this.controller,
    required this.showSavedCard,
    this.balanceTop = 221,
    this.coverHeaderLabels = true,
    this.showStreetHeaderIcons = false,
    this.onCompleteTask,
    this.satietyPercentLeft = 148,
    this.moodPercentLeft = 325,
    this.statsPercentTop = 548,
  });

  final GameController controller;
  final bool showSavedCard;
  final double balanceTop;

  /// Когда в SVG ещё остались «Магомед» / «5 дней» — закрываем их кремом.
  /// На улице макет уже без этих подписей — ставим `false`.
  final bool coverHeaderLabels;

  /// Улица: логотип и огонь рисуем оверлеем (в SVG вырезаны).
  final bool showStreetHeaderIcons;
  final VoidCallback? onCompleteTask;

  final double satietyPercentLeft;
  final double moodPercentLeft;
  final double statsPercentTop;

  static const _headerCream = Color(0xFFFCF9F6);

  /// Высота карточек баланса в макете (улица и дом).
  static const balanceCardHeight = 57.6234;

  /// Зазор лого↔имя и бейдж↔огонёк.
  static const headerGap = 8.0;

  static TextStyle get _availableLabelStyle => AppFonts.rubik(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1,
        color: const Color(0xFF5B4300),
      );

  static TextStyle get _savedLabelStyle => AppFonts.rubik(
        fontWeight: FontWeight.w600,
        fontSize: 11,
        height: 1,
        color: const Color(0xFF1B6943),
      );

  static TextStyle get _balanceAmountStyle => AppFonts.rubik(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        height: 1,
        color: AppColors.textPrimary,
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.profile;
        final name = p.name.isEmpty ? 'Друг' : p.name;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (coverHeaderLabels)
              const Positioned(
                left: 40,
                top: 58,
                width: 170,
                height: 36,
                child: ColoredBox(color: _headerCream),
              ),
            // Логотип + имя: одна линия по центру, прижаты слева.
            if (showStreetHeaderIcons)
              Positioned(
                left: 14,
                top: 65.4,
                width: 200,
                height: 27,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppAssets.streetLogo,
                      width: 24.32,
                      height: 26.96,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: headerGap),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          height: 1,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Positioned(
                left: 50,
                top: 65.4,
                width: 165,
                height: 27,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      height: 1,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ),
            if (coverHeaderLabels)
              const Positioned(
                left: 232,
                top: 70,
                width: 95,
                height: 20,
                child: ColoredBox(color: Color(0xFFFCEFE8)),
              ),
            // Стрик + огонь прижаты справа; зазор как у лого↔имя.
            if (showStreetHeaderIcons)
              Positioned(
                right: 14,
                top: 65.4,
                height: 28,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _StreakPill(label: PlayerRules.streakLabel(p.streakDays)),
                    const SizedBox(width: headerGap),
                    const _StreetFlameIcon(),
                  ],
                ),
              )
            else
              Positioned(
                left: 238,
                top: 67.4,
                width: 94,
                height: 25,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    PlayerRules.streakLabel(p.streakDays),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1,
                      color: const Color(0xFFCD5E2A),
                    ),
                  ),
                ),
              ),
            // «Доступно» / «Накоплено» + сумма — по центру карточки вместе с иконкой.
            Positioned(
              left: showSavedCard ? 68 : 77,
              top: balanceTop,
              width: showSavedCard ? 108 : 78,
              height: balanceCardHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Доступно',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: _availableLabelStyle,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${p.availableBalance}',
                    maxLines: 1,
                    softWrap: false,
                    style: _balanceAmountStyle,
                  ),
                ],
              ),
            ),
            if (showSavedCard)
              Positioned(
                left: 255,
                top: balanceTop,
                width: 110,
                height: balanceCardHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Накоплено',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: _savedLabelStyle,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${p.savedBalance}',
                      maxLines: 1,
                      softWrap: false,
                      style: _balanceAmountStyle,
                    ),
                  ],
                ),
              ),
            // % на одной линии с иконкой и подписью «Сытость» / «Настроение».
            Positioned(
              left: satietyPercentLeft,
              top: statsPercentTop,
              width: 42,
              height: 16,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${p.satiety.round()}%',
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1,
                    color: const Color(0xFF1B6943),
                  ),
                ),
              ),
            ),
            Positioned(
              left: moodPercentLeft,
              top: statsPercentTop,
              width: 42,
              height: 16,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${p.mood.round()}%',
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1,
                    color: const Color(0xFFCD5E2A),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 25.5,
              top: 567.5,
              width: 164.5,
              height: 9,
              child: _MiniBar(
                value: p.satiety / 100,
                fill: const Color(0xFF1B6943),
                border: const Color(0xFF1B6943),
              ),
            ),
            Positioned(
              left: 203,
              top: 567.5,
              width: 164.5,
              height: 9,
              child: _MiniBar(
                value: p.mood / 100,
                fill: const Color(0xFFFDD889),
                border: const Color(0xFFDE984D),
              ),
            ),
            if (onCompleteTask != null)
              Positioned(
                left: 54,
                top: 740,
                width: 285,
                height: 56,
                child: GestureDetector(
                  onTap: onCompleteTask,
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      padding: const EdgeInsets.only(left: 10, right: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x1ACD5E2A),
        borderRadius: BorderRadius.circular(12.5),
        border: Border.all(color: const Color(0x8ACD5E2A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Color(0xFFCD5E2A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1,
              color: const Color(0xFFCD5E2A),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreetFlameIcon extends StatelessWidget {
  const _StreetFlameIcon();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.streetFlame,
      width: 22,
      height: 28,
      fit: BoxFit.fill,
    );
  }
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.value,
    required this.fill,
    required this.border,
  });

  final double value;
  final Color fill;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.5),
        border: Border.all(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.5),
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          alignment: Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
