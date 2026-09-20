import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import 'widgets/onboarding_next_button.dart';

/// Шаг «Как тебя зовут ?» — поле без стрелок + Далее.
class NameStep extends StatefulWidget {
  const NameStep({
    super.key,
    this.initialName = '',
    this.onNext,
    this.onChanged,
  });

  final String initialName;
  final ValueChanged<String>? onNext;
  final ValueChanged<String>? onChanged;

  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  static const _hintColor = Color(0x4A4B946A);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fieldStyle = GoogleFonts.rubik(
      fontWeight: FontWeight.w500,
      fontSize: 27.21,
      height: 1,
      letterSpacing: -0.68,
      color: AppColors.green,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 285,
          height: 66,
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.green, width: 6),
          ),
          alignment: Alignment.centerLeft,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.left,
            textCapitalization: TextCapitalization.words,
            style: fieldStyle,
            cursorColor: AppColors.green,
            inputFormatters: [LengthLimitingTextInputFormatter(20)],
            decoration: InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              hintText: 'Имя',
              hintStyle: fieldStyle.copyWith(color: _hintColor),
            ),
            onChanged: (value) {
              widget.onChanged?.call(value);
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 15),
        OnboardingNextButton(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            widget.onNext?.call(_controller.text.trim());
          },
        ),
      ],
    );
  }
}
