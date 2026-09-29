import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/profile/player_profile.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/theme/finzo_hit_target.dart';
import '../../../core/wardrobe/finzo_avatar.dart';

/// Девять стартовых образов одного питомца. Это сохраняет узнаваемую белку
/// Finzo и даёт ребёнку реальный выбор при создании профиля.
class StarterLook {
  const StarterLook({required this.title, this.bodyKey, this.headKey});
  final String title;
  final String? bodyKey;
  final String? headKey;
}

const starterLooks = <StarterLook>[
  StarterLook(title: 'Классика'),
  StarterLook(title: 'Свитер', bodyKey: 'c0'),
  StarterLook(title: 'Футболка', bodyKey: 'c1'),
  StarterLook(title: 'Платье с бантом', bodyKey: 'c2', headKey: 'c4'),
  StarterLook(title: 'Очки', headKey: 'c3'),
  StarterLook(title: 'Бант', headKey: 'c4'),
  StarterLook(title: 'Худи', bodyKey: 'c5'),
  StarterLook(title: 'Цилиндр', headKey: 'c6'),
  StarterLook(title: 'Костюм', bodyKey: 'c7'),
];

class PetSetupPage extends StatefulWidget {
  const PetSetupPage({
    super.key,
    required this.playerName,
    this.initialPetName = 'Finzo',
    this.initialLook = 0,
    this.onBack,
    this.onDone,
  });

  final String playerName;
  final String initialPetName;
  final int initialLook;
  final VoidCallback? onBack;
  final void Function(String petName, StarterLook look)? onDone;

  @override
  State<PetSetupPage> createState() => _PetSetupPageState();
}

class _PetSetupPageState extends State<PetSetupPage> {
  late final TextEditingController _name;
  late int _selected;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialPetName);
    _selected = widget.initialLook.clamp(0, starterLooks.length - 1);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sample = PlayerProfile.fresh().copyWith(
      starterBodyKey: starterLooks[_selected].bodyKey,
      starterHeadKey: starterLooks[_selected].headKey,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFFEFCF4),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFCF4),
        foregroundColor: const Color(0xFF1B6943),
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          onPressed: widget.onBack,
          style: FinzoHitTarget.iconButtonStyle(
            foregroundColor: const Color(0xFF1B6943),
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Создай Finzo',
          style: AppFonts.rubik(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF1B6943),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            children: [
              Text('Как зовут твою белку?', style: _title),
              const SizedBox(height: 6),
              TextField(
                controller: _name,
                inputFormatters: [LengthLimitingTextInputFormatter(16)],
                textCapitalization: TextCapitalization.words,
                textAlign: TextAlign.center,
                style: _title,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  hintText: 'Finzo',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1B6943)),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 108,
                child: ClipRect(
                  child: Center(
                    child: FinzoAvatar(
                      profile: sample,
                      width: 100,
                      height: 108,
                      // Чуть правее bbox из‑за хвоста, но не до упора в центр оси.
                      alignBodyAxis: true,
                      bodyAxisFactor: 0.55,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
                child: Text(
                  'Выбери стартовый образ — позже одежду можно менять дома.',
                  textAlign: TextAlign.center,
                  style: _body,
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 8.0;
                      final cellW = (constraints.maxWidth - gap * 2) / 3;
                      // Ниже, чем «растянуть на весь экран»: чуть выше квадрата.
                      var cellH = cellW * 1.12;
                      final gridH = cellH * 3 + gap * 2;
                      if (gridH > constraints.maxHeight &&
                          constraints.maxHeight > 0) {
                        cellH = (constraints.maxHeight - gap * 2) / 3;
                      }
                      final ratio = cellW / cellH;
                      return SizedBox(
                        height: cellH * 3 + gap * 2,
                        width: constraints.maxWidth,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: starterLooks.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: ratio,
                            crossAxisSpacing: gap,
                            mainAxisSpacing: gap,
                          ),
                          itemBuilder: (_, index) {
                            final look = starterLooks[index];
                            final selected = _selected == index;
                            final preview = PlayerProfile.fresh().copyWith(
                              starterBodyKey: look.bodyKey,
                              starterHeadKey: look.headKey,
                            );
                            final avatarH = (cellH - 26).clamp(44.0, 100.0);
                            final avatarW = avatarH * (151 / 177);
                            return Semantics(
                              button: true,
                              selected: selected,
                              label: 'Образ ${look.title}',
                              child: Material(
                                color: selected
                                    ? const Color(0xFFE8F5EC)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  onTap: () =>
                                      setState(() => _selected = index),
                                  borderRadius: BorderRadius.circular(14),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: selected
                                            ? const Color(0xFF1B6943)
                                            : const Color(0xFFB9D2C2),
                                        width: selected ? 2 : 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        2,
                                        4,
                                        2,
                                        2,
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: ClipRect(
                                              child: Center(
                                                child: FinzoAvatar(
                                                  profile: preview,
                                                  width: avatarW,
                                                  height: avatarH,
                                                  alignBodyAxis: true,
                                                  bodyAxisFactor: 0.55,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            look.title,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppFonts.rubik(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                              color: const Color(0xFF1B6943),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => widget.onDone?.call(
                    _name.text.trim(),
                    starterLooks[_selected],
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4B946A),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Готово',
                    style: AppFonts.rubik(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _title = AppFonts.rubik(
  fontWeight: FontWeight.w700,
  fontSize: 16,
  color: const Color(0xFF1B6943),
);
final _body = AppFonts.rubik(
  fontWeight: FontWeight.w500,
  fontSize: 12,
  height: 1.25,
  color: const Color(0xFF4A4643),
);
