import 'package:flutter/material.dart';

import '../../../core/profile/player_profile.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/finzo_book_tokens.dart';
import 'book/book_chrome.dart';
import 'book/book_page_layout.dart';
import 'book/book_widgets.dart';
import 'growth_guide/growth_guide_data.dart';
import 'growth_guide/growth_guide_widgets.dart';

/// Обучение про рост питомца — стиль книжки из `обучение.zip`.
class GrowthGuidePage extends StatefulWidget {
  const GrowthGuidePage({super.key, required this.profile, this.onClose});

  final PlayerProfile profile;
  final VoidCallback? onClose;

  static Future<void> open(BuildContext context, PlayerProfile profile) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: true,
        pageBuilder: (_, _, _) => GrowthGuidePage(
          profile: profile,
          onClose: () => Navigator.of(context).pop(),
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  @override
  State<GrowthGuidePage> createState() => _GrowthGuidePageState();
}

class _GrowthGuidePageState extends State<GrowthGuidePage> {
  int _index = 0;
  int _dir = 1;

  String get _pet {
    final n = widget.profile.petName.trim();
    return n.isEmpty ? 'Finzo' : n;
  }

  bool get _animate => widget.profile.animationsEnabled;

  List<GrowthGuidePageData> get _pages => buildGrowthGuidePages(_pet);

  void _close() => widget.onClose?.call();

  void _go(int d) {
    final pages = _pages;
    final next = _index + d;
    if (next < 0 || next >= pages.length) return;
    setState(() {
      _dir = d;
      _index = next;
    });
  }

  void _goToc() => setState(() {
    _dir = -1;
    _index = 0;
  });

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    final page = pages[_index];
    final canBack = _index > 0;
    final canFwd = _index < pages.length - 1;
    final duration = _animate
        ? const Duration(milliseconds: 260)
        : Duration.zero;

    return BookChromeShell(
      title: page.title,
      subtitle: page.subtitle,
      pageLabel: '${_index + 1} / ${pages.length}',
      canBack: canBack,
      canFwd: canFwd,
      onBack: () => _go(-1),
      onFwd: () => _go(1),
      onHome: _close,
      onBook: _goToc,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (current, _) => current ?? const SizedBox.shrink(),
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: Offset(_dir > 0 ? 0.06 : -0.06, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: _PageBody(
            page: page,
            profile: widget.profile,
            petName: _pet,
            animate: _animate,
            showDone: !canFwd,
            onDone: _close,
          ),
        ),
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({
    required this.page,
    required this.profile,
    required this.petName,
    required this.animate,
    required this.showDone,
    required this.onDone,
  });

  final GrowthGuidePageData page;
  final PlayerProfile profile;
  final String petName;
  final bool animate;
  final bool showDone;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return switch (page.kind) {
      GrowthGuideKind.overview => BookPageLayout(
        heroSize: BookHeroSize.none,
        scrollable: true,
        body: _OverviewBody(page: page, profile: profile, animate: animate),
      ),
      GrowthGuideKind.scores => BookPageLayout(
        heroSize: BookHeroSize.none,
        scrollable: true,
        body: _ScoresBody(page: page, petName: petName, animate: animate),
      ),
      GrowthGuideKind.stage => BookPageLayout(
        heroSize: BookHeroSize.large,
        hero: GrowthHeroPet(
          profile: profile,
          stage: page.stage!,
          animate: animate,
          celebrate: page.nextScore == null,
        ),
        body: _StageBody(
          page: page,
          profile: profile,
          animate: animate,
          showDone: showDone,
          onDone: onDone,
          includeHero: false,
        ),
      ),
    };
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({
    required this.page,
    required this.profile,
    required this.animate,
  });

  final GrowthGuidePageData page;
  final PlayerProfile profile;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GrowthStageChain(
          profile: profile,
          current: profile.growthStage,
          animate: animate,
        ),
        const SizedBox(height: 14),
        Text(
          page.description ?? '',
          textAlign: TextAlign.center,
          style: BookType.body,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: BookStyle.mint,
            borderRadius: BorderRadius.circular(FinzoBookTokens.cardRadius),
            border: Border.all(color: BookStyle.green.withValues(alpha: 0.55)),
          ),
          child: Column(
            children: [
              _MiniRule(label: 'Малыш', value: '0–5 очков'),
              const SizedBox(height: 6),
              _MiniRule(label: 'Растущий', value: '6–11 очков'),
              const SizedBox(height: 6),
              _MiniRule(label: 'Самостоятельный', value: '12+ очков'),
              const SizedBox(height: 6),
              _MiniRule(label: 'За день', value: 'до 4 очков'),
            ],
          ),
        ),
        if (page.footer != null) ...[
          const SizedBox(height: 12),
          GrowthHintLine(text: page.footer!),
        ],
      ],
    );
  }
}

