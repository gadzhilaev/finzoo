import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/profile/game_controller.dart';
import '../../../../core/theme/app_fonts.dart';
import 'practice_catalog.dart';
import 'practice_content.dart';
import 'practice_shell.dart';
import 'practice_widgets.dart';

Widget buildPracticeTask({
  required PracticeItem item,
  required GameController controller,
  required VoidCallback onDone,
}) {
  return switch (item.id) {
    PracticeCatalog.lunch =>
      LunchPracticePage(controller: controller, onDone: onDone),
    PracticeCatalog.dayPlan =>
      DayPlanPracticePage(controller: controller, onDone: onDone),
    PracticeCatalog.dreamSave =>
      DreamSavePracticePage(controller: controller, onDone: onDone),
    PracticeCatalog.planChange =>
      PlanChangePracticePage(controller: controller, onDone: onDone),
    PracticeCatalog.deal =>
      DealPracticePage(controller: controller, onDone: onDone),
    PracticeCatalog.receipt =>
      ReceiptPracticePage(controller: controller, onDone: onDone),
    _ => LunchPracticePage(controller: controller, onDone: onDone),
  };
}

// ─── Собери обед ─────────────────────────────────────────────

class LunchPracticePage extends StatefulWidget {
  const LunchPracticePage({
    super.key,
    required this.controller,
    required this.onDone,
  });
  final GameController controller;
  final VoidCallback onDone;
  @override
  State<LunchPracticePage> createState() => _LunchPracticePageState();
}

class _LunchPracticePageState extends State<LunchPracticePage> {
  final _picked = <String>{};
  String? _hint;
  String? _result;
  int _seed = 0;

  List<PracticeGoods> get _items {
    final base = PracticeContent.lunchItems.toList();
    if (_seed.isOdd) {
      base.insert(0, base.removeLast());
    }
    return base;
  }

  int get _spent => _items
      .where((i) => _picked.contains(i.id))
      .fold(0, (a, i) => a + i.price);

  bool get _hasMain =>
      _picked.any((id) => _items.any((e) => e.id == id && e.group == 'main'));
  bool get _hasDrink =>
      _picked.any((id) => _items.any((e) => e.id == id && e.group == 'drink'));

  List<PracticeGoods> get _selectedItems =>
      _items.where((e) => _picked.contains(e.id)).toList();

  void _toggle(PracticeGoods item) {
    setState(() {
      if (_picked.contains(item.id)) {
        _picked.remove(item.id);
      } else {
        if (_spent + item.price >
            PracticeContent.lunchBudgetFor(widget.controller.profile.periodIndex)) {
          _hint =
              'Не влезает в ${PracticeContent.lunchBudgetFor(widget.controller.profile.periodIndex)} монет. Убери что-то с подноса.';
          return;
        }
        if (item.group == 'main') {
          _picked.removeWhere(
            (id) => _items.any((e) => e.id == id && e.group == 'main'),
          );
        }
        if (item.group == 'drink') {
          _picked.removeWhere(
            (id) => _items.any((e) => e.id == id && e.group == 'drink'),
          );
        }
        _picked.add(item.id);
      }
      _hint = null;
    });
  }

