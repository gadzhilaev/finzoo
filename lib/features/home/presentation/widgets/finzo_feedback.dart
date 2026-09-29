import 'package:flutter/material.dart';

import '../../../../core/theme/app_fonts.dart';

/// Компактная заметка о состоянии Finzo (не модальный диалог).
///
/// Формат одной фразы: что изменилось + причина/действие ребёнка.
void showFinzoStateNote(
  BuildContext context, {
  required String message,
  IconData icon = Icons.pets_rounded,
  Color accent = const Color(0xFF1B6943),
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      duration: const Duration(milliseconds: 3200),
      backgroundColor: const Color(0xFFFEF7E6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: accent, width: 1.5),
      ),
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppFonts.rubik(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                height: 1.3,
                color: const Color(0xFF4A4643),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Единый фидбек: что случилось → почему → что дальше.
Future<void> showFinzoFeedback(
  BuildContext context, {
  required String title,
  required String what,
  required String why,
  required String next,
  String confirmLabel = 'Понятно',
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (ctx) {
      return Dialog(
        backgroundColor: const Color(0xFFFEF7E6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF1B6943), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: const Color(0xFF1B6943),
                ),
              ),
              const SizedBox(height: 14),
              _FeedbackBlock(label: 'Что изменилось', text: what),
              const SizedBox(height: 8),
              _FeedbackBlock(label: 'Почему', text: why),
              const SizedBox(height: 8),
              _FeedbackBlock(label: 'Что дальше', text: next, accent: true),
              const SizedBox(height: 16),
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
                    confirmLabel,
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

class _FeedbackBlock extends StatelessWidget {
  const _FeedbackBlock({
    required this.label,
    required this.text,
    this.accent = false,
  });

  final String label;
  final String text;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: accent ? const Color(0xFFEBF4EE) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent
              ? const Color(0xFF1B6943)
              : const Color(0xFF1B6943).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: accent ? const Color(0xFF1B6943) : const Color(0xFFDF9548),
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
    );
  }
}
