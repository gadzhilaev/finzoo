import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/assets/app_assets.dart';
import '../../../../core/theme/app_fonts.dart';
import '../book/book_widgets.dart';

/// Подсказки «нужное / желания / копилка» — стиль книжки «обучение».
Future<void> showMoneyTipsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: BookStyle.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                  color: BookStyle.green.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              SvgPicture.asset(
                AppAssets.logoIntro,
                width: 110,
                height: 32,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 10),
              Text(
                'Три вида решений',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: BookStyle.green,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Открой снова, если забыл — это не только при старте.',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: BookStyle.body,
                ),
              ),
              const SizedBox(height: 14),
              const BookTipGroup(
                items: [
                  (title: 'Нужное', text: 'еда и уход — сначала это'),
                  (title: 'Желания', text: 'игрушки и наряды, если нужное в плане'),
                  (title: 'Копилка', text: 'откладываем на цель регулярно'),
                ],
              ),
              const SizedBox(height: 16),
              BookPrimaryButton(
                label: 'Понятно',
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      );
    },
  );
}
