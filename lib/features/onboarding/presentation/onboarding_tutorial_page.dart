import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/profile/economy.dart';
import '../../../core/profile/player_profile.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/wardrobe/finzo_avatar.dart';
import '../../home/presentation/book/book_chrome.dart';
import '../../home/presentation/book/book_widgets.dart';

/// Основное обучение Finzo после выбора питомца.
///
/// Смысл intro-экранов (приветствие → монеты → нужно/хочу/коплю → готовность)
/// в каркасе книжки; антифрод-страницы из `обучение.zip` — в BookPage / safety.
class OnboardingTutorialPage extends StatefulWidget {
  const OnboardingTutorialPage({
    super.key,
    required this.profile,
    required this.petName,
    required this.onDone,
    this.onExitBack,
    this.animationsEnabled = true,
  });

  final PlayerProfile profile;
  final String petName;
  final VoidCallback onDone;

  /// Назад с первой страницы (к выбору питомца).
  final VoidCallback? onExitBack;
  final bool animationsEnabled;

  static const int pageCount = 6;

  @override
  State<OnboardingTutorialPage> createState() => _OnboardingTutorialPageState();
}

class _OnboardingTutorialPageState extends State<OnboardingTutorialPage> {
  int _index = 0;
  int _dir = 1;
  int? _selectedDecision;

  String get _pet {
    final n = widget.petName.trim();
    return n.isEmpty ? 'Finzo' : n;
  }

  void _go(int d) {
    final next = _index + d;
    if (next < 0) {
      widget.onExitBack?.call();
      return;
    }
    if (next >= OnboardingTutorialPage.pageCount) return;
    setState(() {
      _dir = d;
      _index = next;
      _selectedDecision = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == OnboardingTutorialPage.pageCount - 1;
    final page = _pageAt(_index);
    final duration = widget.animationsEnabled
        ? const Duration(milliseconds: 260)
        : Duration.zero;

    return BookChromeShell(
      title: page.title,
      subtitle: page.subtitle,
      pageLabel: '${_index + 1} / ${OnboardingTutorialPage.pageCount}',
      canBack: _index > 0 || widget.onExitBack != null,
      canFwd: !last,
      onBack: () => _go(-1),
      onFwd: () => _go(1),
      bottomExtra: last
          ? BookPrimaryButton(
              label: 'Начать игру',
              onTap: widget.onDone,
            )
          : null,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (current, previous) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              ...previous,
              ?current,
            ],
          );
        },
        transitionBuilder: (child, anim) {
          final offset = Tween<Offset>(
            begin: Offset(_dir > 0 ? 0.08 : -0.08, 0),
            end: Offset.zero,
          ).animate(anim);
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_index),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: page.body,
          ),
        ),
      ),
    );
  }

  _PageSpec _pageAt(int i) {
    return switch (i) {
      0 => _PageSpec(
          title: 'Привет! Я $_pet',
          body: _HelloBody(
            profile: widget.profile,
            animate: widget.animationsEnabled,
          ),
        ),
      1 => const _PageSpec(
          title: 'У тебя есть монеты',
          body: _CoinsBody(),
        ),
      2 => _PageSpec(
          title: 'Три умных решения',
          subtitle: 'Нажми карточку',
          body: _DecisionsBody(
            selected: _selectedDecision,
            onSelect: (v) => setState(() => _selectedDecision = v),
          ),
        ),
      3 => _PageSpec(
          title: 'Сначала — нужное',
          body: _NeedsBody(profile: widget.profile),
        ),
      4 => const _PageSpec(
          title: 'Можно копить на мечту',
          body: _SaveBody(),
        ),
      _ => _PageSpec(
          title: 'Готово!',
          body: _ReadyBody(
            profile: widget.profile,
            petName: _pet,
            animate: widget.animationsEnabled,
          ),
        ),
    };
  }
}

