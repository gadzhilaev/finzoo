# Лицензии и права на использование

## Пакеты Flutter (pubspec)

| Пакет | Назначение | Лицензия (типичная) |
|-------|------------|---------------------|
| flutter / flutter_test | SDK | BSD-3 (Flutter) |
| flutter_svg | SVG | MIT |
| google_fonts | шрифты (Rubik также bundled) | Apache-2.0 |
| shared_preferences | prefs | BSD-3 |
| video_player | outro video | BSD-3 |
| flutter_lints / flutter_native_splash / flutter_launcher_icons | tool | BSD/MIT |

Точные тексты: `flutter pub deps` / страницы пакетов на pub.dev.

## Шрифты

- `assets/fonts/Rubik-*.ttf` — семейство Rubik (SIL Open Font License 1.1). Убедиться, что OFL соблюдён при публикации.

## Графика и видео

| Ассет | Источник | Право |
|-------|----------|--------|
| UI / белка / дом / улица / цели | оригинальные макеты проекта Finzo | команда / заказчик макетов |
| `assets/book/designer/*`, `safety/*` | макеты `обучение/` | дизайн заказчика хакатона |
| `assets/book/runtime/*` | генерация из SOURCE (`tool/build_book_runtime_pngs.py`) | производные от макетов |
| `assets/videos/intro_outro.mp4` | проектный ролик | команда / заказчик |
| Иконка приложения | `assets/images/app_icon.png` | команда |

Перед RuStore: подтвердить письменное право на распространение всех изображений/видео/шрифтов в составе прототипа (§3.3 ТЗ).

## Секреты

Ключи подписи Android **не** в git. См. private `Documents/private/finzoo/`.
