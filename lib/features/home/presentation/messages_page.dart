import 'package:flutter/material.dart';

import '../../../core/profile/game_controller.dart';
import '../../../core/profile/player_rules.dart';
import '../../../core/theme/app_fonts.dart';

enum _MsgKind { petTip, lesson }

class _Msg {
  const _Msg({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final String id;
  final _MsgKind kind;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;
}

/// Локальные подсказки Finzo (не чат). Учебные примеры мошенников — отдельно.
class MessagesPage extends StatefulWidget {
  const MessagesPage({
    super.key,
    required this.controller,
    this.onBack,
    this.onOpenBook,
    this.onOpenHouse,
    this.onOpenGames,
    this.onOpenBudget,
  });

  final GameController controller;
  final VoidCallback? onBack;
  final VoidCallback? onOpenBook;
  final VoidCallback? onOpenHouse;
  final VoidCallback? onOpenGames;
  final VoidCallback? onOpenBudget;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  late List<_Msg> _items;

  @override
  void initState() {
    super.initState();
    _items = _build();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.markMessagesSeen(_items.map((e) => e.id));
    });
  }

  List<_Msg> _build() {
    final p = widget.controller.profile;
    final seen = p.seenMessageIds.toSet();
    final out = <_Msg>[];

    void add(_Msg m) {
      // Не дублируем уже показанные id, кроме «свежих» по состоянию.
      if (seen.contains(m.id) && m.kind == _MsgKind.lesson) return;
      out.add(m);
    }

    if (p.satiety < 45) {
      add(_Msg(
        id: 'tip_hungry_${p.periodIndex}',
        kind: _MsgKind.petTip,
        title: 'Finzo хочет есть',
        body:
            'Сытость ${p.satiety.round()}%. Она падает примерно на '
            '${PlayerRules.satietyDecayPerHour} в час. Загляни на кухню в доме.',
        actionLabel: 'В дом',
        onAction: widget.onOpenHouse,
      ));
    } else if (p.satiety >= 80) {
      add(_Msg(
        id: 'tip_fed_${p.periodIndex}',
        kind: _MsgKind.petTip,
        title: 'Finzo сыт',
        body: 'Сытость в порядке. Можно заняться планом или практикой с Finzo.',
        actionLabel: 'К практике',
        onAction: widget.onOpenGames,
      ));
    }

    if (p.mood < 40) {
      add(_Msg(
        id: 'tip_mood_${p.periodIndex}',
        kind: _MsgKind.petTip,
        title: 'Настроение грустит',
        body:
            'Настроение ${p.mood.round()}%. Помогут душ или новая одежда '
            '(каждая вещь поднимает настроение один раз).',
        actionLabel: 'В дом',
        onAction: widget.onOpenHouse,
      ));
    }

    if (p.needsBudgetPlan) {
      add(_Msg(
        id: 'tip_budget_${p.periodIndex}',
        kind: _MsgKind.petTip,
        title: 'Нужен план на день',
        body: 'Распредели деньги на необходимое, желания и копилку.',
        actionLabel: 'План бюджета',
        onAction: widget.onOpenBudget,
      ));
    }

    if (p.savedBalance < p.goalPrice && p.goalPrice > 0) {
      add(_Msg(
        id: 'tip_goal_${p.periodIndex}',
        kind: _MsgKind.petTip,
        title: 'Цель: ${p.goalTitle.isEmpty ? 'накопления' : p.goalTitle}',
        body:
            'Накоплено ${p.savedBalance} из ${p.goalPrice}. '
            'Откладывай часть в копилку — без спешки.',
      ));
    }

    // Учебный блок — явно отделён
    add(_Msg(
      id: 'lesson_scam_once',
      kind: _MsgKind.lesson,
      title: 'Учебный пример (не настоящее сообщение)',
      body:
          'В книжке разбираем поддельные письма: код из SMS, «приз» за оплату, '
          'чужой заказ. Это тренировка, а не чат с магазином.',
      actionLabel: 'Открыть книжку',
      onAction: widget.onOpenBook,
    ));

    if (out.isEmpty) {
      out.add(const _Msg(
        id: 'tip_idle',
        kind: _MsgKind.petTip,
        title: 'Пока тихо',
        body: 'Когда сытость или настроение изменятся, здесь появятся подсказки.',
      ));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: const Color(0xFF1B6943),
                  ),
                  Expanded(
                    child: Text(
                      'Сообщения Finzo',
                      textAlign: TextAlign.center,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: const Color(0xFF1B6943),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onOpenBook,
                    icon: const Icon(Icons.menu_book_rounded),
                    color: const Color(0xFF1B6943),
                  ),
                ],
              ),
              Text(
                'Подсказки по игре. Это не настоящий чат.',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: const Color(0xFFDF9548),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final m = _items[i];
                    final isLesson = m.kind == _MsgKind.lesson;
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isLesson
                            ? const Color(0xFFFFF3CD)
                            : const Color(0xFFFEF7E6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isLesson
                              ? const Color(0xFFDF9548)
                              : const Color(0xFF1B6943),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isLesson ? 'УРОК · ${m.title}' : m.title,
                            style: AppFonts.rubik(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: const Color(0xFF1B6943),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m.body,
                            style: AppFonts.rubik(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              height: 1.35,
                              color: const Color(0xFF4A4643),
                            ),
                          ),
                          if (m.actionLabel != null && m.onAction != null) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: m.onAction,
                                child: Text(
                                  m.actionLabel!,
                                  style: AppFonts.rubik(
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1B6943),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
