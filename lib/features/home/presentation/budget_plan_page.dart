import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/budget_plan.dart';
import '../../../core/profile/economy.dart';
import '../../../core/profile/game_controller.dart';
import '../../../core/profile/house_catalog.dart';
import '../../../core/theme/app_fonts.dart';

/// Пошаговый план бюджета: нужное → желания → копилка.
class BudgetPlanPage extends StatefulWidget {
  const BudgetPlanPage({
    super.key,
    required this.controller,
    required this.onConfirmed,
    this.onBack,
  });

  final GameController controller;
  final VoidCallback onConfirmed;
  final VoidCallback? onBack;

  @override
  State<BudgetPlanPage> createState() => _BudgetPlanPageState();
}

enum _BudgetStep { intro, necessary, wants, savings, summary }

class _BudgetPlanPageState extends State<BudgetPlanPage> {
  _BudgetStep _step = _BudgetStep.intro;
  int _necessary = 0;
  int _wants = 0;
  int _savings = 0;
  final _customCtrl = TextEditingController();

  int get _total => widget.controller.profile.distributableBudget;
  int get _allocated => _necessary + _wants + _savings;
  int get _left => (_total - _allocated).clamp(0, _total);

  @override
  void initState() {
    super.initState();
    final existing = widget.controller.profile.plan;
    if (existing != null) {
      _necessary = existing.necessary.clamp(0, _total);
      _wants = existing.wants.clamp(0, _total);
      _savings = existing.savings.clamp(0, _total);
      // Не даём сумме превысить бюджет при возврате к старому плану.
      while (_allocated > _total && _savings > 0) {
        _savings--;
      }
      while (_allocated > _total && _wants > 0) {
        _wants--;
      }
      while (_allocated > _total && _necessary > 0) {
        _necessary--;
      }
    }
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _go(_BudgetStep next) => setState(() {
        _customCtrl.clear();
        _step = next;
      });

  void _setNecessary(int v) {
    final max = _total - _wants - _savings;
    setState(() => _necessary = v.clamp(0, max < 0 ? 0 : max));
  }

  void _setWants(int v) {
    final max = _total - _necessary - _savings;
    setState(() => _wants = v.clamp(0, max < 0 ? 0 : max));
  }

  void _setSavings(int v) {
    final max = _total - _necessary - _wants;
    setState(() => _savings = v.clamp(0, max < 0 ? 0 : max));
  }

  Future<void> _confirm() async {
    final ok = await widget.controller.confirmBudgetPlan(
      BudgetPlan(necessary: _necessary, wants: _wants, savings: _savings),
    );
    if (ok) widget.onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.controller.profile;
    final day = p.periodIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (_step == _BudgetStep.intro) {
                        widget.onBack?.call();
                      } else if (_step == _BudgetStep.necessary) {
                        _go(_BudgetStep.intro);
                      } else if (_step == _BudgetStep.wants) {
                        _go(_BudgetStep.necessary);
                      } else if (_step == _BudgetStep.savings) {
                        _go(_BudgetStep.wants);
                      } else {
                        _go(_BudgetStep.savings);
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: const Color(0xFF1B6943),
                  ),
                  Expanded(
                    child: Text(
                      'План на день',
                      textAlign: TextAlign.center,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: const Color(0xFF1B6943),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Text(
                'День с Finzo · $day',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: const Color(0xFF5B4300),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: switch (_step) {
                  _BudgetStep.intro => _IntroStep(
                      carryover: p.carryoverAvailable,
                      today: p.todayIncome > 0
                          ? p.todayIncome
                          : EconomyRules.periodIncome,
                      total: _total,
                      onNext: () => _go(_BudgetStep.necessary),
                    ),
                  _BudgetStep.necessary => _NecessaryStep(
                      left: _left + _necessary,
                      selected: _necessary,
                      controller: widget.controller,
                      onSelect: _setNecessary,
                      onNext: () => _go(_BudgetStep.wants),
                    ),
                  _BudgetStep.wants => _WantsStep(
                      left: _left + _wants,
                      selected: _wants,
                      onSelect: _setWants,
                      onNext: () => _go(_BudgetStep.savings),
                    ),
                  _BudgetStep.savings => _SavingsStep(
                      left: _left + _savings,
                      selected: _savings,
                      goalTitle: p.goalTitle.isEmpty ? 'цель' : p.goalTitle,
                      goalPrice: p.goalPrice,
                      saved: p.savedBalance,
                      customCtrl: _customCtrl,
                      onSelect: _setSavings,
                      onNext: () => _go(_BudgetStep.summary),
                    ),
                  _BudgetStep.summary => _SummaryStep(
                      necessary: _necessary,
                      wants: _wants,
                      savings: _savings,
                      free: _left,
                      onConfirm: _confirm,
                    ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({
    required this.carryover,
    required this.today,
    required this.total,
    required this.onNext,
  });

  final int carryover;
  final int today;
  final int total;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(label: 'Осталось со вчера', value: '$carryover ₽'),
        const SizedBox(height: 8),
        _InfoCard(label: 'Получено сегодня', value: '$today ₽'),
        const SizedBox(height: 8),
        _InfoCard(
          label: 'Всего можно распределить',
          value: '$total ₽',
          emphasize: true,
        ),
        const SizedBox(height: 10),
        Text(
          'Накопления в копилку сюда не входят.',
          textAlign: TextAlign.center,
          style: AppFonts.rubik(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: const Color(0xFF5B4300),
          ),
        ),
        const Spacer(),
        _GreenBtn(label: 'Дальше', onTap: onNext),
      ],
    );
  }
}

class _NecessaryStep extends StatelessWidget {
  const _NecessaryStep({
    required this.left,
    required this.selected,
    required this.controller,
    required this.onSelect,
    required this.onNext,
  });

  final int left;
  final int selected;
  final GameController controller;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final p = controller.profile;
    final suggestions = <(String, int, String)>[];
    for (var i = 0; i < ShopCatalog.kitchenTitles.length && i < 4; i++) {
      final item = ShopCatalog.item(HouseItemCategory.kitchen, i);
      final qty = p.inventoryQty(item.key);
      suggestions.add((
        item.title,
        item.price,
        qty > 0 ? 'В запасе ${qty}x' : 'Нужно купить',
      ));
    }
    for (var i = 0; i < 2 && i < ShopCatalog.showerTitles.length; i++) {
      final item = ShopCatalog.item(HouseItemCategory.shower, i);
      final qty = p.inventoryQty(item.key);
      suggestions.add((
        item.title,
        item.price,
        qty > 0 ? 'В запасе ${qty}x' : 'Нужно купить',
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Что нужно Finzo сегодня?',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: const Color(0xFF1B6943),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Выбери, на сколько оставить денег. Это ещё не покупка.',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: const Color(0xFF4A4643),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ещё не распределено: $left ₽',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: const Color(0xFF5B4300),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: [
              for (final s in suggestions)
                _ChoiceTile(
                  title: s.$1,
                  subtitle: '${s.$2} ₽ · ${s.$3}',
                  selected: selected == s.$2,
                  onTap: () => onSelect(s.$2 <= left ? s.$2 : left),
                ),
              _ChoiceTile(
                title: 'Пока ничего не оставляю',
                subtitle: '0 ₽ — можно решить позже',
                selected: selected == 0,
                onTap: () => onSelect(0),
              ),
              const SizedBox(height: 8),
              _ChipRow(
                amounts: [50, 100, 150, 200]
                    .where((a) => a <= left || a == selected)
                    .toList(),
                selected: selected,
                onSelect: (a) => onSelect(a > left ? left : a),
              ),
            ],
          ),
        ),
        _GreenBtn(label: 'Дальше', onTap: onNext),
      ],
    );
  }
}

class _WantsStep extends StatelessWidget {
  const _WantsStep({
    required this.left,
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  final int left;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final examples = <(String, int)>[];
    for (var i = 0; i < 4 && i < ShopCatalog.clothesTitles.length; i++) {
      final item = ShopCatalog.item(HouseItemCategory.clothes, i);
      examples.add((item.title, item.price));
    }
    // Мороженое / торт как желания из кухни.
    examples.add((
      ShopCatalog.kitchenTitles[4],
      ShopCatalog.kitchenPrices[4],
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Сколько оставим на желания?',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: const Color(0xFF1B6943),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Это необязательные покупки. Можно выбрать ноль.',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: const Color(0xFF4A4643),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ещё не распределено: $left ₽',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: const Color(0xFF5B4300),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            children: [
              for (final e in examples)
                _ChoiceTile(
                  title: e.$1,
                  subtitle: '${e.$2} ₽',
                  selected: selected == e.$2,
                  onTap: () => onSelect(e.$2 <= left ? e.$2 : left),
                ),
              _ChoiceTile(
                title: 'Без желаний сегодня',
                subtitle: '0 ₽',
                selected: selected == 0,
                onTap: () => onSelect(0),
              ),
              const SizedBox(height: 8),
              _ChipRow(
                amounts: [0, 40, 80, 120]
                    .where((a) => a == 0 || a <= left || a == selected)
                    .toList(),
                selected: selected,
                onSelect: (a) => onSelect(a > left ? left : a),
              ),
            ],
          ),
        ),
        _GreenBtn(label: 'Дальше', onTap: onNext),
      ],
    );
  }
}

