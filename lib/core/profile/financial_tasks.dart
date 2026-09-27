/// Финансовое задание игрового дня: ситуация → выбор → объяснение (без денег).
class FinancialTaskChoice {
  const FinancialTaskChoice({
    required this.id,
    required this.label,
    required this.isCorrect,
    required this.explanation,
  });

  final String id;
  final String label;
  final bool isCorrect;
  final String explanation;
}

class FinancialTask {
  const FinancialTask({
    required this.id,
    required this.title,
    required this.situation,
    required this.choices,
  });

  final String id;
  final String title;
  final String situation;
  final List<FinancialTaskChoice> choices;
}

abstract final class FinancialTasks {
  /// Пока одно задание; ротация по номеру игрового дня.
  static const all = <FinancialTask>[
    FinancialTask(
      id: 'ice_cream_vs_food',
      title: 'Что купить сначала?',
      situation:
          'Мало денег до конца дня. Хочется мороженое, '
          'но скоро понадобится еда. Что выбрать?',
      choices: [
        FinancialTaskChoice(
          id: 'food_first',
          label: 'Сначала еда — это необходимое',
          isCorrect: true,
          explanation:
              'Верно! Необходимое важнее желаний. '
              'Так Finzo не останется голодным.',
        ),
        FinancialTaskChoice(
          id: 'ice_first',
          label: 'Сначала мороженое — порадовать себя',
          isCorrect: false,
          explanation:
              'Мороженое — желание. Если потратить всё на него, '
              'на еду может не хватить. Это не ошибка навсегда: '
              'в плане можно оставить больше на необходимое.',
        ),
        FinancialTaskChoice(
          id: 'buy_nothing',
          label: 'Ничего не покупать до следующего дня',
          isCorrect: false,
          explanation:
              'Еда относится к необходимому. Можно купить немного еды '
              'и оставить желания на потом — попробуй ещё раз.',
        ),
      ],
    ),
    FinancialTask(
      id: 'save_a_bit',
      title: 'Копить или всё потратить?',
      situation:
          'Пришли карманные. Друг зовёт купить игрушку, '
          'а цель накоплений ещё далеко. Как поступить?',
      choices: [
        FinancialTaskChoice(
          id: 'split',
          label: 'Часть отложить в накопления, часть оставить',
          isCorrect: true,
          explanation:
              'Отлично! Даже небольшая сумма в копилку приближает к цели.',
        ),
        FinancialTaskChoice(
          id: 'all_toy',
          label: 'Потратить всё на игрушку',
          isCorrect: false,
          explanation:
              'Игрушка — желание. Без накоплений цель отодвинется. '
              'Можно купить подешевле или отложить покупку.',
        ),
        FinancialTaskChoice(
          id: 'all_save',
          label: 'Отложить всё, даже без еды',
          isCorrect: false,
          explanation:
              'Копить важно, но необходимое (еда, уход) тоже нужно. '
              'В плане оставь деньги на необходимое и накопления.',
        ),
      ],
    ),
  ];

  static FinancialTask forPeriod(int periodIndex) {
    if (all.isEmpty) return all.first;
    final i = (periodIndex - 1).clamp(0, 999) % all.length;
    return all[i];
  }
}
