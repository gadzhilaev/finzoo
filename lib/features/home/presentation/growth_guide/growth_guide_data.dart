import '../../../../core/profile/player_profile.dart';

/// Тип страницы обучения про рост.
enum GrowthGuideKind { overview, scores, stage }

/// Данные одной страницы — вне UI.
class GrowthGuidePageData {
  const GrowthGuidePageData({
    required this.kind,
    required this.title,
    this.subtitle,
    this.description,
    this.footer,
    this.stage,
    this.minScore,
    this.nextScore,
    this.scoreRules = const [],
  });

  final GrowthGuideKind kind;
  final String title;
  final String? subtitle;
  final String? description;
  final String? footer;
  final PetGrowthStage? stage;
  final int? minScore;
  final int? nextScore;
  final List<GrowthScoreRule> scoreRules;
}

class GrowthScoreRule {
  const GrowthScoreRule({
    required this.points,
    required this.title,
    required this.text,
    required this.icon,
  });

  final int points;
  final String title;
  final String text;
  final GrowthScoreIcon icon;
}

enum GrowthScoreIcon { care, plan, piggy }

/// Собирает 5 страниц с именем питомца.
List<GrowthGuidePageData> buildGrowthGuidePages(String petName) {
  final pet = petName.trim().isEmpty ? 'Finzo' : petName.trim();
  return [
    GrowthGuidePageData(
      kind: GrowthGuideKind.overview,
      title: 'Как растёт $pet',
      description:
          '$pet растёт не от дней календаря, а от умных решений '
          'за несколько игровых дней.',
      footer: 'Уровень $pet можно посмотреть в этой книжке в любой момент.',
    ),
    GrowthGuidePageData(
      kind: GrowthGuideKind.scores,
      title: 'Откуда берутся очки',
      description: 'За один игровой день можно получить до 4 очков.',
      footer:
          'Если день прошёл неидеально — ничего страшного. Очки не пропадают.',
      scoreRules: const [
        GrowthScoreRule(
          points: 2,
          title: 'Нужное',
          text: 'Finz поел или получил необходимый уход',
          icon: GrowthScoreIcon.care,
        ),
        GrowthScoreRule(
          points: 1,
          title: 'План',
          text: 'Ты не потратил больше, чем запланировал',
          icon: GrowthScoreIcon.plan,
        ),
        GrowthScoreRule(
          points: 1,
          title: 'Копилка',
          text: 'Ты отложил монеты на свою цель',
          icon: GrowthScoreIcon.piggy,
        ),
      ],
    ),
    GrowthGuidePageData(
      kind: GrowthGuideKind.stage,
      title: 'Малыш',
      subtitle: '0–5 очков',
      description:
          '$pet только начинает учиться считать деньги вместе с тобой.',
      footer: 'Набери 6 очков, чтобы $pet стал Растущим.',
      stage: PetGrowthStage.little,
      minScore: 0,
      nextScore: 6,
    ),
    GrowthGuidePageData(
      kind: GrowthGuideKind.stage,
      title: 'Растущий',
      subtitle: '6–11 очков',
      description: '$pet уже умеет держать план и копить вместе с тобой.',
      footer: 'Набери 12 очков, чтобы $pet стал Самостоятельным.',
      stage: PetGrowthStage.growing,
      minScore: 6,
      nextScore: 12,
    ),
    GrowthGuidePageData(
      kind: GrowthGuideKind.stage,
      title: 'Самостоятельный',
      subtitle: '12+ очков',
      description:
          '$pet уверенно различает нужное, желания и накопления вместе с тобой.',
      footer:
          'Продолжай принимать умные решения — этот уровень останется с тобой.',
      stage: PetGrowthStage.confident,
      minScore: 12,
      nextScore: null,
    ),
  ];
}
