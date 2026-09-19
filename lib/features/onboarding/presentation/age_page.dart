import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_colors.dart';

/// Контент шага возраста (без собственного Scaffold) — для плавной смены на welcome.
class AgeStep extends StatefulWidget {
  const AgeStep({super.key, this.onNext});

  final ValueChanged<int>? onNext;

  @override
  State<AgeStep> createState() => _AgeStepState();
}

class _AgeStepState extends State<AgeStep> {
  static const _minAge = 1;
  static const _maxAge = 99;

  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '10');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int get _age {
    final parsed = int.tryParse(_controller.text);
    if (parsed == null) return 10;
    return parsed.clamp(_minAge, _maxAge);
  }

  void _setAge(int value) {
    final next = value.clamp(_minAge, _maxAge);
    _controller.text = '$next';
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    setState(() {});
  }

  void _onAgeEdited(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits != value) {
      _controller.text = digits;
      _controller.selection = TextSelection.collapsed(offset: digits.length);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _AgeControls(
      controller: _controller,
      focusNode: _focusNode,
      onAgeEdited: _onAgeEdited,
      onDecrement: () => _setAge(_age - 1),
      onIncrement: () => _setAge(_age + 1),
      onNext: () {
        final age = _age;
        _setAge(age);
        widget.onNext?.call(age);
      },
    );
  }
}

class _AgeControls extends StatelessWidget {
  const _AgeControls({
    required this.controller,
    required this.focusNode,
    required this.onAgeEdited,
    required this.onDecrement,
    required this.onIncrement,
    required this.onNext,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onAgeEdited;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ArrowButton(onTap: onDecrement, flipped: true),
            const SizedBox(width: 10),
            _AgeField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onAgeEdited,
            ),
            const SizedBox(width: 10),
            _ArrowButton(onTap: onIncrement, flipped: false),
          ],
        ),
        const SizedBox(height: 15),
        _NextButton(onTap: onNext),
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
      child: Padding(
        padding: const EdgeInsets.all(8),
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
    );
  }
}

class _AgeField extends StatelessWidget {
  const _AgeField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

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
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        style: GoogleFonts.rubik(
          fontWeight: FontWeight.w700,
          fontSize: 40.18,
          height: 1,
          letterSpacing: -1,
          color: AppColors.green,
        ),
        cursorColor: AppColors.green,
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.onTap});

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