class _SavingsStep extends StatelessWidget {
  const _SavingsStep({
    required this.left,
    required this.selected,
    required this.goalTitle,
    required this.goalPrice,
    required this.saved,
    required this.customCtrl,
    required this.onSelect,
    required this.onNext,
  });

  final int left;
  final int selected;
  final String goalTitle;
  final int goalPrice;
  final int saved;
  final TextEditingController customCtrl;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Сколько хочешь отложить на $goalTitle?',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: const Color(0xFF1B6943),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Цель $goalPrice ₽ · уже в копилке $saved ₽',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: const Color(0xFF4A4643),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ещё не распределено: $left ₽',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: const Color(0xFF5B4300),
          ),
        ),
        const SizedBox(height: 12),
        _ChipRow(
          amounts: [0, 20, 50, 100, 150]
              .where((a) => a == 0 || a <= left || a == selected)
              .toList(),
          selected: selected,
          onSelect: (a) {
            customCtrl.clear();
            onSelect(a > left ? left : a);
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: customCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Своя сумма ₽',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (t) {
            final v = int.tryParse(t) ?? 0;
            onSelect(v > left ? left : v);
          },
        ),
        const Spacer(),
        _GreenBtn(label: 'Дальше', onTap: onNext),
      ],
    );
  }
}

