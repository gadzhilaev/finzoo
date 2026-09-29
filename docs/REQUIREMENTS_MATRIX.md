# Матрица соответствия ТЗ (актуализация после фиксов)

Источник ТЗ: `tz/TZ-Finny-hackathon.pdf` / `tz/TZ-extract.txt`.  
Статусы: DONE | PARTIAL | NOT DONE | WRONG | UNCLEAR | N/A (граница MVP).

## §2.5

| ID | Требование | Статус | Доказательство |
|----|------------|--------|----------------|
| 2.5.1 intro + 3 типа | DONE | OnboardingTutorial + MoneyTips |
| 2.5.1 гостевой профиль | DONE | name/age/pet локально |
| 2.5.1 подсказка всегда | DONE | MoneyTips с улицы/бюджета |
| 2.5.2 внешность | DONE | 9 starterLooks |
| 2.5.2 имя питомца | DONE | PetSetupPage |
| 2.5.3 главный экран | DONE | StreetPage hub |
| 2.5.3 доступы разделов | DONE | welcome callbacks |
| 2.5.4 валюта + доход | DONE | EconomyRules 420 + label |
| 2.5.4 награда заданий | DONE | taskReward 20 once |
| 2.5.5 план ≥3 | DONE | BudgetPlanPage |
| 2.5.6 покупки | DONE | ShopCatalog + house |
| 2.5.7 цели/копилка | DONE | GoalsPage + SavingsDialog |
| 2.5.8 ≥6 / 3 темы | DONE | PracticeCatalog |
| 2.5.8 не только MCQ | PARTIAL | Practice интерактивны; FinancialTask MCQ orphan |
| 2.5.9 обратная связь | DONE | диалоги / results / practice |
| 2.5.10 ≥3 стадии | DONE | PetGrowthStage |
| 2.5.11 история | DONE | day history + adult + results |
| 2.5.11 справочник | UNCLEAR | MoneyTips — см. CONTENT_MAP |
| 2.5.12 adult gate | DONE | FinzoAdultGate 8+7 |
| 2.5.12 прогресс без негатива | DONE | AdultPage, счётчик BookContent.flatPageCount |
| 2.5.13 persistence | DONE | SharedPreferences |
| 2.5.13 демо/сброс | DONE | loadDemoProfile / resetProfile |
| 2.5.14 расширяемость | DONE | PracticeCatalog / BookContent |

## §2.6 минимум

| Элемент | Минимум | Факт | Статус |
|---------|---------|------|--------|
| Внешность | ≥9 | 9 | DONE |
| Периоды демо | ≥5 | demo day 5 | DONE |
| Задания | ≥6 / 3 темы | 6 | DONE |
| Покупки | ≥8 / 2 типа | 20 | DONE |
| Цели | ≥3 | 6 | DONE |
| Стадии | ≥3 | 3 | DONE |

## Приложение А

| Шаг | Статус | Комментарий |
|-----|--------|-------------|
| 1–5 | DONE | онбординг, бюджет |
| 6 | DONE | практика + объяснение + валюта (+20 first) |
| 7–8 | DONE | покупки, цели |
| 9–10 | DONE | results, next period, growth |
| 11 | DONE | prefs persist |
| 12 | DONE | adult reset/demo |

## §3.6 звук/анимации

| Требование | Статус |
|------------|--------|
| Анимации отключаются | DONE (TickerMode + BG/облака/переходы) |
| Звуки отключаются | PARTIAL: toggle persist; SFX нет (ТЗ не требует наличие аудио) |
| Критичное не только звуком | DONE |

## Сдача §5 / §3.3

| Пункт | Статус |
|-------|--------|
| README | DONE |
| Матрица / формулы / контент / лицензии | DONE (docs/) |
| §5 п.8 UX/a11y | DONE (`docs/UX_ACCESSIBILITY.md`) |
| §5 п.11 ограничения/план | DONE (`docs/LIMITATIONS.md`) |
| §5 отдельный DOCX | DONE (`docs/FINZO_SUBMISSION.docx`) |
| §4 презентация PPTX/PDF | DONE (`docs/presentation/Finzo_presentation.pptx` + `.pdf`) |
| RuStore черновик локально | DONE (docs/rustore/) |
| Загрузка в консоль RuStore | NOT DONE (нет доступа) |
| Физ. Android отчёт с фактом | NOT DONE (шаблон + чеклист готовы) |
| Видео ≤3 мин (файл) | NOT DONE |

## Продуктовые UNCLEAR

1. MoneyTips = §2.5.11?  
2. FinancialTaskPage обязателен отдельно от Practice?  
3. Бренд Финни vs Finzo.
