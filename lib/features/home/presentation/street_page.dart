import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/budget_plan.dart';
import '../../../core/profile/game_controller.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/wardrobe/finzo_avatar.dart';
import 'practice/practice_catalog.dart';
import 'widgets/hub_hud_overlay.dart';
import 'widgets/pet_stats_panel.dart';
import 'widgets/savings_dialog.dart';
import 'widgets/street_sky_layer.dart';
import 'widgets/svg_scene_page.dart';

/// Улица: сцена SVG + баланс/цель + карточка дня с Finzo.
class StreetPage extends StatelessWidget {
  const StreetPage({
    super.key,
    required this.controller,
    this.onOpenHouse,
    this.onOpenMessages,
    this.onOpenGames,
    this.onOpenBudget,
    this.onOpenTask,
    this.onOpenResults,
    this.onChooseNextGoal,
  });

  final GameController controller;
  final VoidCallback? onOpenHouse;
  final VoidCallback? onOpenMessages;
  final VoidCallback? onOpenGames;
  final VoidCallback? onOpenBudget;
  final VoidCallback? onOpenTask;
  final VoidCallback? onOpenResults;
  final VoidCallback? onChooseNextGoal;

  @override
  Widget build(BuildContext context) {
    return SvgScenePage(
      asset: AppAssets.street,
      backgroundColor: const Color(0xFFD7F9FF),
      overlays: [
        const StreetSkyLayer(),
        HubHudOverlay(
          controller: controller,
          showSavedCard: false,
          balanceTop: 221,
          coverHeaderLabels: false,
          showStreetHeaderIcons: true,
        ),
        _StreetGoalSavingsCard(
          controller: controller,
          onOpenSavings: () => showSavingsDialog(
            context,
            controller,
            onChooseNextGoal: onChooseNextGoal,
          ),
        ),
        ListenableBuilder(
          listenable: controller,
          builder: (context, _) {
            return Positioned(
              left: 118,
              top: 318,
              width: 150,
              height: 175,
              child: IgnorePointer(
                child: FinzoAvatar(
                  profile: controller.profile,
                  width: 150,
                  height: 175,
                ),
              ),
            );
          },
        ),
        PetStatsPanel(controller: controller, top: 528),
        _StreetBottomPanel(
          controller: controller,
          onOpenBudget: onOpenBudget,
          onOpenGames: onOpenGames,
          onOpenTask: onOpenTask,
          onOpenResults: onOpenResults,
        ),
      ],
      hits: [
        SvgHitArea(
          left: 17,
          top: 447,
          width: 45,
          height: 45,
          semanticsLabel: 'Дом',
          onTap: () => onOpenHouse?.call(),
        ),
        SvgHitArea(
          left: 328.5,
          top: 387.5,
          width: 44,
          height: 44,
          semanticsLabel: 'Сообщения',
          onTap: () => onOpenMessages?.call(),
        ),
        SvgHitArea(
          left: 328.5,
          top: 447.5,
          width: 44,
          height: 44,
          semanticsLabel: 'Игры',
          onTap: () => onOpenGames?.call(),
        ),
      ],
    );
  }
}

/// Карточка цели: название, накоплено, стоимость.
class _StreetGoalSavingsCard extends StatelessWidget {
  const _StreetGoalSavingsCard({
    required this.controller,
    required this.onOpenSavings,
  });

  final GameController controller;
  final VoidCallback onOpenSavings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.profile;
        final title = p.goalTitle.isEmpty ? 'Цель' : p.goalTitle;
        return Positioned(
          left: 201.7,
          top: 221,
          width: 177.3,
          height: HubHudOverlay.balanceCardHeight,
          child: Material(
            color: const Color(0xFFFEF7E6),
            borderRadius: BorderRadius.circular(13.9),
            child: InkWell(
              onTap: onOpenSavings,
              borderRadius: BorderRadius.circular(13.9),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13.9),
                  border: Border.all(
                    color: const Color(0xFF1B6943).withValues(alpha: 0.22),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        height: 1,
                        color: const Color(0xFF1B6943),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${p.savedBalance} / ${p.goalPrice} ₽',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.05,
                        color: const Color(0xFF1B1B1B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StreetBottomPanel extends StatelessWidget {
  const _StreetBottomPanel({
    required this.controller,
    this.onOpenBudget,
    this.onOpenGames,
    this.onOpenTask,
    this.onOpenResults,
  });

  final GameController controller;
  final VoidCallback? onOpenBudget;
  final VoidCallback? onOpenGames;
  final VoidCallback? onOpenTask;
  final VoidCallback? onOpenResults;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final p = controller.profile;
        final phase = p.periodPhase;
        final done = PracticeCatalog.completedIds(p.periodPracticeCompletedIds);
        final exercise = PracticeCatalog.nextIncomplete(
          p.periodPracticeCompletedIds,
        );
        final taskDone = p.periodTaskDone || done.isNotEmpty;

        // Ближе к панели показателей (top 528 + ~56 ≈ 592).
        return Positioned(
          left: 12,
          right: 12,
          top: 598,
          bottom: 16,
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _panelBody(
                phase: phase,
                dayIndex: p.periodIndex,
                exerciseTitle: exercise.title,
                taskDone: taskDone,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _panelBody({
    required PeriodPhase phase,
    required int dayIndex,
    required String exerciseTitle,
    required bool taskDone,
  }) {
    if (phase == PeriodPhase.planning) {
      return _SceneCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'День с Finzo · $dayIndex',
              style: AppFonts.rubik(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: const Color(0xFF5B4300),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Сначала составь план на день',
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: const Color(0xFF1B6943),
              ),
            ),
            const SizedBox(height: 10),
            _PrimaryBtn(label: 'План бюджета', onTap: onOpenBudget),
          ],
        ),
      );
    }

    if (phase == PeriodPhase.results) {
      return _SceneCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'День $dayIndex закончился',
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: const Color(0xFF1B6943),
              ),
            ),
            const SizedBox(height: 10),
            _PrimaryBtn(label: 'Как прошёл день', onTap: onOpenResults),
          ],
        ),
      );
    }

    return _SceneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'День с Finzo · $dayIndex',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: const Color(0xFF5B4300),
                ),
              ),
              const Spacer(),
              if (taskDone)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B946A).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF4B946A)),
                  ),
                  child: Text(
                    'Разобрались!',
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: const Color(0xFF1B6943),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            exerciseTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: const Color(0xFF1B6943),
            ),
          ),
          const SizedBox(height: 10),
          if (taskDone)
            OutlinedButton(
              onPressed: onOpenGames,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1B6943),
                side: const BorderSide(color: Color(0xFF1B6943), width: 1.5),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Ещё практика с Finzo',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            )
          else
            _PrimaryBtn(label: 'Открыть упражнение', onTap: onOpenTask),
        ],
      ),
    );
  }
}

class _SceneCard extends StatelessWidget {
  const _SceneCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6C275), width: 1.2),
      ),
      child: child,
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF4B946A),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
