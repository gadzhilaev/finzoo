import 'package:flutter/material.dart';

import '../../../../core/theme/app_fonts.dart';

/// Подсказки «нужное / желания / копилка» — можно открыть в любой момент.
Future<void> showMoneyTipsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFEFCF4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B6943).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Три вида решений',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: const Color(0xFF1B6943),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Открой снова, если забыл — это не только при старте.',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: const Color(0xFF4A4643),
                ),
              ),
              const SizedBox(height: 14),
              const _TipCard(
                number: '1',
                title: 'Нужное',
                text:
                    'Еда, уход, то без чего день не обойтись. Сначала закрываем это.',
                color: Color(0xFF1B6943),
              ),
              const SizedBox(height: 8),
              const _TipCard(
                number: '2',
                title: 'Желания',
                text:
                    'Игрушки, наряды и «хочу». Можно, если нужное уже в плане.',
                color: Color(0xFFDF9548),
              ),
              const SizedBox(height: 8),
              const _TipCard(
                number: '3',
                title: 'Копилка',
                text:
                    'Откладываем на цель. Чем регулярнее — тем быстрее мечта.',
                color: Color(0xFF4B946A),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4B946A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Понятно',
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.number,
    required this.title,
    required this.text,
    required this.color,
  });

  final String number;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(
              number,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.3,
                    color: const Color(0xFF4A4643),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
