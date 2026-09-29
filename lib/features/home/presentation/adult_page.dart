import 'package:flutter/material.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/game_controller.dart';
import '../../../core/profile/player_profile.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/finzo_hit_target.dart';
import '../../../core/theme/finzo_ui.dart';
import 'book/book_content.dart';
import 'practice/practice_catalog.dart';

/// Экран для взрослого: прогресс, настройки, демо и сброс — стиль Finzo.
class AdultPage extends StatelessWidget {
  const AdultPage({
    super.key,
    required this.controller,
    this.onBack,
    this.onResetDone,
  });

  final GameController controller;
  final VoidCallback? onBack;
  final VoidCallback? onResetDone;

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showFinzoConfirmDialog(
      context: context,
      title: 'Сбросить профиль?',
      body:
          'Удалятся игровой день, деньги, инвентарь, цели и история. '
          'Это действие нельзя отменить.',
      confirmLabel: 'Сбросить',
      iconAsset: AppAssets.iconReset,
      warm: true,
    );
    if (confirmed != true) return;
    await controller.resetProfile();
    onResetDone?.call();
  }

  Future<void> _confirmDemo(BuildContext context) async {
    final confirmed = await showFinzoConfirmDialog(
      context: context,
      title: 'Загрузить демо-профиль?',
      body:
          'Текущий прогресс будет заменён учебным профилем с пятью игровыми днями.',
      confirmLabel: 'Загрузить',
      iconAsset: AppAssets.iconDemo,
    );
    if (confirmed == true) await controller.loadDemoProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FinzoUi.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    tooltip: 'Назад',
                    style: FinzoHitTarget.iconButtonStyle(
                      foregroundColor: FinzoUi.green,
                    ),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const FinzoOutlineIcon(AppAssets.iconAdult, size: 26),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Для взрослых',
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: FinzoUi.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  final p = controller.profile;
                  final practices = PracticeCatalog.completedIds(
                    p.parkCompletedIds,
                  ).length;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      _FinzoCard(
                        title: 'Как сюда попасть',
                        child: Text(
                          'Кнопка с иконкой взрослого и ребёнка в «Сообщениях» '
                          'или долгое нажатие на имя ребёнка на улице или в доме. '
                          'Далее пример 8 + 7.',
                          style: _body,
                        ),
                      ),
                      _FinzoCard(
                        title: 'Профиль ребёнка',
                        child: Text(
                          '${p.name.isEmpty ? 'Игрок' : p.name}, ${p.age} лет\n'
                          'Игровой день: ${p.periodIndex}\n'
                          'Серия: ${p.streakDays} ${p.streakDays == 1 ? 'день' : 'дней'}',
                          style: _body,
                        ),
                      ),
                      _FinzoCard(
                        title: 'Как растёт Finzo',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.growthStage.title, style: _emphasis),
                            const SizedBox(height: 4),
                            Text(p.growthStage.description, style: _body),
                            const SizedBox(height: 10),
                            _GrowthLine(stage: p.growthStage),
                            const SizedBox(height: 6),
                            Text(
                              'Очки роста: ${p.growthPoints}. Нужное даёт 2, план без превышения — 1, накопления — 1.',
                              style: _hint,
                            ),
                          ],
                        ),
                      ),
                      _FinzoCard(
                        title: 'Прогресс',
                        child: Text(
                          'Практика: $practices из ${PracticeCatalog.all.length} заданий\n'
                          'Книга: ${BookContent.flatPageCount} экранов в разделе «Книжка»\n'
                          'Полученные цели: ${p.completedGoalTitles.isEmpty ? 'пока нет' : p.completedGoalTitles.join(', ')}',
                          style: _body,
                        ),
                      ),
                      _FinzoCard(
                        title: 'История игровых дней',
                        child: p.periodHistory.isEmpty
                            ? Text(
                                'Заверши первый игровой день — здесь появится итог.',
                                style: _body,
                              )
                            : Column(
                                children: [
                                  for (final item in p.periodHistory)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Text('• $item', style: _body),
                                    ),
                                ],
                              ),
                      ),
                      _FinzoCard(
                        title: 'Последние операции',
                        child: p.transactionHistory.isEmpty
                            ? Text(
                                'Покупки и движения копилки появятся здесь.',
                                style: _body,
                              )
                            : Column(
                                children: [
                                  for (final item
                                      in p.transactionHistory.take(12))
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text('• $item', style: _body),
                                    ),
                                ],
                              ),
                      ),
                      _FinzoCard(
                        title: 'Настройки',
                        child: Column(
                          children: [
                            FinzoSettingsRow(
                              iconAsset: AppAssets.iconAnimation,
                              title: 'Анимации',
                              subtitle: 'Плавные переходы и движения Finzo',
                              value: p.animationsEnabled,
                              animateToggle: p.animationsEnabled,
                              onChanged: (value) => controller.setAccessibility(
                                animationsEnabled: value,
                                soundsEnabled: p.soundsEnabled,
                              ),
                            ),
                            const SizedBox(height: 4),
                            FinzoSettingsRow(
                              iconAsset: AppAssets.iconSound,
                              title: 'Звуки',
                              subtitle:
                                  'Сейчас в приложении нет звуковых эффектов. '
                                  'Переключатель сохранён и применится, когда '
                                  'звуки появятся.',
                              value: p.soundsEnabled,
                              animateToggle: p.animationsEnabled,
                              onChanged: (value) => controller.setAccessibility(
                                animationsEnabled: p.animationsEnabled,
                                soundsEnabled: value,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _FinzoCard(
                        title: 'Словарь',
                        child: const _Glossary(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Демонстрация',
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: FinzoUi.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FinzoPrimaryAction(
                        label: 'Загрузить демо-профиль',
                        iconAsset: AppAssets.iconDemo,
                        onTap: () => _confirmDemo(context),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Данные',
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: FinzoUi.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      FinzoWarmAction(
                        label: 'Сбросить профиль',
                        iconAsset: AppAssets.iconReset,
                        onTap: () => _confirmReset(context),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _body = AppFonts.rubik(
  fontWeight: FontWeight.w500,
  fontSize: 14,
  height: 1.35,
  color: FinzoUi.body,
);
final _emphasis = AppFonts.rubik(
  fontWeight: FontWeight.w700,
  fontSize: 16,
  color: FinzoUi.green,
);
final _hint = AppFonts.rubik(
  fontWeight: FontWeight.w500,
  fontSize: 12,
  color: const Color(0xFF5B4300),
);

class _FinzoCard extends StatelessWidget {
  const _FinzoCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FinzoUi.mint,
        borderRadius: BorderRadius.circular(FinzoUi.radiusCard),
        border: Border.all(
          color: FinzoUi.green.withValues(alpha: 0.45),
          width: FinzoUi.strokeW,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _emphasis),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _GrowthLine extends StatelessWidget {
  const _GrowthLine({required this.stage});
  final PetGrowthStage stage;

  @override
  Widget build(BuildContext context) {
    final active = stage.index;
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: i <= active ? FinzoUi.arrowGreen : const Color(0xFFE8E0D0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (i < 2) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _Glossary extends StatelessWidget {
  const _Glossary();

  @override
  Widget build(BuildContext context) => Text(
        'Бюджет — план, на что пойдут деньги.\n\n'
        'Необходимое — еда, уход и важные вещи.\n\n'
        'Желания — покупки, без которых можно подождать.\n\n'
        'Накопления — деньги, которые откладывают на цель.\n\n'
        'Чек — список того, что купили и сколько это стоило.',
        style: _body,
      );
}
