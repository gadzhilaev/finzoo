import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 285,
        height: 66,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.greenDark,
            borderRadius: BorderRadius.circular(16.36),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(16.36),
              ),
              child: Center(
                child: Text(
                  'Далее',
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.w500,
                    fontSize: 27.21,
                    height: 1,
                    letterSpacing: -0.68,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