class _PageSpec {
  const _PageSpec({
    required this.title,
    required this.body,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget body;
}

class _HelloBody extends StatefulWidget {
  const _HelloBody({required this.profile, required this.animate});

  final PlayerProfile profile;
  final bool animate;

  @override
  State<_HelloBody> createState() => _HelloBodyState();
}

class _HelloBodyState extends State<_HelloBody>
    with SingleTickerProviderStateMixin {
  AnimationController? _breath;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _breath = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      )..repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breath?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget pet = Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 188,
          height: 188,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: BookStyle.mint.withValues(alpha: 0.7),
            border: Border.all(
              color: BookStyle.stroke.withValues(alpha: 0.45),
              width: 2,
            ),
          ),
        ),
        FinzoAvatar(
          profile: widget.profile,
          width: 150,
          height: 168,
        ),
        Positioned(
          right: 18,
          top: 22,
          child: Icon(
            Icons.star_rounded,
            size: 18,
            color: BookStyle.orange.withValues(alpha: 0.85),
          ),
        ),
        Positioned(
          left: 22,
          bottom: 28,
          child: Icon(
            Icons.circle,
            size: 8,
            color: BookStyle.arrowGreen.withValues(alpha: 0.55),
          ),
        ),
      ],
    );

    if (_breath != null) {
      pet = AnimatedBuilder(
        animation: _breath!,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_breath!.value);
          return Transform.translate(
            offset: Offset(0, -3 + t * 6),
            child: Transform.scale(scale: 0.98 + t * 0.04, child: child),
          );
        },
        child: pet,
      );
    }

    return Column(
      children: [
        SizedBox(height: 220, child: Center(child: pet)),
        const SizedBox(height: 8),
        const BookInfoCard(
          title: 'Рад познакомиться!',
          body:
              'Заботься обо мне и учись распоряжаться монетами. '
              'Вместе разберёмся, что нужно, что хочется и на что копить.',
        ),
      ],
    );
  }
}

