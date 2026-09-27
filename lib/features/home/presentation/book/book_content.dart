import 'book_widgets.dart';

/// Урок книжки «Деньги с Finzo».
class BookLesson {
  const BookLesson({
    required this.id,
    required this.title,
    required this.blurb,
    required this.pages,
    this.parkSpotId,
    this.skill,
  });

  final String id;
  final String title;
  final String blurb;
  final List<BookLessonPage> pages;
  /// Связанная игра — после урока, не вместо него.
  final String? parkSpotId;
  final String? skill;
}

class BookLessonPage {
  const BookLessonPage({
    required this.title,
    required this.kind,
    this.blocks = const [],
    this.scene = BookSceneKind.calm,
    this.exampleTitle,
    this.exampleLines = const [],
    this.actionPrompt,
    this.choices = const [],
    this.correctChoiceIds = const {},
    this.feedbackOk,
    this.feedbackBad,
  });

  final String title;
  final BookLessonKind kind;
  final List<String> blocks;
  final BookSceneKind scene;
  final String? exampleTitle;
  final List<String> exampleLines;
  final String? actionPrompt;
  final List<({String id, String label})> choices;
  final Set<String> correctChoiceIds;
  final String? feedbackOk;
  final String? feedbackBad;
}

enum BookLessonKind { explain, example, action, bridge }

abstract final class BookContent {
  static const coverTitle = 'Деньги с Finzo';
  static const coverSubtitle = 'Учимся планировать, копить и покупать';

  static const coverTips = <({String title, String text})>[
    (title: 'Планируем', text: 'Делим деньги на нужное, желания и копилку.'),
    (title: 'Копим', text: 'Маленькие взносы приближают мечту.'),
    (title: 'Покупаем', text: 'Сравниваем цены и проверяем чек.'),
  ];

