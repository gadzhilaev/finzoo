import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/profile/economy.dart';
import '../../../../core/profile/game_controller.dart';
import '../../../../core/theme/app_fonts.dart';
import '../goals_page.dart';

/// Копилка в стиле диалогов покупки: цель, чипы суммы, превью.
Future<void> showSavingsDialog(
  BuildContext context,
  GameController controller, {
  bool startWithdraw = false,
}) async {
  final result = await showDialog<SavingsMoveResult>(
    context: context,
    builder: (ctx) => SavingsDialog(
      controller: controller,
      startWithdraw: startWithdraw,
    ),
  );
  if (result == null || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (c2) => Dialog(
      backgroundColor: const Color(0xFFFEF7E6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF1B6943), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              result.ok ? 'Готово' : 'Не получилось',
              textAlign: TextAlign.center,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: const Color(0xFF1B6943),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              result.message,
              textAlign: TextAlign.center,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: const Color(0xFF4A4643),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(c2),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4B946A),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'ОК',
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showAvailableBottomSheet(
  BuildContext context,
  GameController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFEF7E6),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final p = controller.profile;
          final income = p.todayIncome > 0
              ? p.todayIncome
              : (p.periodIncomeGranted ? EconomyRules.periodIncome : 0);
          final incomeLabel = p.periodIncomeLabel.isEmpty
              ? EconomyRules.periodIncomeLabel
              : p.periodIncomeLabel;
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + MediaQuery.paddingOf(ctx).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5D0D0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Карманные деньги',
                  textAlign: TextAlign.center,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: const Color(0xFF1B6943),
                  ),
                ),
                const SizedBox(height: 14),
                _MoneyLine(
                  label: 'Осталось со вчера',
                  value: '${p.carryoverAvailable} ₽',
                ),
                const SizedBox(height: 8),
                _MoneyLine(
                  label: 'Получено сегодня',
                  value: '$income ₽',
                  hint: incomeLabel,
                ),
                const SizedBox(height: 8),
                _MoneyLine(
                  label: 'Сейчас доступно',
                  value: '${p.availableBalance} ₽',
                  emphasize: true,
                ),
                const SizedBox(height: 8),
                Text(
                  'Накопления в эту сумму не входят — они в копилке.',
                  textAlign: TextAlign.center,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: const Color(0xFF5B4300),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _MoneyLine extends StatelessWidget {
  const _MoneyLine({
    required this.label,
    required this.value,
    this.hint,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final String? hint;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: emphasize
              ? const Color(0xFF1B6943)
              : const Color(0xFF1B6943).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: const Color(0xFF5B4300),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> showSavingsBottomSheet(
  BuildContext context,
  GameController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFEF7E6),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final p = controller.profile;
      final goalImage = _goalImageAsset(p.goalImageAsset, p.goalTitle, p.goalPrice);
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          16 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD5D0D0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    goalImage,
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 56,
                      height: 56,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.goalTitle.isEmpty ? 'Цель' : p.goalTitle,
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: const Color(0xFF1B6943),
                        ),
                      ),
                      Text(
                        '${p.savedBalance} / ${p.goalPrice} ₽ · ${p.goalProgressLabel}',
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: const Color(0xFF4A4643),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: p.goalProgress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE8E0D0),
                color: const Color(0xFF4B946A),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                showSavingsDialog(context, controller);
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4B946A),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Отложить',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx);
                showSavingsDialog(context, controller, startWithdraw: true);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1B6943),
                side: const BorderSide(color: Color(0xFF1B6943), width: 1.5),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Снять',
                style: AppFonts.rubik(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class SavingsDialog extends StatefulWidget {
  const SavingsDialog({
    super.key,
    required this.controller,
    this.startWithdraw = false,
  });

  final GameController controller;
  final bool startWithdraw;

  @override
  State<SavingsDialog> createState() => _SavingsDialogState();
}

class _SavingsDialogState extends State<SavingsDialog> {
  late final TextEditingController _amountCtrl;
  late bool _withdraw;
  bool _busy = false;
  bool _confirmWithdraw = false;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController();
    _withdraw = widget.startWithdraw;
    _amountCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  int get _amount => int.tryParse(_amountCtrl.text) ?? 0;

  List<int> get _chips {
    final p = widget.controller.profile;
    if (_withdraw) {
      final s = p.savedBalance;
      return [10, 20, 50, 100].where((v) => v <= s).toList();
    }
    final a = p.availableBalance;
    return [10, 20, 50, 100].where((v) => v <= a).toList();
  }

  Future<void> _submit() async {
    if (_busy) return;
    if (_withdraw && !_confirmWithdraw) {
      setState(() => _confirmWithdraw = true);
      return;
    }
    setState(() => _busy = true);
    final result = _withdraw
        ? await widget.controller.withdrawFromSavings(_amount)
        : await widget.controller.saveTowardGoal(_amount);
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.controller.profile;
    final goalImage =
        _goalImageAsset(p.goalImageAsset, p.goalTitle, p.goalPrice);
    final amount = _amount;
    final remainAvailable = _withdraw
        ? p.availableBalance + amount
        : (p.availableBalance - amount).clamp(0, 1 << 30);
    final piggyAfter = _withdraw
        ? (p.savedBalance - amount).clamp(0, 1 << 30)
        : p.savedBalance + amount;

    return Dialog(
      backgroundColor: const Color(0xFFFEF7E6),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF1B6943), width: 2),
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _withdraw ? 'Снять из копилки' : 'В копилку',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: const Color(0xFF1B6943),
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColoredBox(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      goalImage,
                      height: 72,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox(height: 72),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                p.goalTitle.isEmpty ? 'Цель' : p.goalTitle,
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: const Color(0xFF4A4643),
                ),
              ),
              Text(
                'В копилке сейчас ${p.savedBalance} ₽',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: const Color(0xFF5B4300),
                ),
              ),
              const SizedBox(height: 12),
              if (_chips.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final c in _chips)
                      ChoiceChip(
                        label: Text('$c ₽'),
                        selected: _amountCtrl.text == '$c',
                        onSelected: (_) {
                          _amountCtrl.text = '$c';
                          setState(() => _confirmWithdraw = false);
                        },
                        selectedColor: const Color(0xFF4B946A),
                        labelStyle: AppFonts.rubik(
                          fontWeight: FontWeight.w700,
                          color: _amountCtrl.text == '$c'
                              ? Colors.white
                              : const Color(0xFF1B6943),
                        ),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF1B6943)),
                      ),
                  ],
                ),
              const SizedBox(height: 10),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Своя сумма ₽',
                  labelStyle: AppFonts.rubik(fontWeight: FontWeight.w500),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF1B6943)),
                  ),
                ),
                onChanged: (_) => setState(() => _confirmWithdraw = false),
              ),
              if (amount > 0) ...[
                const SizedBox(height: 10),
                Text(
                  _withdraw
                      ? 'Останется доступно $remainAvailable ₽\n'
                          'В копилке будет $piggyAfter ₽'
                      : 'Останется $remainAvailable ₽\n'
                          'В копилке будет $piggyAfter ₽',
                  textAlign: TextAlign.center,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    height: 1.3,
                    color: const Color(0xFF1B6943),
                  ),
                ),
              ],
              if (_withdraw && _confirmWithdraw) ...[
                const SizedBox(height: 8),
                Text(
                  'Накопления уменьшатся на $amount ₽. Цель отодвинется.',
                  textAlign: TextAlign.center,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: const Color(0xFFDF9548),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => setState(() {
                  _withdraw = !_withdraw;
                  _confirmWithdraw = false;
                  _amountCtrl.clear();
                }),
                child: Text(
                  _withdraw ? 'Хочу отложить' : 'Хочу снять',
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFFDF9548),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4B946A),
                        side: const BorderSide(
                          color: Color(0xFF4B946A),
                          width: 1.5,
                        ),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Отмена',
                        style: AppFonts.rubik(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _busy || amount <= 0 ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4B946A),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _withdraw
                            ? (_confirmWithdraw ? 'Снять' : 'Далее')
                            : 'Отложить',
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _goalImageAsset(String asset, String title, int price) {
  if (asset.isNotEmpty) return asset;
  final t = title.replaceAll('\n', ' ').trim().toLowerCase();
  for (final g in GoalsPage.goals) {
    final gt = g.title.replaceAll('\n', ' ').trim().toLowerCase();
    if (gt == t || t.contains(gt) || gt.contains(t)) return g.imageAsset;
  }
  for (final g in GoalsPage.goals) {
    final gp = int.tryParse(g.price.replaceAll(RegExp(r'[^\d]'), '')) ?? -1;
    if (gp == price) return g.imageAsset;
  }
  return AppAssets.goalBicycle;
}
