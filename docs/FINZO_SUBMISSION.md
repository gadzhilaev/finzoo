# Finzo — сопроводительный документ сдачи

Отдельный документ по §5 ТЗ (формат DOCX/PDF). Источники: README, `docs/*`, код.  
**Физическое тестирование на Android — ожидает прогона** (см. раздел 11 и `ANDROID_PHYSICAL_CHECKLIST.md`).

Версия приложения: `1.0.0+1` · Package: `ru.gadzhilaev.finzo`

---

## 1. Finzo

Мобильный прототип финансовой грамотности для детей. Продуктовое имя **Finzo**; конкурсное ТЗ — «Питомец Финни».

## 2. Назначение проекта

Научить ребёнка 7–11 лет принимать простые финансовые решения в игровом дне: отличать необходимое, желания и накопление; видеть последствия для баланса и питомца; закрепить безопасность (книжка).

## 3. Целевая аудитория

- Основная: дети **7–11** лет.  
- Взрослый: локальный раздел за gate (пример `8+7`) — прогресс, настройки, демо, сброс.

## 4. Основной пользовательский сценарий

Онбординг → туториал (3 типа решений) → цель → бюджет → hub (улица) → покупки / практика / копилка → итоги периода → рост → следующий день.  
Параллельно: книжка 1–6, Adult.  
Подробнее: `docs/UX_ACCESSIBILITY.md` §1.

## 5. Реализованные механики

| Механика | Реализация |
|----------|------------|
| 3 типа решений | туториал + MoneyTips |
| Бюджет дня | necessary / wants / savings |
| Покупки | кухня/душ (нужное), одежда (желания) |
| Цели + копилка | GoalsPage, SavingsDialog |
| Практика ×6 / 3 темы | PracticeCatalog |
| Книжка безопасности | BookPage 1–6 |
| Рост ≥3 стадии | growthPoints → PetGrowthStage |
| Adult | gate, демо, сброс, toggles |
| Persistence | SharedPreferences |

## 6. Архитектура

- Flutter / Dart, feature-first: `lib/features/*`, ядро `lib/core/profile` (economy, rules, GameController, store).  
- UI без сервера; контент в каталогах (Practice, Shop, Goals, BookContent).  
- Схема обновления контента: правка каталогов / ассетов без смены движка экономики.

## 7. Хранение данных

- Ключ: `finzoo_player_profile_v1`.  
- Профиль, балансы, план, цель, инвентарь, practice IDs, growth, `animationsEnabled` / `soundsEnabled`.  
- Разрешения Android: без лишних `uses-permission` под сбор ПДн.  
- Удаление: Adult → сброс профиля (confirm).

## 8. Экономика

Источник: `EconomyRules` / `docs/ECONOMY.md`.

| Параметр | Значение |
|----------|----------|
| Доход периода | **420** («Карманные от родителей») |
| Награда практики | **+20** один раз на `practice_*` id |
| Учебные монеты в задании | не списывают «Доступно» |

## 9. Контент и задания

См. `docs/CONTENT_MAP.md`: Practice ×6, Book ×6, Growth Guide, MoneyTips.  
FinancialTaskPage — legacy UI_SHOT, не основной flow.

## 10. UX и accessibility

См. `docs/UX_ACCESSIBILITY.md`: 48 dp hit targets (`FinzoHitTarget`), body книжки 16 sp, не только цвет, отключение анимаций, confirm на сброс/снятие, без критичного «только звуком».

## 11. Тестирование

### Автотесты (локально)

```
flutter analyze   # clean
flutter test      # завершается сам; screenshot-тесты через runAsync helper
```

### Физическое тестирование — ожидает прогона

Шаблон: `docs/ANDROID_TEST_REPORT.md`.  
Пошаговый чеклист одного прогона: `docs/ANDROID_PHYSICAL_CHECKLIST.md`  
(REQ-H-003, A-005, A-006, A-007 physical, P-003, DOC-10).

**Не утверждается**, что физический прогон уже выполнен.

## 12. Сборка и запуск

```bash
flutter pub get
flutter run
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

Подпись: ключи вне git (private). Окружение: Flutter 3.44.x, SDK `^3.12.2`.

## 13. Demo / reset

Adult (Messages → взрослый **или** long-press имени) → `8+7`:

- Демо-профиль — `loadDemoProfile`  
- Сброс — confirm → clear prefs + fresh

## 14. Ограничения

См. `docs/LIMITATIONS.md`. Кратко: только local prefs; нет backend/банка/remote parental; SFX нет; физ. метрики и видеозапись — pending.

## 15. Лицензии

См. `docs/LICENSES.md` (пакеты, Rubik OFL, графика проекта/макеты заказчика).

## 16. Соответствие требованиям

Матрица: `docs/REQUIREMENTS_MATRIX.md` (сверкать с актуальной реализацией).  
Черновик RuStore: `docs/rustore/`.  
Презентация: `docs/presentation/Finzo_presentation.pptx` (§4 п.1–9).  
Видеосценарий: `docs/VIDEO_SCENARIO.md` (файл ролика — отдельно).

Открытые позиции сдачи (не закрыты этим документом): физ. Android, cold start/response факты, live demo, видеофайл, GitHub access, release tag, продуктовое решение по звуку (U-007b).
