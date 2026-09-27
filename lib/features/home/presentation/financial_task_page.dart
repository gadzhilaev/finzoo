import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/financial_tasks.dart';
import '../../../core/profile/game_controller.dart';
import '../../../core/theme/app_fonts.dart';

/// Учебное задание дня: выбор → объяснение; без денежной награды.
class FinancialTaskPage extends StatefulWidget {
  const FinancialTaskPage({
    super.key,
    required this.controller,
    required this.onDone,
  });

  final GameController controller;
  final VoidCallback onDone;

  @override
  State<FinancialTaskPage> createState() => _FinancialTaskPageState();
}

class _FinancialTaskPageState extends State<FinancialTaskPage> {
  String? _selected;
  TaskAnswerResult? _result;
  bool _busy = false;

  FinancialTask get _task => widget.controller.currentTask;

  bool get _reviewOnly =>
      widget.controller.profile.periodTaskDone && _result == null;

  Future<void> _submit() async {
    final id = _selected;
    if (id == null || _busy) return;
    setState(() => _busy = true);
    final result = await widget.controller.answerPeriodTask(id);
    if (!mounted) return;
    setState(() {
      _result = result;
      _busy = false;
      if (result != null && !result.correct) {
        _selected = null;
      }
    });
  }

  void _retry() {
    setState(() {
      _result = null;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    onPressed: widget.onDone,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: const Color(0xFF1B6943),
                  ),
                  Expanded(
                    child: Text(
                      'Учимся с Finzo',
                      textAlign: TextAlign.center,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: const Color(0xFF1B6943),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Text(
                _task.title,
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: const Color(0xFF1B6943),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: SvgPicture.asset(
                  AppAssets.squirrel2,
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF7E6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF1B6943),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          _task.situation,
                          textAlign: TextAlign.center,
                          style: AppFonts.rubik(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.35,
                            color: const Color(0xFF4A4643),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_reviewOnly) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5EC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF4B946A)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Color(0xFF1B6943)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Навык изучен. Можно вернуться к игре.',
                                  style: AppFonts.rubik(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: const Color(0xFF1B6943),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _task.choices
                              .firstWhere((c) => c.isCorrect)
                              .explanation,
                          textAlign: TextAlign.center,
                          style: AppFonts.rubik(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.35,
                            color: const Color(0xFF4A4643),
                          ),
                        ),
                      ] else if (_result == null) ...[
                        for (final c in _task.choices) ...[
                          _ChoiceTile(
                            label: c.label,
                            selected: _selected == c.id,
                            onTap: () => setState(() => _selected = c.id),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ] else if (!_result!.correct) ...[
                        Text(
                          'Почти!',
                          textAlign: TextAlign.center,
                          style: AppFonts.rubik(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: const Color(0xFFDF9548),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result!.explanation,
                          textAlign: TextAlign.center,
                          style: AppFonts.rubik(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.35,
                            color: const Color(0xFF4A4643),
                          ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF4B946A), size: 28),
                            const SizedBox(width: 8),
                            Text(
                              'Разобрались!',
                              style: AppFonts.rubik(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: const Color(0xFF1B6943),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _result!.explanation,
                          textAlign: TextAlign.center,
                          style: AppFonts.rubik(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            height: 1.35,
                            color: const Color(0xFF4A4643),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_reviewOnly)
                _PrimaryBtn(label: 'К улице', onTap: widget.onDone)
              else if (_result == null)
                _PrimaryBtn(
                  label: 'Ответить',
                  onTap: _selected == null || _busy ? null : _submit,
                )
              else if (!_result!.correct)
                _PrimaryBtn(label: 'Попробовать ещё', onTap: _retry)
              else
                _PrimaryBtn(label: 'К улице', onTap: widget.onDone),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF4B946A) : const Color(0xFFFEF7E6),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1B6943), width: 1.5),
          ),
          child: Text(
            label,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              height: 1.3,
              color: selected ? Colors.white : const Color(0xFF4A4643),
            ),
          ),
        ),
      ),
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
      color: onTap == null ? const Color(0xFFA8C4B4) : const Color(0xFF4B946A),
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
