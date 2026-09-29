# Чеклист физического Android-прогона

Закрывает одним прогоном: **REQ-H-003**, **REQ-A-005**, **REQ-A-006**, **REQ-A-007 (physical)**, **REQ-P-003**, **REQ-DOC-10**.

Факт прогона сюда **не подставлять заранее**. После устройства — скопировать результаты также в `ANDROID_TEST_REPORT.md`.

APK: `build/app/outputs/flutter-apk/app-release.apk`  
Package: `ru.gadzhilaev.finzo` · Version: `1.0.0+1`

---

## DEVICE

| Поле | Значение |
|------|----------|
| DEVICE (модель) | |
| Android version (≥8.0) | |
| RAM (≥3 ГБ) | |
| screen resolution | |
| Дата / исполнитель | |

---

## INSTALL

| Проверка | PASS/FAIL | Комментарий |
|----------|-----------|-------------|
| APK installs | | |
| first launch (splash→welcome без crash) | | |

---

## COLD START (REQ-A-005, цель ≤5 с)

Замер: от tap иконки до первого интерактивного UI (Welcome или Restore).

| Прогон | Секунды |
|--------|---------|
| run 1 | |
| run 2 | |
| run 3 | |
| **average** | |

Результат vs ≤5 с: PASS / FAIL

---

## INTERACTION RESPONSE (REQ-A-006, цель ≤1 с)

| action | measurement (как меряли) | result (с) | PASS/FAIL |
|--------|--------------------------|------------|-----------|
| Tap «Бюджет» с улицы → экран плана | | | |
| Подтверждение плана бюджета | | | |
| Открытие Practice / старт задания | | | |
| Покупка в доме (диалог) | | | |
| Переход «итоги периода» | | | |

---

## FULL FLOW (PASS/FAIL + комментарий)

| Шаг | PASS/FAIL | Комментарий |
|-----|-----------|-------------|
| onboarding (возраст→имя→питомец→туториал→цель) | | |
| profile создан локально | | |
| hub (Street) читается: баланс/цель/статы | | |
| income 420 виден / выдан | | ожидать «Карманные от родителей» |
| budget 3 направления | | |
| shop: нужное + желание | | |
| goal выбрана | | |
| savings: перевод в копилку | | |
| practice ≥1 задание + объяснение | | +20 только first id |
| period result | | |
| growth / стадии понятны | | |
| book 1–6 листается | | |
| adult gate 8+7 | | |
| settings: анимации toggle | | |
| restart app → persistence | | полный kill, не только background |
| demo profile | | |
| reset profile (с confirm) | | |

---

## STABILITY

| Проверка | PASS/FAIL | Комментарий |
|----------|-----------|-------------|
| Нет crash в сценарии выше | | |
| Нет ANR | | |
| Нет явного overflow / clipped critical CTA | | |
| Persistence после полного закрытия | | баланс/план/цель на месте |

---

## LIVE DEMO (REQ-P-003)

Показаны шаги Приложения А (столбец «Демонстрация»): PASS / FAIL  
Устройство то же: ____  
Заметки: ____

---

## Автотесты на машине сборки (до устройства)

```
flutter analyze   → 
flutter test      →   (ожидается: завершается сам, failed=0)
```

Дата прогона автотестов: ____
