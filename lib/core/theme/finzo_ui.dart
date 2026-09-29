import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../assets/app_assets.dart';
import 'app_fonts.dart';
import 'finzo_book_tokens.dart';

/// Общие Finzo-контролы для служебных экранов (Adult и др.).
abstract final class FinzoUi {
  static const cream = FinzoBookTokens.pageCream;
  static const cardCream = Color(0xFFFEF7E6);
  static const mint = FinzoBookTokens.mint;
  static const green = FinzoBookTokens.titleGreen;
  static const arrowGreen = FinzoBookTokens.arrowGreen;
  static const body = Color(0xFF4A4643);
  static const orange = Color(0xFFDF9548);
  static const ink = Color(0xFF3D3D3D);
  static const radiusCard = 16.0;
  static const radiusControl = 14.0;
  static const strokeW = 1.5;
}

class FinzoOutlineIcon extends StatelessWidget {
  const FinzoOutlineIcon(this.asset, {super.key, this.size = 24, this.color});

  final String asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

/// Компактная кнопка входа «Для взрослых» (не toggle).
class FinzoAdultEntryButton extends StatefulWidget {
  const FinzoAdultEntryButton({super.key, required this.onTap});

  final VoidCallback? onTap;

  @override
  State<FinzoAdultEntryButton> createState() => _FinzoAdultEntryButtonState();
}

class _FinzoAdultEntryButtonState extends State<FinzoAdultEntryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Открыть раздел для взрослых',
      child: Tooltip(
        message: 'Для взрослых',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: widget.onTap == null
              ? null
              : (_) => setState(() => _pressed = true),
          onTapUp: widget.onTap == null
              ? null
              : (_) {
                  setState(() => _pressed = false);
                  widget.onTap?.call();
                },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1,
            duration: const Duration(milliseconds: 120),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: FinzoUi.mint,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: FinzoUi.green.withValues(alpha: 0.55),
                      width: FinzoUi.strokeW,
                    ),
                  ),
                  child: const FinzoOutlineIcon(AppAssets.iconAdult, size: 22),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FinzoToggle extends StatelessWidget {
  const FinzoToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.animate = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final duration = animate
        ? const Duration(milliseconds: 200)
        : Duration.zero;
    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOutCubic,
          width: 52,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? FinzoUi.arrowGreen : FinzoUi.mint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: value
                  ? FinzoUi.arrowGreen
                  : FinzoUi.green.withValues(alpha: 0.45),
              width: FinzoUi.strokeW,
            ),
          ),
          child: AnimatedAlign(
            duration: duration,
            curve: Curves.easeOutCubic,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? Colors.white : FinzoUi.cream,
                shape: BoxShape.circle,
                border: Border.all(
                  color: value
                      ? Colors.white
                      : FinzoUi.green.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FinzoSettingsRow extends StatelessWidget {
  const FinzoSettingsRow({
    super.key,
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.animateToggle = true,
  });

  final String iconAsset;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool animateToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              FinzoOutlineIcon(iconAsset, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: FinzoUi.green,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppFonts.rubik(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: FinzoUi.body,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FinzoToggle(
                value: value,
                onChanged: onChanged,
                animate: animateToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FinzoPrimaryAction extends StatefulWidget {
  const FinzoPrimaryAction({
    super.key,
    required this.label,
    required this.onTap,
    this.iconAsset,
  });

  final String label;
  final VoidCallback? onTap;
  final String? iconAsset;

  @override
  State<FinzoPrimaryAction> createState() => _FinzoPrimaryActionState();
}

class _FinzoPrimaryActionState extends State<FinzoPrimaryAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: widget.onTap == null
                ? FinzoUi.arrowGreen.withValues(alpha: 0.45)
                : FinzoUi.arrowGreen,
            borderRadius: BorderRadius.circular(FinzoUi.radiusControl),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.iconAsset != null) ...[
                FinzoOutlineIcon(
                  widget.iconAsset!,
                  size: 22,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FinzoWarmAction extends StatefulWidget {
  const FinzoWarmAction({
    super.key,
    required this.label,
    required this.onTap,
    this.iconAsset,
  });

  final String label;
  final VoidCallback? onTap;
  final String? iconAsset;

  @override
  State<FinzoWarmAction> createState() => _FinzoWarmActionState();
}

class _FinzoWarmActionState extends State<FinzoWarmAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: FinzoUi.cream,
            borderRadius: BorderRadius.circular(FinzoUi.radiusControl),
            border: Border.all(color: FinzoUi.orange, width: 1.6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.iconAsset != null) ...[
                FinzoOutlineIcon(widget.iconAsset!, size: 22),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: FinzoUi.orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool?> showFinzoConfirmDialog({
  required BuildContext context,
  required String title,
  required String body,
  required String confirmLabel,
  String cancelLabel = 'Отмена',
  String? iconAsset,
  bool warm = false,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.35),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (ctx, anim, _) {
      return const SizedBox.shrink();
    },
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(curved),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                  decoration: BoxDecoration(
                    color: FinzoUi.cream,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: warm
                          ? FinzoUi.orange
                          : FinzoUi.green.withValues(alpha: 0.55),
                      width: 1.6,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (iconAsset != null) ...[
                        FinzoOutlineIcon(iconAsset, size: 36),
                        const SizedBox(height: 10),
                      ],
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: FinzoUi.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: AppFonts.rubik(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          height: 1.35,
                          color: FinzoUi.body,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _DialogChip(
                              label: cancelLabel,
                              onTap: () => Navigator.pop(ctx, false),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _DialogChip(
                              label: confirmLabel,
                              filled: true,
                              warm: warm,
                              onTap: () => Navigator.pop(ctx, true),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _DialogChip extends StatelessWidget {
  const _DialogChip({
    required this.label,
    required this.onTap,
    this.filled = false,
    this.warm = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool warm;

  @override
  Widget build(BuildContext context) {
    final bg = !filled
        ? FinzoUi.mint
        : (warm ? FinzoUi.orange : FinzoUi.arrowGreen);
    final fg = !filled ? FinzoUi.green : Colors.white;
    final border = !filled ? FinzoUi.green.withValues(alpha: 0.35) : bg;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(FinzoUi.radiusControl),
          border: Border.all(color: border, width: FinzoUi.strokeW),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: fg,
          ),
        ),
      ),
    );
  }
}

/// Gate: пример 8+7. Lifecycle controller внутри StatefulWidget.
class FinzoAdultGate extends StatefulWidget {
  const FinzoAdultGate({super.key});

  static Future<bool?> open(BuildContext context) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, anim, _) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, _, child) {
        final curved = CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        );
        final inset = MediaQuery.viewInsetsOf(ctx).bottom;
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(curved),
            child: SafeArea(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.only(bottom: inset),
                child: GestureDetector(
                  behavior: HitTestBehavior.deferToChild,
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: Center(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: const FinzoAdultGate(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  State<FinzoAdultGate> createState() => _FinzoAdultGateState();
}

class _FinzoAdultGateState extends State<FinzoAdultGate> {
  late final TextEditingController _answer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _answer = TextEditingController();
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    _answer.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _submit() {
    _dismissKeyboard();
    if (_answer.text.trim() == '15') {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() => _error = 'Не получилось. Попробуй ещё раз.');
  }

  void _cancel() {
    _dismissKeyboard();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: FinzoUi.cream,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: FinzoUi.green.withValues(alpha: 0.55),
              width: 1.6,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const FinzoOutlineIcon(AppAssets.iconAdult, size: 40),
              const SizedBox(height: 10),
              Text(
                'Для взрослых',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: FinzoUi.green,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Реши пример, чтобы продолжить',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: FinzoUi.body,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '8 + 7',
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  color: FinzoUi.green,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _answer,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: FinzoUi.ink,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: FinzoUi.mint,
                  hintText: '?',
                  hintStyle: AppFonts.rubik(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: FinzoUi.arrowGreen.withValues(alpha: 0.45),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: FinzoUi.green.withValues(alpha: 0.45),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: FinzoUi.arrowGreen,
                      width: 2,
                    ),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: AppFonts.rubik(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: FinzoUi.orange,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'Этот раздел предназначен для взрослых.',
                textAlign: TextAlign.center,
                style: AppFonts.rubik(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: FinzoUi.body,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DialogChip(label: 'Отмена', onTap: _cancel),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FinzoPrimaryAction(label: 'Готово', onTap: _submit),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