  static final lessons = <BookLesson>[
    BookLesson(
      id: 'money_source',
      title: 'Откуда деньги',
      blurb: 'Карманные деньги, остаток и доступная сумма.',
      skill: 'Понимать доступный остаток',
      parkSpotId: 'practice_plan_change',
      pages: [
        BookLessonPage(
          title: 'Откуда деньги',
          kind: BookLessonKind.explain,
          scene: BookSceneKind.coins,
          blocks: [
            'Finzo получает учебные монеты на период — как карманные деньги.',
            'Доступная сумма — то, что можно потратить сейчас.',
            'Остаток — что осталось после покупок.',
          ],
        ),
        BookLessonPage(
          title: 'Пример',
          kind: BookLessonKind.example,
          scene: BookSceneKind.coins,
          exampleTitle: 'День 1',
          exampleLines: [
            'Получил: 100',
            'Потратил на еду: 40',
            'Доступно сейчас: 60',
          ],
        ),
        BookLessonPage(
          title: 'Попробуй',
          kind: BookLessonKind.action,
          scene: BookSceneKind.calm,
          actionPrompt: 'Что такое «доступная сумма»?',
          choices: [
            (id: 'a', label: 'Всё, что когда-либо получал Finzo'),
            (id: 'b', label: 'То, что можно потратить сейчас'),
            (id: 'c', label: 'Только деньги в копилке'),
          ],
          correctChoiceIds: {'b'},
          feedbackOk: 'Верно: доступно — то, что можно потратить сейчас.',
          feedbackBad: 'Доступная сумма — текущий остаток для трат, не вся история.',
        ),
        BookLessonPage(
          title: 'Практика с Finzo',
          kind: BookLessonKind.bridge,
          scene: BookSceneKind.calm,
          blocks: [
            'Практика «Изменились планы»: нужная трата и учебная копилка.',
          ],
        ),
      ],
    ),
    BookLesson(
      id: 'needs_wants',
      title: 'Нужное и желания',
      blurb: 'Еда и уход важнее развлечений; желание можно отложить.',
      skill: 'Различать нужное и желаемое',
      parkSpotId: 'practice_lunch',
      pages: [
        BookLessonPage(
          title: 'Нужное и желания',
          kind: BookLessonKind.explain,
          scene: BookSceneKind.plan,
          blocks: [
            'Нужное: еда, уход — без этого Finzo плохо себя чувствует.',
            'Желания: игрушки и развлечения — приятно, но можно позже.',
            'Отложить желание — не ошибка.',
          ],
        ),
        BookLessonPage(
          title: 'Пример',
          kind: BookLessonKind.example,
          scene: BookSceneKind.calm,
          exampleTitle: 'Выбор',
          exampleLines: [
            'Еда 40 — нужно',
            'Игрушка 30 — желание',
            'Если денег 50: сначала еда, игрушку — завтра',
          ],
        ),
        BookLessonPage(
          title: 'Попробуй',
          kind: BookLessonKind.action,
          scene: BookSceneKind.calm,
          actionPrompt: 'Что можно спокойно отложить?',
          choices: [
            (id: 'a', label: 'Еду на сегодня'),
            (id: 'b', label: 'Новую игрушку'),
            (id: 'c', label: 'Оплату дома'),
          ],
          correctChoiceIds: {'b'},
          feedbackOk: 'Да: желание можно перенести, нужное — нет.',
          feedbackBad: 'Еда и уход — нужное. Откладывают желания.',
        ),
        BookLessonPage(
          title: 'Практика с Finzo',
          kind: BookLessonKind.bridge,
          scene: BookSceneKind.calm,
          blocks: [
            'Практика «Собери обед»: нужное в бюджете и желания по остатку.',
          ],
        ),
      ],
    ),
    BookLesson(
      id: 'day_plan',
      title: 'План на день',
      blurb: 'Делим деньги: нужное, желания, копилка. План — ещё не покупка.',
      skill: 'Составлять простой план',
      parkSpotId: 'practice_day_plan',
      pages: [
        BookLessonPage(
          title: 'План на день',
          kind: BookLessonKind.explain,
          scene: BookSceneKind.plan,
          blocks: [
            'План показывает, куда пойдут монеты: нужное, желания, копилка.',
            'Пока план только на бумаге — покупки ещё не случились.',
            'Потом сверим план с фактом.',
          ],
        ),
        BookLessonPage(
          title: 'Пример',
          kind: BookLessonKind.example,
          scene: BookSceneKind.calm,
          exampleTitle: 'Есть 100',
          exampleLines: [
            'Нужное: 50',
            'Желания: 20',
            'Копилка: 30',
            'Итого план: 100',
          ],
        ),
        BookLessonPage(
          title: 'Попробуй',
          kind: BookLessonKind.action,
          scene: BookSceneKind.calm,
          actionPrompt: 'План уже списал деньги с баланса?',
          choices: [
            (id: 'a', label: 'Да, сразу'),
            (id: 'b', label: 'Нет, покупка будет отдельно'),
          ],
          correctChoiceIds: {'b'},
          feedbackOk: 'Верно: план — договор с собой, не покупка.',
          feedbackBad: 'Деньги списываются при покупке, не при плане.',
        ),
        BookLessonPage(
          title: 'Практика с Finzo',
          kind: BookLessonKind.bridge,
          scene: BookSceneKind.prize,
          blocks: [
            'Практика «План на день»: разложи учебные монеты без списания баланса.',
          ],
        ),
      ],
    ),
    BookLesson(
      id: 'savings',
      title: 'Копим на мечту',
      blurb: 'Цена цели, накоплено, осталось; маленькие взносы.',
      skill: 'Копить регулярными взносами',
      parkSpotId: 'practice_dream_save',
      pages: [
        BookLessonPage(
          title: 'Копим на мечту',
          kind: BookLessonKind.explain,
          scene: BookSceneKind.prize,
          blocks: [
            'У цели есть цена. Смотри: накоплено и сколько осталось.',
            'Лучше откладывать понемногу каждый день.',
            'Потратить всё на украшение — цель отодвинется.',
          ],
        ),
        BookLessonPage(
          title: 'Пример',
          kind: BookLessonKind.example,
          scene: BookSceneKind.prize,
          exampleTitle: 'Наушники 90',
          exampleLines: [
            'Уже в копилке: 30',
            'Осталось: 60',
            'Взнос сегодня: 20 → останется 40',
          ],
        ),
        BookLessonPage(
          title: 'Попробуй',
          kind: BookLessonKind.action,
          scene: BookSceneKind.prize,
          actionPrompt: 'Цель 90, накоплено 50. Сколько ещё нужно?',
          choices: [
            (id: 'a', label: '50'),
            (id: 'b', label: '40'),
            (id: 'c', label: '90'),
          ],
          correctChoiceIds: {'b'},
          feedbackOk: '90 − 50 = 40. Верно!',
          feedbackBad: 'Осталось = цена цели минус накоплено.',
        ),
        BookLessonPage(
          title: 'Практика с Finzo',
          kind: BookLessonKind.bridge,
          scene: BookSceneKind.prize,
          blocks: [
            'Практика «Копим на мечту»: несколько учебных дней и взносы.',
          ],
        ),
      ],
    ),
    BookLesson(
      id: 'smart_buy',
      title: 'Покупаем внимательно',
      blurb: 'Сравнение наборов, итог, оплата и проверка чека.',
      skill: 'Сравнивать цены и проверять чек',
      parkSpotId: 'practice_deal',
      pages: [
        BookLessonPage(
          title: 'Покупаем внимательно',
          kind: BookLessonKind.explain,
          scene: BookSceneKind.order,
          blocks: [
            'Одинаковый набор может стоить по-разному у двух продавцов.',
            'Сложи цены предметов и сравни с готовым набором.',
            'Перед оплатой проверь чек: нет ли лишней строки.',
          ],
        ),
        BookLessonPage(
          title: 'Пример',
          kind: BookLessonKind.example,
          scene: BookSceneKind.order,
          exampleTitle: 'Ракетка + 2 мяча',
          exampleLines: [
            'По отдельности: 55 + 15 + 15 = 85',
            'Набор: 80',
            'Выгоднее набор — экономия 5',
          ],
        ),
        BookLessonPage(
          title: 'Попробуй',
          kind: BookLessonKind.action,
          scene: BookSceneKind.order,
          actionPrompt: 'В чеке лишние чипсы, которых не брал. Что делать?',
          choices: [
            (id: 'a', label: 'Оплатить как есть'),
            (id: 'b', label: 'Убрать лишнюю строку и пересчитать'),
          ],
          correctChoiceIds: {'b'},
          feedbackOk: 'Да: сначала исправь чек, потом плати.',
          feedbackBad: 'Лишнюю строку нужно убрать до оплаты.',
        ),
        BookLessonPage(
          title: 'Практика с Finzo',
          kind: BookLessonKind.bridge,
          scene: BookSceneKind.order,
          blocks: [
            'Практика «Выгодная покупка»: сравни два магазина по числам.',
          ],
        ),
      ],
    ),
    BookLesson(
      id: 'safety',
      title: 'Безопасность',
      blurb: 'Код, сомнительная ссылка, спешка — к взрослому.',
      skill: 'Не передавать секреты незнакомцам',
      parkSpotId: 'practice_receipt',
      pages: [
        BookLessonPage(
          title: 'Безопасность',
          kind: BookLessonKind.explain,
          scene: BookSceneKind.compareMessages,
          blocks: [
            'Код из SMS — только для тебя.',
            'Ссылка «срочно отмени заказ» часто бывает подделкой.',
            'Если торопят — остановись и покажи взрослому.',
          ],
        ),
        BookLessonPage(
          title: 'Пример',
          kind: BookLessonKind.example,
          scene: BookSceneKind.alert,
          exampleTitle: 'Сообщение',
          exampleLines: [
            '«Пришлите код, иначе заказ отменят»',
            'Признаки: просят код + спешка',
            'Действие: не слать, показать взрослому',
          ],
        ),
        BookLessonPage(
          title: 'Попробуй',
          kind: BookLessonKind.action,
          scene: BookSceneKind.phoneLock,
          actionPrompt: 'Просят код из SMS «от магазина». Что безопасно?',
          choices: [
            (id: 'a', label: 'Отправить код'),
            (id: 'b', label: 'Не передавать код'),
            (id: 'c', label: 'Показать взрослому'),
          ],
          correctChoiceIds: {'b', 'c'},
          feedbackOk: 'Верно: код не отправляем; взрослый поможет проверить.',
          feedbackBad: 'Код никому не отправляют. Можно закрыть или спросить взрослого.',
        ),
        BookLessonPage(
          title: 'Практика внимательности',
          kind: BookLessonKind.bridge,
          scene: BookSceneKind.inspectMessage,
          blocks: [
            'Практика «Проверь чек»: убери лишнее и оплати учебными монетами.',
          ],
        ),
      ],
    ),
    BookLesson(
      id: 'day_review',
      title: 'Как прошёл день',
      blurb: 'План и факт, остаток, что исправить завтра.',
      skill: 'Сравнивать план с фактом',
      pages: [
        BookLessonPage(
          title: 'Как прошёл день',
          kind: BookLessonKind.explain,
          scene: BookSceneKind.calm,
          blocks: [
            'В конце дня сравниваем план и факт.',
            'Смотрим остаток и что ушло в копилку.',
            'Ошибку можно поправить в следующем периоде.',
          ],
        ),
        BookLessonPage(
          title: 'Пример',
          kind: BookLessonKind.example,
          scene: BookSceneKind.calm,
          exampleTitle: 'План vs факт',
          exampleLines: [
            'План: нужное 50, желания 20, копилка 30',
            'Факт: нужное 50, желания 40, копилка 10',
            'Завтра: меньше желаний, больше в копилку',
          ],
        ),
        BookLessonPage(
          title: 'Попробуй',
          kind: BookLessonKind.action,
          scene: BookSceneKind.calm,
          actionPrompt: 'Факт не совпал с планом. Что делать?',
          choices: [
            (id: 'a', label: 'Стереть весь прогресс'),
            (id: 'b', label: 'Заметить разницу и поправить завтра'),
          ],
          correctChoiceIds: {'b'},
          feedbackOk: 'Да: учимся на факте, без обнуления всего.',
          feedbackBad: 'Прогресс не сбрасывают — корректируют следующий план.',
        ),
      ],
    ),
  ];

  static List<BookTocItem> get toc => [
        for (final l in lessons)
          BookTocItem(
            id: l.id,
            title: l.title,
            blurb: l.blurb,
            parkSpotId: l.parkSpotId,
          ),
      ];

  /// Обложка + все страницы уроков + оглавление.
  static int get flatPageCount =>
      1 + lessons.fold<int>(0, (s, l) => s + l.pages.length) + 1;
}

class BookTocItem {
  const BookTocItem({
    required this.id,
    required this.title,
    required this.blurb,
    this.parkSpotId,
  });
  final String id;
  final String title;
  final String blurb;
  final String? parkSpotId;
}
