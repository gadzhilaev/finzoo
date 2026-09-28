import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/layout/design_scale.dart';
import '../../../core/profile/player_profile.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/wardrobe/finzo_avatar.dart';
import '../../onboarding/presentation/widgets/onboarding_decor.dart';
import 'book/book_widgets.dart';

/// Окно про уровни Finzo — тот же каркас, что у книжки «обучение».
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
  static const _pages = <_GuidePage>[
    _GuidePage(
      title: 'Уровни Finzo',
      body:
          'Finzo растёт, когда ты хорошо планируешь день: закрываешь нужное, '
          'держишься плана и откладываешь в копилку.',
      tips: [
        (title: 'Нужное', text: '+2 очка, если Finzo поел или ухожен'),
        (title: 'План', text: '+1 очко, если траты не выше плана'),
        (title: 'Копилка', text: '+1 очко, если отложил на цель'),
      ],
      footer: 'Очки копятся за несколько дней. Чем умнее решения — тем выше уровень.',
    ),
    _GuidePage(
      title: '1 · Малыш',
      stage: PetGrowthStage.little,
      body: 'Первый уровень. Finzo только учится вместе с тобой.',
      tips: [
        (title: 'Сейчас', text: '0–5 очков роста'),
        (title: 'Что делать', text: 'Корми, планируй день, копи на цель'),
        (title: 'Дальше', text: 'Набери 6 очков — откроется «Растущий»'),
      ],
      footer: 'Не страшно ошибиться: завтра можно сделать лучше.',
    ),
    _GuidePage(
      title: '2 · Растущий',
      stage: PetGrowthStage.growing,
      body: 'Уже умеет планировать день и копить. Finzo становится увереннее.',
      tips: [
        (title: 'Сейчас', text: '6–11 очков роста'),
        (title: 'Что важно', text: 'Нужное важнее желаний'),
        (title: 'Дальше', text: 'Набери 12 очков — «Самостоятельный»'),
      ],
      footer: 'Сравнивай план и факт в конце дня — так растёшь быстрее.',
    ),
    _GuidePage(
      title: '3 · Самостоятельный',
      stage: PetGrowthStage.confident,
      body: 'Высший уровень. Finzo уверенно делает финансовый выбор.',
      tips: [
        (title: 'Сейчас', text: '12 и больше очков роста'),
        (title: 'Как держать', text: 'Закрывай нужное, копи регулярно'),
        (title: 'Награда', text: 'Finzo выглядит крупнее и увереннее'),
      ],
      footer: 'Продолжай умные решения — прогресс не сбрасывается.',
    ),
  ];

  int _index = 0;

  void _close() => widget.onClose?.call();

  void _go(int d) {
    final next = _index + d;
    if (next < 0) return;
    if (next >= _pages.length) {
      _close();
      return;
    }
    setState(() => _index = next);
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_index];
    final current = widget.profile.growthStage;
    final points = widget.profile.growthPoints;
    final canBack = _index > 0;
    final canFwd = true; // на последней странице — закрыть
    final pageNo = '${_index + 1} / ${_pages.length}';

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
                    onTap: _close,
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
                          child: Column(
                            children: [
                              if (page.stage != null) ...[
                                SizedBox(
                                  height: 100,
                                  child: FinzoAvatar(
                                    profile: widget.profile.copyWith(
                                      growthPoints: switch (page.stage!) {
                                        PetGrowthStage.little => 0,
                                        PetGrowthStage.growing => 6,
                                        PetGrowthStage.confident => 12,
                                      },
                                    ),
                                    width: 92,
                                    height: 100,
                                    alignBodyAxis: true,
                                    bodyAxisFactor: 0.55,
                                  ),
                                ),
                                if (page.stage == current) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: BookStyle.mint,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: BookStyle.green,
                                      ),
                                    ),
                                    child: Text(
                                      'Сейчас у тебя: $points очков',
                                      style: AppFonts.rubik(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: BookStyle.green,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                              ],
                              Text(
                                page.body,
                                textAlign: TextAlign.center,
                                style: AppFonts.rubik(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  height: 1.35,
                                  color: BookStyle.body,
                                ),
                              ),
                              const SizedBox(height: 12),
                              BookTipGroup(items: page.tips),
                              const SizedBox(height: 12),
                              Text(
                                page.footer,
                                textAlign: TextAlign.center,
                                style: AppFonts.rubik(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  height: 1.3,
                                  color: BookStyle.orange,
                                ),
                              ),
                            ],
                          ),
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
}

class _GuidePage {
  const _GuidePage({
    required this.title,
    required this.body,
    required this.tips,
    required this.footer,
    this.stage,
  });

  final String title;
  final String body;
  final List<({String? title, String text})> tips;
  final String footer;
  final PetGrowthStage? stage;
}
