import 'package:flutter/material.dart';

import '../../../core/layout/design_scale.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/finzo_book_tokens.dart';
import 'book/animated_book_background.dart';
import 'book/book_content.dart';
import 'book/book_widgets.dart';

/// Book 1–6: стабильный [BookChromeShell] + сменяемый content.
///
/// Эталон геометрии shell — «Книжка 1 cтр.svg»:
/// frame `(11.5, 62.5, 371×688, rx=40.5)`.
///
/// AnimatedSwitcher оборачивает ТОЛЬКО page content.
class BookPage extends StatefulWidget {
  const BookPage({
    super.key,
    this.onOpenHouse,
    this.onOpenParkGame,
    this.startAtToc = false,
    this.startPage,
  });

  final VoidCallback? onOpenHouse;
  final void Function(String parkSpotId)? onOpenParkGame;
  final bool startAtToc;
  final int? startPage;

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  late int _index;
  String? _picked;
  bool _checked = false;

  /// Background lives for the whole Book lifecycle.
  final GlobalKey _bgKey = GlobalKey();

  List<DesignerBookScreen> get _screens => BookContent.screens;

  @override
  void initState() {
    super.initState();
    _index = (widget.startPage ?? 0).clamp(0, _screens.length - 1);
  }

  void _go(int d) {
    final n = (_index + d).clamp(0, _screens.length - 1);
    if (n == _index) return;
    setState(() {
      _index = n;
      _picked = null;
      _checked = false;
    });
  }

  void _pick(String id) {
    setState(() {
      _picked = id;
      _checked = false;
    });
  }

  void _check() {
    if (_picked == null) return;
    setState(() => _checked = true);
  }

  @override
  Widget build(BuildContext context) {
    final screen = _screens[_index];
    final canBack = _index > 0;
    final canFwd = _index < _screens.length - 1;

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBookBackground(key: _bgKey),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: DesignScale.designWidth,
                    height: DesignScale.designHeight,
                    child: _BookChromeShell(
                      pageLabel: '${_index + 1} / ${_screens.length}',
                      canBack: canBack,
                      canFwd: canFwd,
                      onBack: () => _go(-1),
                      onFwd: () => _go(1),
                      onHome: widget.onOpenHouse,
                      onBook: () => setState(() {
                        _index = 0;
                        _picked = null;
                        _checked = false;
                      }),
                      content: _PageContent(
                        key: ValueKey<String>(screen.asset),
                        screen: screen,
                        picked: _picked,
                        checked: _checked,
                        onPick: _pick,
                        onCheck: _check,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Фиксированный chrome по эталону Book 1. Не участвует в page transition.
class _BookChromeShell extends StatelessWidget {
  const _BookChromeShell({
    required this.pageLabel,
    required this.canBack,
    required this.canFwd,
    required this.onBack,
    required this.onFwd,
    required this.content,
    this.onHome,
    this.onBook,
  });

  final String pageLabel;
  final bool canBack;
  final bool canFwd;
  final VoidCallback onBack;
  final VoidCallback onFwd;
  final VoidCallback? onHome;
  final VoidCallback? onBook;
  final Widget content;

  static const double frameLeft = 11.5;
  static const double frameTop = 62.5;
  static const double frameWidth = 371;
  static const double frameHeight = 688;
  static const double frameRadius = 40.5;

  /// Content sits inside frame, below header, above counter.
  static const double contentLeft = 11.5;
  static const double contentTop = 120;
  static const double contentWidth = 371;
  static const double contentHeight = 590;

  static const double counterTop = 720;
  static const double navTop = 754;
  static const double navLeftBack = 55;
  static const double navLeftFwd = 195;

  static const String headerAsset = 'assets/book/chrome/book_header.png';

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        // Fixed cream fill (Book 1 geometry). Border drawn ABOVE content.
        Positioned(
          left: frameLeft,
          top: frameTop,
          width: frameWidth,
          height: frameHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: FinzoBookTokens.notebookCream,
                borderRadius: BorderRadius.circular(frameRadius),
              ),
            ),
          ),
        ),

        // Page-specific content ONLY — AnimatedSwitcher here, not around shell
        Positioned(
          left: contentLeft,
          top: contentTop,
          width: contentWidth,
          height: contentHeight,
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: content,
            ),
          ),
        ),

        // Fixed green border ON TOP of content so all pages share Book1 edge
        Positioned(
          left: frameLeft,
          top: frameTop,
          width: frameWidth,
          height: frameHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(frameRadius),
                border: Border.all(
                  color: FinzoBookTokens.titleGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),

        // Fixed header (Home / Finzo / Book) — never fades with page
        Positioned.fill(
          child: IgnorePointer(
            child: Image.asset(
              headerAsset,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
            ),
          ),
        ),

        Positioned(
          left: 24,
          top: 70,
          width: 56,
          height: 56,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onHome,
          ),
        ),
        Positioned(
          right: 24,
          top: 70,
          width: 56,
          height: 56,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBook,
          ),
        ),

        // Fixed counter — only the string changes
        Positioned(
          left: 0,
          right: 0,
          top: counterTop,
          child: Text(
            pageLabel,
            textAlign: TextAlign.center,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: FinzoBookTokens.counterSize,
              color: FinzoBookTokens.titleGreen,
            ),
          ),
        ),

        Positioned(
          left: navLeftBack,
          top: navTop,
          child: BookArrowButton(
            forward: false,
            enabled: canBack,
            onTap: onBack,
          ),
        ),
        Positioned(
          left: navLeftFwd,
          top: navTop,
          child: BookArrowButton(
            forward: true,
            enabled: canFwd,
            onTap: onFwd,
          ),
        ),
      ],
    );
  }
}

