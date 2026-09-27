#!/usr/bin/env bash
# Сборка ZIP исходников + документов без секретов / зависимостей / build.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="${ROOT}/build/handoff"
STAMP="$(date +%Y%m%d-%H%M)"
NAME="finzoo-park-book-${STAMP}"
STAGE="${OUT_DIR}/${NAME}"
ZIP="${OUT_DIR}/${NAME}.zip"

rm -rf "${STAGE}"
mkdir -p "${STAGE}"

# Копируем исходники выборочно
rsync -a \
  --exclude '.git' \
  --exclude '.dart_tool' \
  --exclude 'build' \
  --exclude '.idea' \
  --exclude '.vscode' \
  --exclude 'ios/Pods' \
  --exclude 'ios/.symlinks' \
  --exclude 'ios/Flutter/ephemeral' \
  --exclude 'ios/Flutter/Flutter.podspec' \
  --exclude 'android/.gradle' \
  --exclude 'android/local.properties' \
  --exclude 'android/app/key.properties' \
  --exclude '**/key.properties' \
  --exclude '**/*.jks' \
  --exclude '**/*.keystore' \
  --exclude '**/.env*' \
  --exclude '**/secrets*' \
  --exclude 'macos/Flutter/ephemeral' \
  --exclude 'linux/flutter/ephemeral' \
  --exclude 'windows/flutter/ephemeral' \
  --exclude '.cursor' \
  "${ROOT}/" "${STAGE}/project/"

# Документы ТЗ
mkdir -p "${STAGE}/docs"
cp -f "${ROOT}/tz/REQUIREMENTS_STATUS.md" "${STAGE}/docs/"
cp -f "${ROOT}/tz/NEXT_STEPS.md" "${STAGE}/docs/" 2>/dev/null || true
cp -f "${ROOT}/tz/PROJECT_HANDOFF.md" "${STAGE}/docs/" 2>/dev/null || true
cp -f "${ROOT}/tz/TZ-extract.txt" "${STAGE}/docs/" 2>/dev/null || true
cp -f "${ROOT}/README.md" "${STAGE}/docs/" 2>/dev/null || true

# Скриншоты парка/книжки
mkdir -p "${STAGE}/screenshots"
cp -f "${ROOT}/build/ui_shots"/sim_park_map.png "${STAGE}/screenshots/" 2>/dev/null || true
cp -f "${ROOT}/build/ui_shots"/sim_mech_*.png "${STAGE}/screenshots/" 2>/dev/null || true
cp -f "${ROOT}/build/ui_shots"/sim_book_*.png "${STAGE}/screenshots/" 2>/dev/null || true

# Краткий отчёт
cat > "${STAGE}/REPORT.md" <<'EOF'
# Finzoo — отчёт (парк + книжка)

## Сделано
- Карта парка: убраны цифры «10» и бейджи цены из SVG; подписи Велозаезд/Музыка/Игровой клуб/Лодка/Теннис/Рыбалка; hit-зоны привязаны к объектам; сцена масштабируется через SvgScenePage 393×852.
- 6 мини-игр на учебные монеты (стабильные ID `park_*`), без влияния на основной баланс и без денежных наград.
- Книжка: обложка с лупой, оглавление (бюджет / необходимое и желаемое / копилка / безопасные покупки → мини-игры), 3 сценария мошенников.
- Матрица ТЗ обновлена по коду: `docs/REQUIREMENTS_STATUS.md`.

## Пробелы (не готово)
- 9 вариантов внешности и отдельное имя питомца
- 3 стадии роста
- Раздел взрослого, удаление/сброс
- Явный демо-профиль «5 дней»
- История решений периода
- Переключатели звука/анимаций
- Android-проверка, релизная сборка, полный пакет сдачи

## Скриншоты
См. папку `screenshots/`.
EOF

cd "${OUT_DIR}"
rm -f "${ZIP}"
# Без AppleDouble / __MACOSX
COPYFILE_DISABLE=1 zip -r -q "${NAME}.zip" "${NAME}" \
  -x "*.DS_Store" -x "*__MACOSX*" -x "*.env" -x "*ephemeral*"
echo "ZIP=${ZIP}"
ls -lh "${ZIP}"