class _MiniRule extends StatelessWidget {
  const _MiniRule({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: BookStyle.green,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label · ',
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: BookStyle.green,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: BookStyle.body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoresBody extends StatelessWidget {
  const _ScoresBody({
    required this.page,
    required this.petName,
    required this.animate,
  });

  final GrowthGuidePageData page;
  final String petName;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final rules = page.scoreRules;
    return Column(
      children: [
        for (var i = 0; i < rules.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _Stagger(
            index: i,
            animate: animate,
            child: GrowthScoreRuleCard(rule: rules[i], petName: petName),
          ),
        ],
        if (page.description != null) ...[
          const SizedBox(height: 12),
          Text(
            page.description!,
            textAlign: TextAlign.center,
            style: BookType.section,
          ),
        ],
        if (page.footer != null) ...[
          const SizedBox(height: 8),
          GrowthHintLine(text: page.footer!),
        ],
      ],
    );
  }
}

class _StageBody extends StatelessWidget {
  const _StageBody({
    required this.page,
    required this.profile,
    required this.animate,
    required this.showDone,
    required this.onDone,
    this.includeHero = true,
  });

  final GrowthGuidePageData page;
  final PlayerProfile profile;
  final bool animate;
  final bool showDone;
  final VoidCallback onDone;
  final bool includeHero;

  @override
  Widget build(BuildContext context) {
    final stage = page.stage!;
    final isCurrent = profile.growthStage == stage;
    final isFinal = page.nextScore == null;
    final points = profile.growthPoints;

    return Column(
      children: [
        if (includeHero) ...[
          GrowthHeroPet(
            profile: profile,
            stage: stage,
            animate: animate,
            celebrate: isFinal,
          ),
          const SizedBox(height: 8),
        ],
        if (isCurrent) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: BookStyle.mint,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BookStyle.green),
            ),
            child: Text(
              'Сейчас: $points очков',
              style: AppFonts.rubik(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: BookStyle.green,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          page.description ?? '',
          textAlign: TextAlign.center,
          style: BookType.body,
        ),
        const SizedBox(height: 12),
        if (isFinal) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            decoration: BoxDecoration(
              color: BookStyle.mint,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BookStyle.green, width: 1.4),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: BookStyle.orange,
                  size: 26,
                ),
                const SizedBox(height: 6),
                Text(
                  'Высший уровень достигнут',
                  textAlign: TextAlign.center,
                  style: BookType.section,
                ),
              ],
            ),
          ),
        ] else if (page.nextScore != null) ...[
          GrowthStageProgress(
            points: points,
            nextScore: page.nextScore!,
            animate: animate,
          ),
        ],
        if (page.footer != null) ...[
          const SizedBox(height: 10),
          GrowthHintLine(text: page.footer!),
        ],
        if (showDone) ...[
          const SizedBox(height: 14),
          BookPrimaryButton(label: 'Понятно', onTap: onDone),
        ],
      ],
    );
  }
}

class _Stagger extends StatelessWidget {
  const _Stagger({
    required this.index,
    required this.animate,
    required this.child,
  });

  final int index;
  final bool animate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
