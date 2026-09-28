import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/budget_plan.dart';
import '../../../core/profile/economy.dart';
import '../../../core/profile/game_controller.dart';
import '../../../core/theme/app_fonts.dart';

/// Один экран плана бюджета: необходимое + желания + копилка.
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

class _BudgetPlanPageState extends State<BudgetPlanPage> {
  int _necessary = 0;
  int _wants = 0;
  int _savings = 0;

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
    final today = p.todayIncome > 0
        ? p.todayIncome
        : EconomyRules.periodIncome;
    final showCarryover = p.periodIndex > 1;

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
                    onPressed: widget.onBack,
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
              _BudgetHeader(
                showCarryover: showCarryover,
                carryover: p.carryoverAvailable,
                today: today,
                total: _total,
                left: _left,
              ),
              const SizedBox(height: 8),
              Text(
                'Разложи деньги по трём направлениям. Покупки — потом дома.',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  height: 1.3,
                  color: const Color(0xFF4A4643),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    _BucketCard(
                      title: 'Необходимое',
                      hint: 'Еда и уход для Finzo',
                      value: _necessary,
                      max: _left + _necessary,
                      color: const Color(0xFF1B6943),
                      onChanged: _setNecessary,
                    ),
                    const SizedBox(height: 10),
                    _BucketCard(
                      title: 'Желания',
                      hint: 'Одежда, игрушки и другое необязательное',
                      value: _wants,
                      max: _left + _wants,
                      color: const Color(0xFFDF9548),
                      onChanged: _setWants,
                    ),
                    const SizedBox(height: 10),
                    _BucketCard(
                      title: 'Копилка',
                      hint: p.goalTitle.isEmpty
                          ? 'Отложить на цель'
                          : 'На «${p.goalTitle}» · уже ${p.savedBalance} ₽',
                      value: _savings,
                      max: _left + _savings,
                      color: const Color(0xFF4B946A),
                      onChanged: _setSavings,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _GreenBtn(
                label: 'Сохранить план и играть',
                onTap: _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader({
    required this.showCarryover,
    required this.carryover,
    required this.today,
    required this.total,
    required this.left,
  });

  final bool showCarryover;
  final int carryover;
  final int today;
  final int total;
  final int left;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF7E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1B6943), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(AppAssets.streetLogo, width: 28, height: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Можно распределить',
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF4A4643),
                  ),
                ),
              ),
              Text(
                '$total ₽',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: const Color(0xFF1B6943),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (showCarryover)
                Expanded(
                  child: Text(
                    'Со вчера $carryover ₽',
                    style: _meta,
                  ),
                ),
              Expanded(
                child: Text(
                  showCarryover ? 'Сегодня +$today ₽' : 'На день $today ₽',
                  textAlign: showCarryover ? TextAlign.end : TextAlign.start,
                  style: _meta,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              left == 0
                  ? 'Всё разложено'
                  : 'Ещё не распределено: $left ₽',
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: const Color(0xFF5B4300),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final _meta = AppFonts.rubik(
  fontWeight: FontWeight.w500,
  fontSize: 12,
  color: const Color(0xFF5B4300),
);

class _BucketCard extends StatelessWidget {
  const _BucketCard({
    required this.title,
    required this.hint,
    required this.value,
    required this.max,
    required this.color,
    required this.onChanged,
  });

  final String title;
  final String hint;
  final int value;
  final int max;
  final Color color;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final sliderMax = max <= 0 ? 1.0 : max.toDouble();
    final sliderValue = value.clamp(0, max).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ),
              Text(
                '$value ₽',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: const Color(0xFF1B6943),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: const Color(0xFF4A4643),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.12),
              trackHeight: 6,
            ),
            child: Slider(
              min: 0,
              max: sliderMax,
              divisions: max <= 0 ? 1 : max,
              value: sliderValue,
              onChanged: max <= 0
                  ? null
                  : (v) => onChanged(v.round().clamp(0, max)),
            ),
          ),
        ],
      ),
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
