import '../../../../core/assets/app_assets.dart';

/// Одна страница = один макет дизайнера из `обучение/`.
class DesignerBookScreen {
  const DesignerBookScreen({
    required this.title,
    required this.asset,
    this.quiz = false,
    this.correctChoiceId,
    this.feedbackOk,
    this.feedbackBad,
  });

  final String title;

  /// PNG, экспортированный из SVG дизайнера (pattern/embedded image
  /// в SVG flutter_svg ломает — поэтому растр).
  final String asset;

  /// Книжка 4 / 5: выбор «Мошенник» / «Магазин».
  final bool quiz;
  final String? correctChoiceId;
  final String? feedbackOk;
  final String? feedbackBad;
}

/// Книжка = ровно экраны из `/Downloads/svg/обучение`.
/// Никаких самодельных уроков и старых BookHeroScene.
abstract final class BookContent {
  static const coverTitle = 'Деньги с Finzo';

  static const screens = <DesignerBookScreen>[
    DesignerBookScreen(
      title: 'Кто пишет: магазин или мошенник?',
      asset: AppAssets.bookSafety01,
    ),
    DesignerBookScreen(
      title: 'Шаг 1: Проверь адрес и ссылку',
      asset: AppAssets.bookSafety02,
    ),
    DesignerBookScreen(
      title: 'Шаг 2: Как с тобой общаются',
      asset: AppAssets.bookSafety03,
    ),
    DesignerBookScreen(
      title: 'Шаг 3: Проверка запроса',
      asset: AppAssets.bookSafety04,
    ),
    DesignerBookScreen(
      title: 'Закрепим!',
      asset: AppAssets.bookSafety05,
      quiz: true,
      correctChoiceId: 'scammer',
      feedbackOk:
          'Верно: «выигрыш» и оплата комиссии по странной ссылке — мошенник.',
      feedbackBad:
          'Настоящий магазин не просит комиссию за выигрыш по странной ссылке.',
    ),
    DesignerBookScreen(
      title: 'Ещё раз!',
      asset: AppAssets.bookSafety06,
      quiz: true,
      correctChoiceId: 'scammer',
      feedbackOk: 'Верно: код из SMS никому не диктуют — даже «оператору».',
      feedbackBad:
          'Код из SMS — только для тебя. Просьба продиктовать код — мошенник.',
    ),
  ];

  static int get flatPageCount => screens.length;

  /// Для тестов / старых вызовов.
  static List<({String id, String title, String blurb})> get toc => [
        (
          id: 'safety',
          title: 'Безопасность',
          blurb: 'Экраны дизайнера из обучение/',
        ),
      ];
}
