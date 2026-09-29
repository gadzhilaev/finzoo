abstract final class AppAssets {
  static const String logo = 'assets/images/logo.svg';
  static const String logo2 = 'assets/images/logo2.svg';

  /// Мордочка белки + Finzo — как на ознакомительных экранах.
  static const String logoIntro = 'assets/images/logo_intro.svg';
  static const String squirrel = 'assets/images/squirrel.svg';
  static const String squirrel2 = 'assets/images/squirrel2.svg';
  static const String play = 'assets/images/play.svg';
  static const String playBlob = 'assets/images/play_blob.svg';
  static const String playTriangle = 'assets/images/play_triangle.svg';
  static const String strelka = 'assets/images/strelka.svg';
  static const String introOutroVideo = 'assets/videos/intro_outro.mp4';

  /// Картинки целей накопления — заменяй файлы в `assets/images/goals/`.
  static const String goalBicycle = 'assets/images/goals/bicycle.png';
  static const String goalHeadphones = 'assets/images/goals/headphones.png';
  static const String goalPlaystation = 'assets/images/goals/playstation.png';
  static const String goalBoat = 'assets/images/goals/boat.png';
  static const String goalTennis = 'assets/images/goals/tennis.png';
  static const String goalFishing = 'assets/images/goals/fishing.png';
  static const String goalsCard = 'assets/images/goals_card.svg';
  static const String goalsCardSelected =
      'assets/images/goals_card_selected.svg';
  static const String okButton = 'assets/images/ok_button.svg';
  static const String street = 'assets/images/street.svg';
  static const String streetCloudLeft = 'assets/images/street_cloud_left.svg';
  static const String streetCloudRight = 'assets/images/street_cloud_right.svg';
  static const String streetLogo = 'assets/images/street_logo.svg';
  static const String streetFlame = 'assets/images/street_flame.svg';
  static const String house = 'assets/images/house.svg';
  static const String houseAvailable = 'assets/images/house_available.svg';
  static const String houseSaved = 'assets/images/house_saved.svg';
  static const String houseClothes = 'assets/images/house_clothes.svg';
  static const String houseShower = 'assets/images/house_shower.svg';
  static const String book = 'assets/images/book.svg';
  static const String bookArrowRight =
      'assets/images/book_icons/book_arrow_right.svg';
  static const String games = 'assets/images/games.svg';
  static const String gamesBg = 'assets/images/games_bg.png';
  static const String messages = 'assets/images/messages.svg';
  static const String rubleMark = 'assets/images/ruble_mark.svg';

  static const String iconAdult = 'assets/images/finzo_icons/adult.svg';
  static const String iconAnimation = 'assets/images/finzo_icons/animation.svg';
  static const String iconSound = 'assets/images/finzo_icons/sound.svg';
  static const String iconDemo = 'assets/images/finzo_icons/demo.svg';
  static const String iconReset = 'assets/images/finzo_icons/reset.svg';

  /// Слоты инвентаря на экране дома (из `Дом.svg`).
  static const List<String> houseInventory = [
    'assets/images/house_inv/item_0.png',
    'assets/images/house_inv/item_1.png',
    'assets/images/house_inv/item_2.png',
    'assets/images/house_inv/item_3.png',
    'assets/images/house_inv/item_4.png',
    'assets/images/house_inv/item_5.png',
    'assets/images/house_inv/item_6.png',
    'assets/images/house_inv/item_7.png',
  ];

  /// Одежда — из `ОДЕЖДА.svg`.
  static const List<String> houseClothesInventory = [
    'assets/images/house_inv_clothes/item_0.png',
    'assets/images/house_inv_clothes/item_1.png',
    'assets/images/house_inv_clothes/item_2.png',
    'assets/images/house_inv_clothes/item_3.png',
    'assets/images/house_inv_clothes/item_4.png',
    'assets/images/house_inv_clothes/item_5.png',
    'assets/images/house_inv_clothes/item_6.png',
    'assets/images/house_inv_clothes/item_7.png',
  ];

  /// Душ — из `Душ.svg` (4 слота).
  static const List<String> houseShowerInventory = [
    'assets/images/house_inv_shower/item_0.png',
    'assets/images/house_inv_shower/item_1.png',
    'assets/images/house_inv_shower/item_2.png',
    'assets/images/house_inv_shower/item_3.png',
  ];

  /// Урок «Безопасность» в основной книжке: PNG из `обучение.zip`
  /// (растр 3× — flutter_svg ломает pattern/embedded image в SVG).
  /// Исходные PNG из макета (с status bar / nav / digit) — не для runtime.
  static const String bookSafety01Raw =
      'assets/book/safety/png/book_page_01.png';
  static const String bookSafety02Raw =
      'assets/book/safety/png/book_page_02.png';
  static const String bookSafety03Raw =
      'assets/book/safety/png/book_page_03.png';
  static const String bookSafety04Raw =
      'assets/book/safety/png/book_page_04.png';
  static const String bookSafety05Raw =
      'assets/book/safety/png/book_page_05.png';
  static const String bookSafety06Raw =
      'assets/book/safety/png/book_page_06.png';

  /// Runtime: без mock status bar, без nav SVG, без одиночного номера.
  static const String bookSafety01 = 'assets/book/runtime/book_page_01.png';
  static const String bookSafety02 = 'assets/book/runtime/book_page_02.png';
  static const String bookSafety03 = 'assets/book/runtime/book_page_03.png';
  static const String bookSafety04 = 'assets/book/runtime/book_page_04.png';
  static const String bookSafety05 = 'assets/book/runtime/book_page_05.png';
  static const String bookSafety06 = 'assets/book/runtime/book_page_06.png';

  static const List<String> bookSafetyPages = [
    bookSafety01,
    bookSafety02,
    bookSafety03,
    bookSafety04,
    bookSafety05,
    bookSafety06,
  ];

  /// Исходные SVG дизайнера (рядом с PNG).
  static const List<String> bookSafetySvgSources = [
    'assets/book/safety/book_page_01.svg',
    'assets/book/safety/book_page_02.svg',
    'assets/book/safety/book_page_03.svg',
    'assets/book/safety/book_page_04.svg',
    'assets/book/safety/book_page_05.svg',
    'assets/book/safety/book_page_06.svg',
  ];
}
