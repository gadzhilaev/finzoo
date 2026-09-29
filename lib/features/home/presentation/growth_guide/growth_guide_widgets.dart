import 'package:flutter/material.dart';

import '../../../../core/profile/player_profile.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/finzo_book_tokens.dart';
import '../../../../core/wardrobe/finzo_avatar.dart';
import '../book/book_widgets.dart';
import 'growth_guide_data.dart';

/// Цепочка Малыш → Растущий → Самостоятельный.
class GrowthStageChain extends StatelessWidget {
  const GrowthStageChain({
    super.key,
    required this.profile,
    required this.current,
    this.animate = true,
  });

  final PlayerProfile profile;
  final PetGrowthStage current;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < PetGrowthStage.values.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 36, left: 2, right: 2),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: BookStyle.green.withValues(alpha: 0.55),
              ),
            ),
          Expanded(
            child: _StageNode(
              profile: profile,
              stage: PetGrowthStage.values[i],
              selected: PetGrowthStage.values[i] == current,
              animate: animate,
            ),
          ),
        ],
      ],
    );
  }
}

class _StageNode extends StatelessWidget {
  const _StageNode({
    required this.profile,
    required this.stage,
    required this.selected,
    required this.animate,
  });

  final PlayerProfile profile;
  final PetGrowthStage stage;
  final bool selected;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final points = switch (stage) {
      PetGrowthStage.little => 0,
      PetGrowthStage.growing => 6,
      PetGrowthStage.confident => 12,
    };
    final label = switch (stage) {
      PetGrowthStage.little => 'Малыш',
      PetGrowthStage.growing => 'Растущий',
      PetGrowthStage.confident => 'Сам.',
    };
    final h = switch (stage) {
      PetGrowthStage.little => 52.0,
      PetGrowthStage.growing => 66.0,
      PetGrowthStage.confident => 80.0,
    };

    final card = Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      decoration: BoxDecoration(
        color: selected ? BookStyle.mint : Colors.white,
        borderRadius: BorderRadius.circular(FinzoBookTokens.cardRadius),
        border: Border.all(
          color: selected
              ? BookStyle.green
              : BookStyle.green.withValues(alpha: 0.28),
          width: selected ? 2 : FinzoBookTokens.cardBorderWidth,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 72,
            child: ClipRect(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FinzoAvatar(
                  profile: profile.copyWith(growthPoints: points),
                  width: h * 0.78,
                  height: h,
                  alignBodyAxis: true,
                  bodyAxisFactor: 0.45,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              color: BookStyle.green,
            ),
          ),
        ],
      ),
    );

    if (!animate) return card;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: card,
    );
  }
}

/// Карточка правила +2 / +1.
class GrowthScoreRuleCard extends StatelessWidget {
  const GrowthScoreRuleCard({
    super.key,
    required this.rule,
    this.petName = 'Finz',
  });

  final GrowthScoreRule rule;
  final String petName;

  @override
  Widget build(BuildContext context) {
    final text = rule.text.replaceAll('Finz', petName);
    final iconData = switch (rule.icon) {
      GrowthScoreIcon.care => Icons.restaurant_rounded,
      GrowthScoreIcon.plan => Icons.account_balance_wallet_outlined,
      GrowthScoreIcon.piggy => Icons.savings_outlined,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BookStyle.green.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: BookStyle.mint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BookStyle.green.withValues(alpha: 0.4)),
            ),
            child: Text(
              '+${rule.points}',
              style: AppFonts.rubik(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: BookStyle.green,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.title,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: BookStyle.green,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    height: 1.3,
                    color: BookStyle.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(iconData, color: BookStyle.orange, size: 26),
        ],
      ),
    );
  }
}

/// Прогресс до следующего уровня.
class GrowthStageProgress extends StatelessWidget {
  const GrowthStageProgress({
    super.key,
    required this.points,
    required this.nextScore,
    required this.animate,
  });

  final int points;
  final int nextScore;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final clamped = points.clamp(0, nextScore);
    final target = nextScore <= 0 ? 0.0 : clamped / nextScore;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: BookStyle.mint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BookStyle.green.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'До следующего уровня',
            style: AppFonts.rubik(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: BookStyle.green,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: animate
                  ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: target),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 12,
                          backgroundColor: Colors.white,
                          color: BookStyle.arrowGreen,
                        );
                      },
                    )
                  : LinearProgressIndicator(
                      value: target,
                      minHeight: 12,
                      backgroundColor: Colors.white,
                      color: BookStyle.arrowGreen,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$clamped / $nextScore очков',
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: BookStyle.body,
            ),
          ),
        ],
      ),
    );
  }
}

/// Крупный портрет стадии — строго в своём слоте, с ClipRect.
class GrowthHeroPet extends StatelessWidget {
  const GrowthHeroPet({
    super.key,
    required this.profile,
    required this.stage,
    required this.animate,
    this.celebrate = false,
  });

  final PlayerProfile profile;
  final PetGrowthStage stage;
  final bool animate;
  final bool celebrate;

  @override
  Widget build(BuildContext context) {
    final points = switch (stage) {
      PetGrowthStage.little => 0,
      PetGrowthStage.growing => 6,
      PetGrowthStage.confident => 12,
    };
    final size = switch (stage) {
      PetGrowthStage.little => 88.0,
      PetGrowthStage.growing => 100.0,
      PetGrowthStage.confident => 112.0,
    };

    Widget pet = SizedBox(
      height: size,
      width: double.infinity,
      child: ClipRect(
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.hardEdge,
          children: [
            if (celebrate) ...[
              Positioned(
                left: 36,
                top: 4,
                child: Icon(
                  Icons.star_rounded,
                  size: 16,
                  color: BookStyle.orange.withValues(alpha: 0.85),
                ),
              ),
              Positioned(
                right: 40,
                top: 10,
                child: Icon(
                  Icons.circle,
                  size: 7,
                  color: BookStyle.arrowGreen.withValues(alpha: 0.7),
                ),
              ),
            ],
            FinzoAvatar(
              profile: profile.copyWith(growthPoints: points),
              width: size * 0.82,
              height: size,
              alignBodyAxis: true,
              bodyAxisFactor: 0.45,
            ),
          ],
        ),
      ),
    );

    if (!animate) return pet;
    return TweenAnimationBuilder<double>(
      key: ValueKey(stage),
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: pet,
    );
  }
}

/// Короткая оранжевая подсказка в духе макетов.
class GrowthHintLine extends StatelessWidget {
  const GrowthHintLine({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppFonts.rubik(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        height: 1.3,
        color: BookStyle.orange,
      ),
    );
  }
}
