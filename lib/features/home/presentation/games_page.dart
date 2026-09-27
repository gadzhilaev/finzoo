import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/profile/game_controller.dart';
import '../../../core/theme/app_fonts.dart';
import 'practice/practice_catalog.dart';
import 'practice/practice_tasks.dart';

/// Экран «Практика с Finzo»: список из 6 финансовых заданий.
class GamesPage extends StatefulWidget {
  const GamesPage({
    super.key,
    required this.controller,
    this.onBack,
    this.autoOpenExerciseId,
    this.skipIntro = false,
    this.onAutoOpenConsumed,
  });

  final GameController controller;
  final VoidCallback? onBack;
  final String? autoOpenExerciseId;
  final bool skipIntro;
  final VoidCallback? onAutoOpenConsumed;

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  bool _autoOpened = false;
  bool _tipScheduled = false;

  @override
  void initState() {
    super.initState();
    final raw = widget.autoOpenExerciseId;
    if (raw != null && raw.isNotEmpty) {
      final item = PracticeCatalog.byId(raw);
      if (item != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _autoOpened) return;
          _autoOpened = true;
          widget.onAutoOpenConsumed?.call();
          _openTask(item);
        });
      }
    }
    if (!widget.skipIntro && !widget.controller.profile.practiceTipShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _tipScheduled) return;
        _tipScheduled = true;
        if (!widget.controller.profile.practiceTipShown) {
          _showPracticeTip(first: true);
        }
      });
    }
  }

  void _openTask(PracticeItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => buildPracticeTask(
          item: item,
          controller: widget.controller,
          onDone: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  Future<void> _showPracticeTip({required bool first}) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFEF7E6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFF1B6943), width: 2),
        ),
        title: Text(
          'Учебные монеты',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF1B6943),
          ),
        ),
        content: Text(
          'Здесь учебные монеты — твои накопления останутся на месте.',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            height: 1.3,
            color: const Color(0xFF4A4643),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Понятно',
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1B6943),
              ),
            ),
          ),
        ],
      ),
    );
    if (first) await widget.controller.markPracticeTipShown();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final done = PracticeCatalog.completedIds(
          widget.controller.profile.periodPracticeCompletedIds,
        );
        final allDone = done.length == PracticeCatalog.all.length;
        final level = PracticeCatalog.levelForPeriod(
          widget.controller.profile.periodIndex,
        );

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
                          'Практика с Finzo',
                          textAlign: TextAlign.center,
                          style: AppFonts.rubik(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                            color: const Color(0xFF1B6943),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showPracticeTip(first: false),
                        icon: const Icon(Icons.info_outline_rounded),
                        color: const Color(0xFFDF9548),
                        tooltip: 'Про учебные монеты',
                      ),
                    ],
                  ),
                  Text(
                    allDone
                        ? 'Все задания на сегодня пройдены. Завтра будет уровень $level.'
                        : 'Уровень $level · учимся обращаться с деньгами',
                    textAlign: TextAlign.center,
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: const Color(0xFF4A4643),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1B6943)),
                    ),
                    child: Text(
                      'Пройдено ${done.length} из ${PracticeCatalog.all.length}',
                      textAlign: TextAlign.center,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: const Color(0xFF1B6943),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (allDone) ...[
                    _PracticeDayCompleteCard(
                      nextLevel: PracticeCatalog.levelForPeriod(
                        widget.controller.profile.periodIndex + 1,
                      ),
                      onBack: widget.onBack,
                    ),
                    const SizedBox(height: 12),
                  ],
                  Expanded(
                    child: ListView.separated(
                      itemCount: PracticeCatalog.all.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = PracticeCatalog.all[i];
                        final ok = done.contains(item.id);
                        return _PracticeCard(
                          item: item,
                          completed: ok,
                          onTap: () => _openTask(item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PracticeDayCompleteCard extends StatelessWidget {
  const _PracticeDayCompleteCard({required this.nextLevel, this.onBack});

  final int nextLevel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B6943), width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium_rounded,
              color: Color(0xFF1B6943), size: 30),
          const SizedBox(height: 4),
          Text('Отличная практика!',
              style: AppFonts.rubik(fontWeight: FontWeight.w700, fontSize: 16,
                  color: const Color(0xFF1B6943))),
          const SizedBox(height: 4),
          Text('Ты потренировал бюджет, накопления и покупки. '
              'На следующем игровом дне откроется уровень $nextLevel: '
              'меньше свободных монет и больше условий.',
              textAlign: TextAlign.center,
              style: AppFonts.rubik(fontWeight: FontWeight.w500, fontSize: 12,
                  height: 1.3, color: const Color(0xFF4A4643))),
          if (onBack != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Вернуться на улицу'),
            ),
          ],
        ],
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({
    required this.item,
    required this.completed,
    required this.onTap,
  });

  final PracticeItem item;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFEF7E6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: completed
                  ? const Color(0xFF4B946A)
                  : const Color(0xFF1B6943),
              width: completed ? 2 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDD889)),
                ),
                child: _thumb(item),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      softWrap: true,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFF1B6943),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.blurb,
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 1.25,
                        color: const Color(0xFF4A4643),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                completed ? Icons.check_circle : Icons.chevron_right_rounded,
                color: const Color(0xFF1B6943),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb(PracticeItem item) {
    final asset = item.imageAsset;
    if (asset == null) {
      return Icon(item.icon, color: const Color(0xFF1B6943), size: 32);
    }
    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(asset, fit: BoxFit.contain);
    }
    return Image.asset(
      asset,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          Icon(item.icon, color: const Color(0xFF1B6943), size: 32),
    );
  }
}