  Future<void> _finish() async {
    if (!_hasMain || !_hasDrink) {
      setState(() {
        _hint = !_hasMain && !_hasDrink
            ? 'Нужны блюдо и напиток.'
            : (!_hasMain ? 'Добавь блюдо на поднос.' : 'Добавь напиток.');
      });
      return;
    }
    if (_spent > PracticeContent.lunchBudgetFor(widget.controller.profile.periodIndex)) {
      setState(() => _hint = 'Сверх бюджета — убери что-то с подноса.');
      return;
    }
    await widget.controller.markParkExerciseDone(PracticeCatalog.lunch);
    if (!mounted) return;
    final budget = PracticeContent.lunchBudgetFor(widget.controller.profile.periodIndex);
    final left = budget - _spent;
    setState(() {
      _result =
          'Потратил $_spent из $budget, осталось $left. '
          '${_picked.length > 2 ? 'Ещё и десерт — отлично при остатке.' : 'Обед готов.'}';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) {
      return PracticeShell(
        title: 'Собери обед',
        subtitle: 'Учебные монеты',
        onExit: widget.onDone,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text(
                    'Finzo доволен обедом!',
                    textAlign: TextAlign.center,
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: const Color(0xFF1B6943),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final item in _selectedItems)
                        Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E8),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFF1B6943)),
                              ),
                              child: item.imageAsset != null
                                  ? Image.asset(item.imageAsset!,
                                      fit: BoxFit.contain)
                                  : Icon(item.icon),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.title,
                              style: AppFonts.rubik(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: const Color(0xFF1B6943),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _result!,
                    textAlign: TextAlign.center,
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1.35,
                      color: const Color(0xFF4A4643),
                    ),
                  ),
                ],
              ),
            ),
            practicePrimaryBtn('Ещё раз', () => setState(() {
                  _seed++;
                  _picked.clear();
                  _result = null;
                  _hint = null;
                })),
            const SizedBox(height: 8),
            practicePrimaryBtn('К списку', widget.onDone),
          ],
        ),
      );
    }

    final budget = PracticeContent.lunchBudgetFor(widget.controller.profile.periodIndex);
    final left = budget - _spent;
    return PracticeShell(
      title: 'Собери обед',
      subtitle:
          'У тебя $budget монет. Выбери блюдо и напиток для Finzo',
      onExit: widget.onDone,
      bottom: practicePrimaryBtn('Подать обед', _finish),
      child: Column(
        children: [
          if (_hint != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FinzoMoodBanner(text: _hint!, happy: false),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Если останутся монеты, можно взять десерт',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: const Color(0xFFDF9548),
                ),
              ),
            ),
          _LunchTray(
            items: _selectedItems,
            spent: _spent,
            left: left,
            hasMain: _hasMain,
            hasDrink: _hasDrink,
            onRemove: _toggle,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.72,
              children: [
                for (final item in _items)
                  _LunchShelfCard(
                    item: item,
                    selected: _picked.contains(item.id),
                    onTap: () => _toggle(item),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LunchTray extends StatelessWidget {
  const _LunchTray({
    required this.items,
    required this.spent,
    required this.left,
    required this.hasMain,
    required this.hasDrink,
    required this.onRemove,
  });

  final List<PracticeGoods> items;
  final int spent;
  final int left;
  final bool hasMain;
  final bool hasDrink;
  final void Function(PracticeGoods item) onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B6943), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Поднос',
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: const Color(0xFF1B6943),
                  ),
                ),
              ),
              _check('Блюдо', hasMain),
              const SizedBox(width: 8),
              _check('Напиток', hasDrink),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 70,
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'Нажми на продукт — он появится здесь',
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: const Color(0xFF4A4643),
                      ),
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return GestureDetector(
                        onTap: () => onRemove(item),
                        child: Column(
                          children: [
                            Expanded(
                              child: item.imageAsset != null
                                  ? Image.asset(item.imageAsset!,
                                      fit: BoxFit.contain)
                                  : Icon(item.icon, size: 36),
                            ),
                            Text(
                              item.title,
                              style: AppFonts.rubik(
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                color: const Color(0xFF1B6943),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Потрачено $spent',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFF5B4300),
                ),
              ),
              const Spacer(),
              Text(
                'Осталось $left',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: const Color(0xFF1B6943),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _check(String label, bool ok) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          ok ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: ok ? const Color(0xFF4B946A) : const Color(0xFF4A4643),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppFonts.rubik(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: const Color(0xFF1B6943),
          ),
        ),
      ],
    );
  }
}

