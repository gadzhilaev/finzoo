import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/onboarding_next_button.dart';

/// Контент шага возраста — только стрелки, поле не редактируется.
class AgeStep extends StatefulWidget {
  const AgeStep({super.key, this.initialAge = 10, this.onNext, this.onChanged});

  final int initialAge;
  final ValueChanged<int>? onNext;
  final ValueChanged<int>? onChanged;

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  static const _minAge = 1;
  static const _maxAge = 99;

  late int _age;

  @override
  void initState() {
    super.initState();
    _age = widget.initialAge.clamp(_minAge, _maxAge);
  }

  void _setAge(int value) {
    final next = value.clamp(_minAge, _maxAge);
    setState(() => _age = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ArrowButton(onTap: () => _setAge(_age - 1), flipped: true),
            const SizedBox(width: 10),
            _AgeField(age: _age),
            const SizedBox(width: 10),
            _ArrowButton(onTap: () => _setAge(_age + 1), flipped: false),
          ],
        ),
        const SizedBox(height: 15),
        OnboardingNextButton(onTap: () => widget.onNext?.call(_age)),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.onTap, required this.flipped});

  final VoidCallback onTap;
  final bool flipped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Center(
          child: Transform.rotate(
            angle: flipped ? math.pi : 0,
            child: SvgPicture.asset(
              AppAssets.strelka,
              width: 34,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _AgeField extends StatelessWidget {
  const _AgeField({required this.age});

  final int age;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      height: 66,
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.green, width: 6),
      ),
      alignment: Alignment.center,
      child: Text(
        '$age',
        textAlign: TextAlign.center,
        style: GoogleFonts.rubik(
          fontWeight: FontWeight.w700,
          fontSize: 40.18,
          height: 1,
          letterSpacing: -1,
          color: AppColors.green,
        ),
      ),
    );
  }
}