/// Page-specific art + quiz overlays. Fits into fixed content viewport.
class _PageContent extends StatelessWidget {
  const _PageContent({
    super.key,
    required this.screen,
    required this.picked,
    required this.checked,
    required this.onPick,
    required this.onCheck,
  });

  final DesignerBookScreen screen;
  final String? picked;
  final bool checked;
  final ValueChanged<String> onPick;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    // Content PNG is full 393×852 with transparent chrome; align so the
    // page art (which starts ~y=120 in design) lines up with viewport top.
    // Viewport top = design y=120 → shift image up by 120.
    const designShift = _BookChromeShell.contentTop;

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned(
          left: -_BookChromeShell.contentLeft,
          top: -designShift,
          width: DesignScale.designWidth,
          height: DesignScale.designHeight,
          child: Image.asset(
            screen.asset,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.medium,
            gaplessPlayback: true,
          ),
        ),
        if (screen.quiz) ...[
          Positioned(
            left: 30.5 - _BookChromeShell.contentLeft,
            top: 604.5 - designShift,
            width: 160,
            height: 54,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick('scammer'),
              child: _QuizHighlight(
                selected: picked == 'scammer',
                danger: true,
                revealed: checked,
              ),
            ),
          ),
          Positioned(
            left: 211.5 - _BookChromeShell.contentLeft,
            top: 604.5 - designShift,
            width: 152,
            height: 54,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick('safe'),
              child: _QuizHighlight(
                selected: picked == 'safe',
                danger: false,
                revealed: checked,
              ),
            ),
          ),
          if (picked != null && !checked)
            Positioned(
              left: 55 - _BookChromeShell.contentLeft,
              top: 670 - designShift,
              width: 283,
              height: 44,
              child: _CheckChip(onTap: onCheck),
            ),
          if (checked)
            Positioned(
              left: 30 - _BookChromeShell.contentLeft,
              top: 668 - designShift,
              width: 333,
              child: _FeedbackBanner(
                ok: picked == screen.correctChoiceId,
                text: picked == screen.correctChoiceId
                    ? (screen.feedbackOk ?? 'Верно!')
                    : (screen.feedbackBad ?? 'Подумай ещё'),
              ),
            ),
        ],
      ],
    );
  }
}

class _QuizHighlight extends StatelessWidget {
  const _QuizHighlight({
    required this.selected,
    required this.danger,
    required this.revealed,
  });

  final bool selected;
  final bool danger;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    if (!selected && !revealed) return const SizedBox.expand();
    final color = danger
        ? FinzoBookTokens.dangerStroke
        : FinzoBookTokens.titleGreen;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FinzoBookTokens.cardRadius),
        border: Border.all(color: color, width: selected ? 3 : 1.5),
        color: selected
            ? color.withValues(alpha: revealed ? 0.12 : 0.08)
            : Colors.transparent,
      ),
    );
  }
}

class _CheckChip extends StatelessWidget {
  const _CheckChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: FinzoBookTokens.arrowGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Проверить ответ',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  const _FeedbackBanner({required this.ok, required this.text});
  final bool ok;
  final String text;

  @override
  Widget build(BuildContext context) {
    final stroke =
        ok ? FinzoBookTokens.titleGreen : FinzoBookTokens.dangerStroke;
    final fill = ok ? FinzoBookTokens.mint : FinzoBookTokens.dangerFill;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(FinzoBookTokens.cardRadius),
        border: Border.all(color: stroke),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppFonts.rubik(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          height: 1.25,
          color: FinzoBookTokens.ink,
        ),
      ),
    );
  }
}
