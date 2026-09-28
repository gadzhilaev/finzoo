import 'package:flutter/material.dart';

import '../../../../core/profile/game_controller.dart';
import '../../../../core/theme/app_fonts.dart';

/// История операций текущего профиля — для ребёнка, не только взрослый раздел.
Future<void> showDayHistorySheet(
  BuildContext context,
  GameController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFFEFCF4),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * 0.62,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final items = controller.profile.transactionHistory;
              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B6943).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Что уже сделали',
                      textAlign: TextAlign.center,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: const Color(0xFF1B6943),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Покупки, копилка и уход за Finzo',
                      textAlign: TextAlign.center,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: const Color(0xFF4A4643),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: items.isEmpty
                          ? Center(
                              child: Text(
                                'Пока пусто — купи что-нибудь или отложи в копилку.',
                                textAlign: TextAlign.center,
                                style: AppFonts.rubik(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: const Color(0xFF4A4643),
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: items.length.clamp(0, 24),
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final text = items[i];
                                return Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    12,
                                    12,
                                    12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFF1B6943)
                                          .withValues(alpha: 0.28),
                                    ),
                                  ),
                                  child: Text(
                                    text,
                                    style: AppFonts.rubik(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      height: 1.3,
                                      color: const Color(0xFF4A4643),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
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
                          'Закрыть',
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
              );
            },
          ),
        ),
      );
    },
  );
}