class _CoinsBody extends StatelessWidget {
  const _CoinsBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          decoration: BoxDecoration(
            color: BookStyle.mint,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: BookStyle.green.withValues(alpha: 0.45),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              SvgPicture.asset(AppAssets.rubleMark, width: 36, height: 36),
              const SizedBox(height: 6),
              Text(
                '1 000',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w800,
                  fontSize: 40,
                  color: BookStyle.ink,
                ),
              ),
              Text(
                'монет на день',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: BookStyle.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Монеты ограничены — на всё сразу их может не хватить.',
          textAlign: TextAlign.center,
          style: AppFonts.rubik(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            height: 1.35,
            color: BookStyle.body,
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _AssetChip(
                label: 'Нужно',
                asset: 'assets/images/house_inv/item_0.png',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _AssetChip(
                label: 'Хочу',
                asset: 'assets/images/house_inv_clothes/item_0.png',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _AssetChip(
                label: 'Коплю',
                asset: AppAssets.goalBicycle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const BookInfoCard(
          body: 'Поэтому каждый день нужно выбирать, куда их отправить.',
        ),
      ],
    );
  }
}

class _AssetChip extends StatelessWidget {
  const _AssetChip({required this.label, required this.asset});

  final String label;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BookStyle.green.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            asset,
            height: 36,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.circle,
              size: 28,
              color: BookStyle.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: BookStyle.greenDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionsBody extends StatelessWidget {
  const _DecisionsBody({
    required this.selected,
    required this.onSelect,
  });

  final int? selected;
  final ValueChanged<int> onSelect;

  static const _items = [
    (
      title: 'Нужно',
      asset: 'assets/images/house_inv/item_0.png',
      tip: 'То, без чего трудно обойтись: еда, уход, важные вещи.',
    ),
    (
      title: 'Хочу',
      asset: 'assets/images/house_inv_clothes/item_1.png',
      tip: 'Приятно иметь, но такую покупку можно отложить.',
    ),
    (
      title: 'Коплю',
      asset: AppAssets.goalBicycle,
      tip: 'Монеты на большую мечту — копилка постепенно наполняется.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _DecisionCard(
            title: _items[i].title,
            asset: _items[i].asset,
            tip: _items[i].tip,
            selected: selected == i,
            onTap: () => onSelect(i),
          ),
        ],
        const SizedBox(height: 12),
        BookInfoCard(
          body: selected == null
              ? 'Выбери карточку — узнаешь, что значит каждое решение.'
              : _items[selected!].tip,
        ),
      ],
    );
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({
    required this.title,
    required this.asset,
    required this.tip,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String asset;
  final String tip;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $tip',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? BookStyle.mint : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? BookStyle.green
                    : BookStyle.green.withValues(alpha: 0.35),
                width: selected ? 2.5 : 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: BookStyle.green.withValues(alpha: 0.16),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Image.asset(
                  asset,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: BookStyle.greenDark,
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.touch_app_outlined,
                  color: BookStyle.arrowGreen,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NeedsBody extends StatelessWidget {
  const _NeedsBody({required this.profile});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FinzoAvatar(profile: profile, width: 96, height: 112),
            Padding(
              padding: const EdgeInsets.only(bottom: 36, left: 4, right: 4),
              child: Text(
                '+',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: BookStyle.green,
                ),
              ),
            ),
            const _NeedBubble(
              label: 'Еда',
              asset: 'assets/images/house_inv/item_0.png',
            ),
            const SizedBox(width: 6),
            const _NeedBubble(
              label: 'Уход',
              asset: 'assets/images/house_inv_shower/item_0.png',
            ),
          ],
        ),
        const SizedBox(height: 14),
        const BookInfoCard(
          title: 'Нужно',
          body:
              'Это то, без чего Finzo трудно обойтись. '
              'Сначала подумай о нужном.',
        ),
        const SizedBox(height: 10),
        const BookInfoCard(
          title: 'Хочу',
          body:
              'Игрушки и наряды — приятно, но их можно купить чуть позже.',
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: BookStyle.mint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: BookStyle.green.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Text(
            'Сначала нужное — потом желания. Так Finzo будет в порядке.',
            textAlign: TextAlign.center,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              height: 1.35,
              color: BookStyle.greenDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _NeedBubble extends StatelessWidget {
  const _NeedBubble({required this.label, required this.asset});

  final String label;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BookStyle.green.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Image.asset(asset, height: 32, fit: BoxFit.contain),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: BookStyle.body,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBody extends StatelessWidget {
  const _SaveBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: BookStyle.green.withValues(alpha: 0.45),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  AppAssets.goalBicycle,
                  height: 88,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Велосипед',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: BookStyle.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '160 / 800',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: BookStyle.green,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                  value: 160 / 800,
                  minHeight: 12,
                  backgroundColor: BookStyle.mint,
                  color: BookStyle.arrowGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _DayChip(
                label: 'Карманные',
                amount: '+${EconomyRules.periodIncome}',
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: _DayChip(label: 'В копилку', amount: '+80'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const BookInfoCard(
          body:
              'Откладывай часть монет каждый день — и мечта становится ближе. '
              'Не обязательно тратить всё сразу.',
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: BookStyle.mint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BookStyle.green.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: BookStyle.body,
            ),
          ),
          Text(
            amount,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: BookStyle.greenDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyBody extends StatelessWidget {
  const _ReadyBody({
    required this.profile,
    required this.petName,
    required this.animate,
  });

  final PlayerProfile profile;
  final String petName;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: Center(
            child: FinzoAvatar(
              profile: profile,
              width: 140,
              height: 158,
            ),
          ),
        ),
        Text(
          'Теперь ты готов!',
          textAlign: TextAlign.center,
          style: AppFonts.rubik(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: BookStyle.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Помоги $petName заботиться о нужном,\nисполнять желания и копить на цели.',
          textAlign: TextAlign.center,
          style: AppFonts.rubik(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            height: 1.35,
            color: BookStyle.body,
          ),
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _AssetChip(
                label: 'Нужно',
                asset: 'assets/images/house_inv/item_0.png',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _AssetChip(
                label: 'Хочу',
                asset: 'assets/images/house_inv_clothes/item_0.png',
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _AssetChip(
                label: 'Коплю',
                asset: AppAssets.goalBicycle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Дальше — короткое видео, потом выберем цель.',
          textAlign: TextAlign.center,
          style: AppFonts.rubik(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: BookStyle.green,
          ),
        ),
      ],
    );
  }
}
