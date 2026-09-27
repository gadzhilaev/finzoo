import 'package:flutter/material.dart';

import '../../../core/profile/game_controller.dart';
import '../../../core/profile/player_profile.dart';
import '../../../core/theme/app_fonts.dart';
import 'practice/practice_catalog.dart';

/// Экран для взрослого: прозрачный прогресс, история и сброс профиля.
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Сбросить профиль?'),
        content: const Text(
          'Удалятся игровой день, деньги, инвентарь, цели и история. '
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await controller.resetProfile();
    onResetDone?.call();
  }

  Future<void> _confirmDemo(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Загрузить демо-профиль?'),
        content: const Text(
          'Текущий прогресс будет заменён учебным профилем с пятью игровыми днями.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Загрузить'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.loadDemoProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFCF4),
        foregroundColor: const Color(0xFF1B6943),
        elevation: 0,
        leading: IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Для взрослого',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF1B6943),
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final p = controller.profile;
          final practices = PracticeCatalog.completedIds(
            p.parkCompletedIds,
          ).length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              _Card(
                title: 'Профиль ребёнка',
                child: Text(
                  '${p.name.isEmpty ? 'Игрок' : p.name}, ${p.age} лет\n'
                  'Игровой день: ${p.periodIndex}\n'
                  'Серия: ${p.streakDays} ${p.streakDays == 1 ? 'день' : 'дней'}',
                  style: _body,
                ),
              ),
              _Card(
                title: 'Рост Finzo',
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
              _Card(
                title: 'Прогресс обучения',
                child: Text(
                  'Практика: $practices из 6 заданий\n'
                  'Книга: 7 тем доступны в разделе «Книжка»\n'
                  'Полученные цели: ${p.completedGoalTitles.isEmpty ? 'пока нет' : p.completedGoalTitles.join(', ')}',
                  style: _body,
                ),
              ),
              _Card(
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
              _Card(
                title: 'Последние операции',
                child: p.transactionHistory.isEmpty
                    ? Text(
                        'Покупки и движения копилки появятся здесь.',
                        style: _body,
                      )
                    : Column(
                        children: [
                          for (final item in p.transactionHistory.take(12))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text('• $item', style: _body),
                            ),
                        ],
                      ),
              ),
              _Card(
                title: 'Настройки доступности',
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Анимации', style: _body),
                      subtitle: Text(
                        'Плавные переходы между экранами',
                        style: _hint,
                      ),
                      value: p.animationsEnabled,
                      onChanged: (value) => controller.setAccessibility(
                        animationsEnabled: value,
                        soundsEnabled: p.soundsEnabled,
                      ),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Звуки', style: _body),
                      subtitle: Text(
                        'Сохранится для будущих звуковых подсказок',
                        style: _hint,
                      ),
                      value: p.soundsEnabled,
                      onChanged: (value) => controller.setAccessibility(
                        animationsEnabled: p.animationsEnabled,
                        soundsEnabled: value,
                      ),
                    ),
                  ],
                ),
              ),
              _Card(title: 'Словарь', child: const _Glossary()),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () => _confirmDemo(context),
                icon: const Icon(Icons.science_outlined),
                label: Text(
                  'Загрузить демо-профиль',
                  style: AppFonts.rubik(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4B946A),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _confirmReset(context),
                icon: const Icon(Icons.restart_alt_rounded),
                label: Text(
                  'Сбросить профиль',
                  style: AppFonts.rubik(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB33A21),
                  side: const BorderSide(color: Color(0xFFB33A21)),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

final _body = AppFonts.rubik(
  fontWeight: FontWeight.w500,
  fontSize: 14,
  height: 1.35,
  color: const Color(0xFF4A4643),
);
final _emphasis = AppFonts.rubik(
  fontWeight: FontWeight.w700,
  fontSize: 16,
  color: const Color(0xFF1B6943),
);
final _hint = AppFonts.rubik(
  fontWeight: FontWeight.w500,
  fontSize: 12,
  color: const Color(0xFF5B4300),
);

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF7E6),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF1B6943)),
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
                color: i <= active
                    ? const Color(0xFF4B946A)
                    : const Color(0xFFE8E0D0),
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