class _SummaryStep extends StatelessWidget {
  const _SummaryStep({
    required this.necessary,
    required this.wants,
    required this.savings,
    required this.free,
    required this.onConfirm,
  });

  final int necessary;
  final int wants;
  final int savings;
  final int free;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InfoCard(label: 'На необходимое', value: '$necessary ₽'),
        const SizedBox(height: 8),
        _InfoCard(label: 'На желания', value: '$wants ₽'),
        const SizedBox(height: 8),
        _InfoCard(label: 'В копилку (план)', value: '$savings ₽'),
        const SizedBox(height: 8),
        _InfoCard(label: 'Свободный остаток', value: '$free ₽', emphasize: true),
        const SizedBox(height: 14),
        Text(
          'Это твой план. Покупки и перевод в копилку сделаем отдельно.',
          textAlign: TextAlign.center,
          style: AppFonts.rubik(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            height: 1.35,
            color: const Color(0xFF4A4643),
          ),
        ),
        const Spacer(),
        _GreenBtn(label: 'Сохранить план и играть', onTap: onConfirm),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: emphasize
              ? const Color(0xFF1B6943)
              : const Color(0xFF1B6943).withValues(alpha: 0.4),
          width: emphasize ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          if (emphasize) ...[
            SvgPicture.asset(AppAssets.streetLogo, width: 28, height: 32),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              label,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: const Color(0xFF4A4643),
              ),
            ),
          ),
          Text(
            value,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: emphasize ? 18 : 16,
              color: const Color(0xFF1B6943),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? const Color(0xFFE8F5EC) : const Color(0xFFFEF7E6),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFF1B6943)
                    : const Color(0xFF1B6943).withValues(alpha: 0.35),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: const Color(0xFF1B6943),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: const Color(0xFF4A4643),
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle, color: Color(0xFF1B6943)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.amounts,
    required this.selected,
    required this.onSelect,
  });

  final List<int> amounts;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final a in amounts)
          ChoiceChip(
            label: Text(a == 0 ? '0 ₽' : '$a ₽'),
            selected: selected == a,
            onSelected: (_) => onSelect(a),
            selectedColor: const Color(0xFF4B946A),
            labelStyle: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              color: selected == a ? Colors.white : const Color(0xFF1B6943),
            ),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF1B6943)),
          ),
      ],
    );
  }
}

class _GreenBtn extends StatelessWidget {
  const _GreenBtn({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF4B946A),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: 52,
          child: Center(
            child: Text(
              label,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