class _LunchShelfCard extends StatelessWidget {
  const _LunchShelfCard({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final PracticeGoods item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFDCEFE3) : const Color(0xFFFFF8E8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFF4B946A)
                  : const Color(0xFF1B6943),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: item.imageAsset != null
                    ? Image.asset(item.imageAsset!, fit: BoxFit.contain)
                    : Icon(item.icon, size: 40, color: const Color(0xFF1B6943)),
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: const Color(0xFF1B6943),
                ),
              ),
              Text(
                '${item.price}',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: const Color(0xFFDF9548),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── План на день ────────────────────────────────────────────

class DayPlanPracticePage extends StatefulWidget {
  const DayPlanPracticePage({
    super.key,
    required this.controller,
    required this.onDone,
  });
  final GameController controller;
  final VoidCallback onDone;
  @override
  State<DayPlanPracticePage> createState() => _DayPlanPracticePageState();
}

class _DayPlanPracticePageState extends State<DayPlanPracticePage> {
  late int _need;
  int _want = 20;
  int _save = 20;
  String? _hint;
  String? _result;

  int get _budget => PracticeContent.planBudgetFor(widget.controller.profile.periodIndex);
  int get _minimumNeed => PracticeContent.planNeedMinFor(widget.controller.profile.periodIndex);

  @override
  void initState() {
    super.initState();
    _need = _minimumNeed;
  }

  int get _sum => _need + _want + _save;
  int get _left => _budget - _sum;

  void _clamp() {
    if (_need < _minimumNeed) {
      _need = _minimumNeed;
    }
    while (_sum > _budget && _want > 0) {
      _want--;
    }
    while (_sum > _budget && _save > 0) {
      _save--;
    }
  }

  Future<void> _finish() async {
    if (_need < _minimumNeed) {
      setState(() =>
          _hint = 'На нужное минимум $_minimumNeed.');
      return;
    }
    if (_sum > _budget) {
      setState(() => _hint = 'Сумма плана больше $_budget.');
      return;
    }
    await widget.controller.markParkExerciseDone(PracticeCatalog.dayPlan);
    if (!mounted) return;
    setState(() {
      _result =
          'План: нужное $_need, желания $_want, копилка $_save. '
          'Не распределено $_left (можно оставить). '
          'Основной баланс не списан — это только учебный план.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) {
      return PracticeShell(
        title: 'План на день',
        subtitle: 'Учебные монеты · баланс приложения не меняется',
        onExit: widget.onDone,
        child: PracticeResultPane(
          message: _result!,
          onRetry: () => setState(() {
            _need = _minimumNeed;
            _want = 20;
            _save = 20;
            _result = null;
          }),
          onExit: widget.onDone,
        ),
      );
    }
    return PracticeShell(
      title: 'План на день',
      subtitle: 'Всего $_budget · распределено $_sum · свободно $_left',
      onExit: widget.onDone,
      bottom: practicePrimaryBtn('Подтвердить план', _finish),
      child: ListView(
        children: [
          FinzoMoodBanner(
            text: _hint ??
                'Finzo: на нужное не меньше $_minimumNeed. Остаток можно не тратить.',
            happy: _hint == null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PlanBucket(
                  label: 'Нужное',
                  value: _need,
                  asset: AppAssets.houseInventory[0],
                  onMinus: () => setState(() {
                    _need = (_need - 5)
                        .clamp(_minimumNeed, _budget);
                    _hint = null;
                  }),
                  onPlus: () => setState(() {
                    _need = (_need + 5).clamp(0, _budget);
                    _clamp();
                    _hint = null;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PlanBucket(
                  label: 'Желания',
                  value: _want,
                  asset: AppAssets.houseInventory[4],
                  onMinus: () => setState(() {
                    _want = (_want - 5).clamp(0, _budget);
                    _hint = null;
                  }),
                  onPlus: () => setState(() {
                    _want = (_want + 5).clamp(0, _budget);
                    _clamp();
                    _hint = null;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PlanBucket(
                  label: 'Копилка',
                  value: _save,
                  asset: AppAssets.goalBicycle,
                  onMinus: () => setState(() {
                    _save = (_save - 5).clamp(0, _budget);
                    _hint = null;
                  }),
                  onPlus: () => setState(() {
                    _save = (_save + 5).clamp(0, _budget);
                    _clamp();
                    _hint = null;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Свободно: $_left монет',
            textAlign: TextAlign.center,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: const Color(0xFF1B6943),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanBucket extends StatelessWidget {
  const _PlanBucket({
    required this.label,
    required this.value,
    required this.asset,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final int value;
  final String asset;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1B6943)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: Image.asset(asset, fit: BoxFit.contain),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: const Color(0xFF1B6943),
            ),
          ),
          Text(
            '$value',
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: const Color(0xFFDF9548),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onMinus,
                icon: const Icon(Icons.remove_circle_outline, size: 22),
                color: const Color(0xFF1B6943),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onPlus,
                icon: const Icon(Icons.add_circle_outline, size: 22),
                color: const Color(0xFF1B6943),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Копим на мечту ──────────────────────────────────────────

class DreamSavePracticePage extends StatefulWidget {
  const DreamSavePracticePage({
    super.key,
    required this.controller,
    required this.onDone,
  });
  final GameController controller;
  final VoidCallback onDone;
  @override
  State<DreamSavePracticePage> createState() => _DreamSavePracticePageState();
}

class _DreamSavePracticePageState extends State<DreamSavePracticePage> {
  int _day = 1;
  int _saved = 0;
  int _pocket = 0;
  int _put = 20;
  String? _hint;
  String? _result;

  int get _period => widget.controller.profile.periodIndex;
  int get _income => PracticeContent.dreamIncomeFor(_period);
  int get _need => PracticeContent.dreamNeedFor(_period);
  int get _goal => PracticeContent.dreamGoalFor(_period);
  int get _days => PracticeContent.dreamDaysFor(_period);
  int get _free => _income - _need;
  int get _toGoal => (_goal - _saved).clamp(0, _goal);

  void _startDay() {
    _put = (_free / 2).round();
    _hint = null;
  }

  @override
  void initState() {
    super.initState();
    _startDay();
  }

  Future<void> _confirmDay() async {
    if (_put < 0 || _put > _free) {
      setState(() => _hint = 'Отложить можно от 0 до $_free (после нужного $_need).');
      return;
    }
    final nextSaved = _saved + _put;
    final nextPocket = _pocket + (_free - _put);
    setState(() {
      _saved = nextSaved;
      _pocket = nextPocket;
    });
    if (_day >= _days) {
      await widget.controller.markParkExerciseDone(PracticeCatalog.dreamSave);
      if (!mounted) return;
      setState(() {
        _result =
            'За $_days дня: в копилке $_saved из $_goal '
            '(до цели $_toGoal), свободно на руках $_pocket. '
            '${_saved >= PracticeContent.dreamGoal ? 'Цель достигнута!' : 'Можно продолжить копить без обнуления.'}';
      });
      return;
    }
    setState(() {
      _day++;
      _startDay();
      _hint =
          'Finzo: накоплено $_saved, на руках $_pocket. День $_day — снова доход $_income.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) {
      return PracticeShell(
        title: 'Копим на мечту',
        subtitle: 'Учебные монеты',
        onExit: widget.onDone,
        child: PracticeResultPane(
          message: _result!,
          onRetry: () => setState(() {
            _day = 1;
            _saved = 0;
            _pocket = 0;
            _result = null;
            _startDay();
          }),
          onExit: widget.onDone,
        ),
      );
    }
    return PracticeShell(
      title: 'Копим на мечту',
      subtitle:
          'День $_day / $_days · копилка $_saved / $_goal · руки $_pocket',
      onExit: widget.onDone,
      bottom: practicePrimaryBtn('Отложить $_put', _confirmDay),
      child: ListView(
        children: [
          FinzoMoodBanner(
            text: _hint ??
                'Доход $_income, нужное $_need. Свободно $_free — реши, сколько в копилку.',
            happy: _hint == null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 72,
                      child: Image.asset(
                        widget.controller.profile.goalImageAsset.isNotEmpty
                            ? widget.controller.profile.goalImageAsset
                            : AppAssets.goalBicycle,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text('Мечта', style: practiceHead),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 72,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1B6943)),
                      ),
                      child: FractionallySizedBox(
                        heightFactor:
                            (_saved / _goal).clamp(0.08, 1),
                        widthFactor: 1,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4B946A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Text('Копилка $_saved', style: practiceHead),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('До цели: $_toGoal', style: practiceHead),
          const SizedBox(height: 12),
          PracticeAllocateRow(
            label: 'В копилку сегодня',
            value: _put,
            onMinus: () => setState(() {
              _put = (_put - 5).clamp(0, _free);
              _hint = null;
            }),
            onPlus: () => setState(() {
              _put = (_put + 5).clamp(0, _free);
              _hint = null;
            }),
          ),
          Text('Останется на руках сегодня: ${_free - _put}', style: practiceBody),
        ],
      ),
    );
  }
}

// ─── Изменились планы ────────────────────────────────────────

class PlanChangePracticePage extends StatefulWidget {
  const PlanChangePracticePage({
    super.key,
    required this.controller,
    required this.onDone,
  });
  final GameController controller;
  final VoidCallback onDone;
  @override
  State<PlanChangePracticePage> createState() => _PlanChangePracticePageState();
}

class _PlanChangePracticePageState extends State<PlanChangePracticePage> {
  late int _fromPocket;
  late int _fromSave;
  String? _hint;
  String? _result;

  int get _period => widget.controller.profile.periodIndex;
  int get _need => PracticeContent.changeNeedCostFor(_period);
  int get _free => PracticeContent.changeFreeFor(_period);
  int get _saved => PracticeContent.changeSavedFor(_period);
  int get _goalLeft => PracticeContent.changeGoalLeftFor(_period);
  int get _totalTake => _fromPocket + _fromSave;
  int get _pocketLeft => _free - _fromPocket;
  int get _saveLeft => _saved - _fromSave;
  int get _goalAfter =>
      _goalLeft + _fromSave; // снятие отодвигает цель

  @override
  void initState() {
    super.initState();
    _fromPocket = _free.clamp(0, _need);
    _fromSave = (_need - _fromPocket).clamp(0, _saved);
  }

  Future<void> _confirm() async {
    if (_totalTake != _need) {
      setState(() => _hint =
          'Нужно набрать ровно $_need. Сейчас $_totalTake — поправь до подтверждения.');
      return;
    }
    if (_fromPocket > _free || _fromSave > _saved) {
      setState(() => _hint = 'Нельзя снять больше, чем есть.');
      return;
    }
    await widget.controller.markParkExerciseDone(PracticeCatalog.planChange);
    if (!mounted) return;
    setState(() {
      _result =
          'Нужная трата $_need: с рук $_fromPocket (осталось $_pocketLeft), '
          'из копилки $_fromSave (осталось $_saveLeft). '
          'До цели стало $_goalAfter вместо $_goalLeft. '
          'Снятие на необходимое — разумный выбор, не ошибка.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) {
      return PracticeShell(
        title: 'Изменились планы',
        subtitle: 'Учебные монеты',
        onExit: widget.onDone,
        child: PracticeResultPane(
          message: _result!,
          onRetry: () => setState(() {
            _fromPocket = _free.clamp(0, _need);
            _fromSave = (_need - _fromPocket).clamp(0, _saved);
            _result = null;
            _hint = null;
          }),
          onExit: widget.onDone,
        ),
      );
    }
    return PracticeShell(
      title: 'Изменились планы',
      subtitle: 'Нужно $_need · набрано $_totalTake · до цели после: $_goalAfter',
      onExit: widget.onDone,
      bottom: practicePrimaryBtn('Подтвердить', _confirm),
      child: ListView(
        children: [
          FinzoMoodBanner(
            text: _hint ??
                'Появилась нужная трата $_need. Свободно $_free, в копилке $_saved.',
            happy: _hint == null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ChangePill(
                  title: 'Свободно',
                  value: _pocketLeft,
                  subtitle: 'было $_free',
                  asset: AppAssets.rubleMark,
                  isSvg: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChangePill(
                  title: 'Покупка',
                  value: _need,
                  subtitle: 'нужно сейчас',
                  asset: AppAssets.houseInventory[3],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChangePill(
                  title: 'Копилка',
                  value: _saveLeft,
                  subtitle: 'после: цель $_goalAfter',
                  asset: AppAssets.goalBicycle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PracticeAllocateRow(
            label: 'Взять с рук',
            value: _fromPocket,
            onMinus: () => setState(() {
              _fromPocket = (_fromPocket - 5).clamp(0, _free);
              _hint = null;
            }),
            onPlus: () => setState(() {
              _fromPocket = (_fromPocket + 5).clamp(0, _free);
              _hint = null;
            }),
          ),
          PracticeAllocateRow(
            label: 'Снять из копилки',
            value: _fromSave,
            onMinus: () => setState(() {
              _fromSave = (_fromSave - 5).clamp(0, _saved);
              _hint = null;
            }),
            onPlus: () => setState(() {
              _fromSave = (_fromSave + 5).clamp(0, _saved);
              _hint = null;
            }),
          ),
        ],
      ),
    );
  }
}

class _ChangePill extends StatelessWidget {
  const _ChangePill({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.asset,
    this.isSvg = false,
  });

  final String title;
  final int value;
  final String subtitle;
  final String asset;
  final bool isSvg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1B6943)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: isSvg
                ? SvgPicture.asset(asset, fit: BoxFit.contain)
                : Image.asset(asset, fit: BoxFit.contain),
          ),
          Text(title, style: practiceHead),
          Text(
            '$value',
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: const Color(0xFFDF9548),
            ),
          ),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppFonts.rubik(fontSize: 10, color: const Color(0xFF4A4643)),
          ),
        ],
      ),
    );
  }
}

// ─── Выгодная покупка ────────────────────────────────────────

class DealPracticePage extends StatefulWidget {
  const DealPracticePage({
    super.key,
    required this.controller,
    required this.onDone,
  });
  final GameController controller;
  final VoidCallback onDone;
  @override
  State<DealPracticePage> createState() => _DealPracticePageState();
}

class _DealPracticePageState extends State<DealPracticePage> {
  final _bag = <String>{};
  String? _hint;
  String? _result;
  int _seed = 0;

  int get _budget =>
      PracticeContent.dealBudgetFor(widget.controller.profile.periodIndex);

  List<PracticeGoods> get _shopA => PracticeContent.dealShopA;

  List<PracticeGoods> get _shopB {
    if (_seed.isOdd) {
      return const [
        PracticeGoods(
          id: 'balls3',
          title: '3 мяча',
          price: 40,
          icon: Icons.sports_baseball,
          tag: 'мяч 3',
          group: 'ball',
        ),
        PracticeGoods(
          id: 'full',
          title: 'Набор ракетка+2 мяча',
          price: 80,
          icon: Icons.card_giftcard,
          tag: 'ракетка 1 · мяч 2',
          group: 'mix',
        ),
      ];
    }
    return PracticeContent.dealShopB;
  }

  List<PracticeGoods> get _all => [..._shopA, ..._shopB];

  int _racketsOf(PracticeGoods g) {
    if (g.id == 'racket' || g.id == 'pack2' || g.id == 'full') return 1;
    return 0;
  }

  int _ballsOf(PracticeGoods g) {
    return switch (g.id) {
      'ball' => 1,
      'pack2' => 1,
      'balls3' => 3,
      'full' => 2,
      _ => 0,
    };
  }

  int get _spent =>
      _all.where((g) => _bag.contains(g.id)).fold(0, (s, g) => s + g.price);
  int get _rackets =>
      _all.where((g) => _bag.contains(g.id)).fold(0, (s, g) => s + _racketsOf(g));
  int get _balls =>
      _all.where((g) => _bag.contains(g.id)).fold(0, (s, g) => s + _ballsOf(g));

  int get _separateRef => 55 + 15 * PracticeContent.dealNeedBalls;

  void _toggle(PracticeGoods g) {
    setState(() {
      if (_bag.contains(g.id)) {
        _bag.remove(g.id);
      } else {
        if (_spent + g.price > _budget) {
          _hint = 'Не влезает в $_budget.';
          return;
        }
        _bag.add(g.id);
      }
      _hint = null;
    });
  }

  Future<void> _finish() async {
    if (_rackets < PracticeContent.dealNeedRacket ||
        _balls < PracticeContent.dealNeedBalls) {
      setState(() => _hint =
          'Нужны ракетка и ${PracticeContent.dealNeedBalls} мяча. Сейчас: $_rackets / $_balls.');
      return;
    }
    if (_spent > _budget) {
      setState(() => _hint = 'Сверх бюджета.');
      return;
    }
    await widget.controller.markParkExerciseDone(PracticeCatalog.deal);
    if (!mounted) return;
    final diff = _separateRef - _spent;
    setState(() {
      _result =
          'Комплект за $_spent (поштучно ориентир ~$_separateRef'
          '${diff > 0 ? ', выгода $diff' : diff < 0 ? ', дороже на ${-diff}' : ''}). '
          'Ракетка $_rackets, мячи $_balls. Единственного «правильного» магазина нет — важны числа.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) {
      return PracticeShell(
        title: 'Выгодная покупка',
        subtitle: 'Учебные монеты',
        onExit: widget.onDone,
        child: PracticeResultPane(
          message: _result!,
          onRetry: () => setState(() {
            _seed++;
            _bag.clear();
            _result = null;
          }),
          onExit: widget.onDone,
        ),
      );
    }
    return PracticeShell(
      title: 'Выгодная покупка',
      subtitle: 'Бюджет $_budget · сумка $_spent · ракетка $_rackets · мячи $_balls',
      onExit: widget.onDone,
      bottom: practicePrimaryBtn('Сравнить итог', _finish),
      child: ListView(
        children: [
          FinzoMoodBanner(
            text: _hint ??
                'Finzo: собери 1 ракетку и 2 мяча. Сравни магазины А и Б.',
            happy: _hint == null,
          ),
          const SizedBox(height: 8),
          Text('Магазин А', style: practiceHead),
          for (final g in _shopA)
            PracticeSelectTile(
              title: g.title,
              subtitle: '${g.price} · ${g.tag}',
              selected: _bag.contains(g.id),
              onTap: () => _toggle(g),
            ),
          Text('Магазин Б', style: practiceHead),
          for (final g in _shopB)
            PracticeSelectTile(
              title: g.title,
              subtitle: '${g.price} · ${g.tag}',
              selected: _bag.contains(g.id),
              onTap: () => _toggle(g),
            ),
        ],
      ),
    );
  }
}

// ─── Проверь чек ─────────────────────────────────────────────

class ReceiptPracticePage extends StatefulWidget {
  const ReceiptPracticePage({
    super.key,
    required this.controller,
    required this.onDone,
  });
  final GameController controller;
  final VoidCallback onDone;
  @override
  State<ReceiptPracticePage> createState() => _ReceiptPracticePageState();
}

class _ReceiptPracticePageState extends State<ReceiptPracticePage> {
  int _step = 0; // 0 gear, 1 receipt, 2 pay
  final _gear = <String>{};
  String? _flagged;
  final _paidCoins = <int>[];
  bool _alt = false;
  int? _pendingCoin;
  String? _hint;
  String? _result;
  int _seed = 0;

  int get _budget =>
      PracticeContent.receiptBudgetFor(widget.controller.profile.periodIndex);

  int get _honest => PracticeContent.receiptGear
      .where((g) => _gear.contains(g.id))
      .fold(0, (s, g) => s + g.price);
  int get _paid => _paidCoins.fold(0, (a, b) => a + b);

  List<(String, String, int)> get _lines {
    final gear = PracticeContent.receiptGear.toList();
    if (_seed.isOdd) gear.insert(0, gear.removeLast());
    final lines = <(String, String, int)>[];
    for (final g in gear) {
      if (_gear.contains(g.id)) lines.add((g.id, g.title, g.price));
    }
    lines.add((
      PracticeContent.sneakyId,
      PracticeContent.sneakyTitle,
      PracticeContent.sneakyPrice,
    ));
    return lines;
  }

  Future<void> _finish() async {
    await widget.controller.markParkExerciseDone(PracticeCatalog.receipt);
    if (!mounted) return;
    setState(() {
      _result =
          'Чек очищен, оплата $_honest точная. '
          'Осталось учебных ${_budget - _honest}. '
          'Основной баланс не менялся.';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) {
      return PracticeShell(
        title: 'Проверь чек',
        subtitle: 'Учебные монеты',
        onExit: widget.onDone,
        child: PracticeResultPane(
          message: _result!,
          onRetry: () => setState(() {
            _seed++;
            _step = 0;
            _gear.clear();
            _flagged = null;
            _paidCoins.clear();
            _result = null;
          }),
          onExit: widget.onDone,
        ),
      );
    }
    return PracticeShell(
      title: 'Проверь чек',
      subtitle: switch (_step) {
        0 => 'Снасти · бюджет $_budget',
        1 => 'Найди лишнее в чеке',
        _ => 'Оплата $_paid / $_honest',
      },
      onExit: widget.onDone,
      bottom: practicePrimaryBtn(
        switch (_step) {
          0 => 'К чеку',
          1 => 'К оплате',
          _ => 'Оплатить',
        },
        () async {
          if (_step == 0) {
            final need = PracticeContent.receiptGear
                .where((g) => g.required)
                .every((g) => _gear.contains(g.id));
            if (!need) {
              setState(() => _hint = 'Возьми все нужные позиции.');
              return;
            }
            if (_honest > _budget) {
              setState(() => _hint = 'Дороже бюджета — убери желание.');
              return;
            }
            setState(() {
              _step = 1;
              _hint = null;
            });
          } else if (_step == 1) {
            if (_flagged != PracticeContent.sneakyId) {
              setState(() => _hint = 'Отметь строку, которую не выбирал.');
              return;
            }
            setState(() {
              _step = 2;
              _paidCoins.clear();
              _hint = null;
            });
          } else {
            if (_paid != _honest) {
              setState(() =>
                  _hint = 'Нужно ровно $_honest. Сейчас $_paid — исправь.');
              return;
            }
            await _finish();
          }
        },
      ),
      child: switch (_step) {
        0 => Column(
            children: [
              FinzoMoodBanner(
                text: _hint ?? 'Finzo: собери нужное. Желание — по желанию.',
                happy: _hint == null,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    for (final g in PracticeContent.receiptGear)
                      PracticeSelectTile(
                        title: g.title,
                        subtitle:
                            '${g.price} · ${g.required ? 'нужно' : 'желание'}',
                        selected: _gear.contains(g.id),
                        onTap: () => setState(() {
                          if (_gear.contains(g.id)) {
                            _gear.remove(g.id);
                          } else {
                            _gear.add(g.id);
                          }
                          _hint = null;
                        }),
                      ),
                  ],
                ),
              ),
            ],
          ),
        1 => ListView(
            children: [
              FinzoMoodBanner(
                text: _hint ?? 'Нажми лишнюю строку.',
                happy: _hint == null,
              ),
              const SizedBox(height: 8),
              for (final line in _lines)
                PracticeSelectTile(
                  title: line.$2,
                  subtitle: '${line.$3}',
                  selected: _flagged == line.$1,
                  onTap: () => setState(() {
                    _flagged = line.$1;
                    _hint = null;
                  }),
                ),
            ],
          ),
        _ => Column(
            children: [
              FinzoMoodBanner(
                text: _hint ?? 'Перетащи монеты на кассу или тапни.',
                happy: _hint == null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: FilterChip(
                  label: Text(_alt ? 'Выбрать→касса' : 'Тап/drag'),
                  selected: _alt,
                  onSelected: (v) => setState(() {
                    _alt = v;
                    _pendingCoin = null;
                  }),
                ),
              ),
              Expanded(
                child: PracticePayPad(
                  target: _honest,
                  paid: _paid,
                  altMode: _alt,
                  pending: _pendingCoin,
                  onPending: (v) => setState(() => _pendingCoin = v),
                  onAdd: (v) => setState(() {
                    _paidCoins.add(v);
                    _pendingCoin = null;
                    _hint = null;
                  }),
                  onReset: () => setState(() {
                    _paidCoins.clear();
                    _hint = 'Оплату сбросили.';
                  }),
                ),
              ),
            ],
          ),
      },
    );
  }
}
