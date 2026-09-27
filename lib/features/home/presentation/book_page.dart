import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/layout/design_scale.dart';
import '../../../core/theme/app_fonts.dart';
import '../../onboarding/presentation/widgets/onboarding_decor.dart';
import 'book/book_content.dart';
import 'book/book_widgets.dart';

/// Книжка «Деньги с Finzo»: уроки по темам ТЗ + отдельные упражнения.
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

enum _Kind { cover, lesson, toc }

class _FlatPage {
  const _FlatPage({
    required this.title,
    required this.kind,
    this.lesson,
    this.lessonPage,
  });
  final String title;
  final _Kind kind;
  final BookLesson? lesson;
  final BookLessonPage? lessonPage;
}

class _BookPageState extends State<BookPage> {
  late int _index;
  late final List<_FlatPage> _pages;

  /// Выбор по ключу lessonId+pageTitle — сохраняется при листании.
  final Map<String, Set<String>> _picked = {};
  final Map<String, bool> _checked = {};

  @override
  void initState() {
    super.initState();
    _pages = _build();
    if (widget.startAtToc) {
      _index = _pages.length - 1;
    } else if (widget.startPage != null) {
      _index = widget.startPage!.clamp(0, _pages.length - 1);
    } else {
      _index = 0;
    }
  }

  List<_FlatPage> _build() {
    final out = <_FlatPage>[
      const _FlatPage(title: BookContent.coverTitle, kind: _Kind.cover),
    ];
    for (final lesson in BookContent.lessons) {
      for (final p in lesson.pages) {
        out.add(_FlatPage(
          title: p.title,
          kind: _Kind.lesson,
          lesson: lesson,
          lessonPage: p,
        ));
      }
    }
    out.add(const _FlatPage(title: 'Оглавление', kind: _Kind.toc));
    return out;
  }

  String _key(_FlatPage p) =>
      '${p.lesson?.id ?? 'x'}_${p.lessonPage?.title ?? p.title}';

  void _go(int d) {
    final n = (_index + d).clamp(0, _pages.length - 1);
    if (n != _index) setState(() => _index = n);
  }

