import 'package:flutter/material.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/finzo_hit_target.dart';

class PracticeShell extends StatelessWidget {
  const PracticeShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onExit,
    this.bottom,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? bottom;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onExit,
                    style: FinzoHitTarget.iconButtonStyle(
                      foregroundColor: const Color(0xFF1B6943),
                    ),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        color: const Color(0xFF1B6943),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xFFDF9548),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: child),
              if (bottom != null) ...[
                const SizedBox(height: 8),
                bottom!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class PracticeResultPane extends StatelessWidget {
  const PracticeResultPane({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onExit,
    this.moodOk = true,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onExit;
  final bool moodOk;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF4B946A)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      moodOk ? Icons.sentiment_satisfied_alt : Icons.pets,
                      color: const Color(0xFF1B6943),
                      size: 44,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.35,
                        color: const Color(0xFF1B6943),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        practicePrimaryBtn('Ещё раз', onRetry),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: onExit,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4B946A),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'К списку практик',
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

Widget practicePrimaryBtn(String label, VoidCallback? onTap) {
  return Material(
    color: onTap == null ? const Color(0xFFA8C4B4) : const Color(0xFF4B946A),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 50,
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppFonts.rubik(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}

TextStyle get practiceBody => AppFonts.rubik(
      fontWeight: FontWeight.w500,
      fontSize: 15,
      height: 1.35,
      color: const Color(0xFF4A4643),
    );

TextStyle get practiceHead => AppFonts.rubik(
      fontWeight: FontWeight.w700,
      fontSize: 16,
      color: const Color(0xFF1B6943),
    );

TextStyle get practiceHint => AppFonts.rubik(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: const Color(0xFFDF9548),
    );

/// Реакция Finzo на действие (без аркады).
class FinzoMoodBanner extends StatelessWidget {
  const FinzoMoodBanner({super.key, required this.text, this.happy = true});

  final String text;
  final bool happy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: happy ? const Color(0xFFE8F5EC) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: happy ? const Color(0xFF4B946A) : const Color(0xFFDF9548),
        ),
      ),
      child: Row(
        children: [
          Icon(
            happy ? Icons.sentiment_satisfied_alt : Icons.sentiment_dissatisfied,
            color: happy ? const Color(0xFF1B6943) : const Color(0xFFDF9548),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: practiceBody)),
        ],
      ),
    );
  }
}
