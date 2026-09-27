import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/profile/player_profile.dart';
import '../../../core/theme/app_fonts.dart';
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
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFCF4),
        foregroundColor: const Color(0xFF1B6943),
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onBack,
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
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
          child: Column(
            children: [
              Text('Как зовут твою белку?', style: _title),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                inputFormatters: [LengthLimitingTextInputFormatter(16)],
                textCapitalization: TextCapitalization.words,
                textAlign: TextAlign.center,
                style: _title,
                decoration: InputDecoration(
                  hintText: 'Finzo',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF1B6943)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 138,
                child: FinzoAvatar(profile: sample, width: 130, height: 138),
              ),
              Text(
                'Выбери стартовый образ — позже одежду можно менять дома.',
                textAlign: TextAlign.center,
                style: _body,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GridView.builder(
                  itemCount: starterLooks.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: .92,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (_, index) {
                    final look = starterLooks[index];
                    final selected = _selected == index;
                    final preview = PlayerProfile.fresh().copyWith(
                      starterBodyKey: look.bodyKey,
                      starterHeadKey: look.headKey,
                    );
                    return Semantics(
                      button: true,
                      selected: selected,
                      label: 'Образ ${look.title}',
                      child: InkWell(
                        onTap: () => setState(() => _selected = index),
                        borderRadius: BorderRadius.circular(14),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFE8F5EC)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF1B6943)
                                  : const Color(0xFFB9D2C2),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: FinzoAvatar(
                                  profile: preview,
                                  width: 76,
                                  height: 84,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                                child: Text(
                                  look.title,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.rubik(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                    color: const Color(0xFF1B6943),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => widget.onDone?.call(
                    _name.text.trim(),
                    starterLooks[_selected],
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4B946A),
                    minimumSize: const Size.fromHeight(52),
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
  fontSize: 17,
  color: const Color(0xFF1B6943),
);
final _body = AppFonts.rubik(
  fontWeight: FontWeight.w500,
  fontSize: 13,
  height: 1.3,
  color: const Color(0xFF4A4643),
);