  void _jumpToLesson(String id) {
    final i = _pages.indexWhere((p) => p.lesson?.id == id);
    if (i >= 0) setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];
    final pageNo = '${_index + 1} / ${_pages.length}';
    final canBack = _index > 0;
    final canFwd = _index < _pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF4),
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: DesignScale.designWidth,
            height: DesignScale.designHeight,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: IgnorePointer(child: OnboardingDecor()),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: SvgPicture.asset(
                      AppAssets.book,
                      fit: BoxFit.fill,
                      width: DesignScale.designWidth,
                      height: DesignScale.designHeight,
                    ),
                  ),
                ),
                const Positioned(
                  left: 28,
                  top: 128,
                  width: 337,
                  height: 600,
                  child: ColoredBox(color: BookStyle.cream),
                ),
                Positioned(
                  left: 24,
                  top: 70,
                  width: 56,
                  height: 56,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onOpenHouse?.call(),
                  ),
                ),
                Positioned(
                  right: 24,
                  top: 70,
                  width: 56,
                  height: 56,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _index = _pages.length - 1),
                  ),
                ),
                Positioned(
                  left: 44,
                  top: 140,
                  width: 305,
                  height: 560,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w700,
                          fontSize: 19,
                          height: 1.15,
                          color: BookStyle.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: _body(page),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        pageNo,
                        textAlign: TextAlign.center,
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: BookStyle.counter,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 64,
                  top: 764,
                  child: BookArrowButton(
                    forward: false,
                    enabled: canBack,
                    onTap: () => _go(-1),
                  ),
                ),
                Positioned(
                  left: 204,
                  top: 764,
                  child: BookArrowButton(
                    forward: true,
                    enabled: canFwd,
                    onTap: () => _go(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(_FlatPage page) {
    switch (page.kind) {
      case _Kind.cover:
        return _cover();
      case _Kind.toc:
        return _toc();
      case _Kind.lesson:
        return _lesson(page);
    }
  }

  Widget _cover() {
    return Column(
      children: [
        Text(
          BookContent.coverSubtitle,
          textAlign: TextAlign.center,
          style: AppFonts.rubik(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: BookStyle.body,
          ),
        ),
        const SizedBox(height: 8),
        const BookHeroScene(kind: BookSceneKind.coverLoupe),
        const SizedBox(height: 8),
        for (final t in BookContent.coverTips)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BookTipCard(title: t.title, text: t.text),
          ),
      ],
    );
  }

  Widget _toc() {
    return Column(
      children: [
        for (final item in BookContent.toc)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BookTipCard(
              title: item.title,
              text: item.blurb,
              onTap: () => _jumpToLesson(item.id),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: BookStyle.green,
              ),
            ),
          ),
      ],
    );
  }

  Widget _lesson(_FlatPage page) {
    final lp = page.lessonPage!;
    final lesson = page.lesson!;
    final key = _key(page);
    final picked = _picked.putIfAbsent(key, () => <String>{});
    final checked = _checked[key] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BookHeroScene(kind: lp.scene, compact: true),
        const SizedBox(height: 8),
        if (lp.blocks.isNotEmpty)
          BookTipGroup(
            items: [
              for (final b in lp.blocks) (title: null, text: b),
            ],
          ),
        if (lp.exampleLines.isNotEmpty) ...[
          const SizedBox(height: 8),
          BookTipCard(
            title: lp.exampleTitle ?? 'Пример',
            text: lp.exampleLines.join('\n'),
          ),
        ],
        if (lp.kind == BookLessonKind.action) ...[
          const SizedBox(height: 8),
          Text(
            lp.actionPrompt ?? '',
            textAlign: TextAlign.center,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: BookStyle.green,
            ),
          ),
          if (lp.correctChoiceIds.length > 1)
            Text(
              'Можно выбрать один или несколько верных ответов',
              textAlign: TextAlign.center,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: BookStyle.counter,
              ),
            ),
          const SizedBox(height: 8),
          for (final c in lp.choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: BookTipCard(
                text: c.label,
                selected: picked.contains(c.id),
                onTap: () => setState(() {
                  if (lp.correctChoiceIds.length > 1) {
                    if (picked.contains(c.id)) {
                      picked.remove(c.id);
                    } else {
                      picked.add(c.id);
                    }
                  } else {
                    picked
                      ..clear()
                      ..add(c.id);
                  }
                  _checked[key] = false;
                }),
              ),
            ),
          _CheckBtn(
            label: checked ? 'Проверено' : 'Проверить ответ',
            onTap: picked.isEmpty
                ? null
                : () => setState(() => _checked[key] = true),
          ),
          if (checked) ...[
            const SizedBox(height: 8),
            Builder(
              builder: (_) {
                final noBad = picked.every(lp.correctChoiceIds.contains);
                final good = noBad &&
                    (lp.correctChoiceIds.length == 1
                        ? picked.contains(lp.correctChoiceIds.first)
                        : picked.intersection(lp.correctChoiceIds).isNotEmpty);
                return BookTipCard(
                  title: good ? 'Хорошо' : 'Подумай ещё',
                  text: good
                      ? (lp.feedbackOk ?? 'Верно!')
                      : (lp.feedbackBad ?? 'Выбери другой вариант.'),
                );
              },
            ),
          ],
        ],
        if (lp.kind == BookLessonKind.bridge && lesson.parkSpotId != null) ...[
          const SizedBox(height: 12),
          _CheckBtn(
            label: 'Открыть практику',
            onTap: () => widget.onOpenParkGame?.call(lesson.parkSpotId!),
          ),
          const SizedBox(height: 6),
          Text(
            'Игра — дополнительно после урока, не вместо него.',
            textAlign: TextAlign.center,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: BookStyle.counter,
            ),
          ),
        ],
      ],
    );
  }
}

class _CheckBtn extends StatelessWidget {
  const _CheckBtn({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final on = onTap != null;
    return Material(
      color: on ? BookStyle.arrowGreen : BookStyle.arrowMuted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
