import 'dart:io';
import 'dart:ui' as ui;

import 'package:finzoo/core/profile/budget_plan.dart';
import 'package:finzoo/core/profile/economy.dart';
import 'package:finzoo/core/profile/game_controller.dart';
import 'package:finzoo/core/profile/player_profile.dart';
import 'package:finzoo/core/profile/player_profile_store.dart';
import 'package:finzoo/features/home/presentation/practice/practice_catalog.dart';
import 'package:finzoo/features/home/presentation/practice/practice_tasks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Один кадр за прогон: --dart-define=SHOT_ID=practice_lunch
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const id = String.fromEnvironment('SHOT_ID', defaultValue: 'practice_lunch');

  testWidgets('shot $id', (tester) async {
    final out = Directory('build/ui_shots')..createSync(recursive: true);
    final c = GameController(
      profile: PlayerProfile.fresh().copyWith(
        name: 'Demo',
        age: 9,
        onboardingDone: true,
        availableBalance: 280,
        savedBalance: 120,
        periodIncomeGranted: true,
        periodIncomeAmount: EconomyRules.periodIncome,
        plan: const BudgetPlan(necessary: 180, wants: 100, savings: 80),
      ),
      store: _Mem(),
    );
    final item = PracticeCatalog.byId(id)!;
    await tester.binding.setSurfaceSize(const Size(393, 852));
    await tester.pumpWidget(
      RepaintBoundary(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: buildPracticeTask(item: item, controller: c, onDone: () {}),
        ),
      ),
    );
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary).first,
    );
    final image = await boundary.toImage(pixelRatio: 1.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('${out.path}/$id.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

class _Mem extends PlayerProfileStore {
  PlayerProfile? _p;
  @override
  Future<PlayerProfile> load() async => _p ?? PlayerProfile.fresh();
  @override
  Future<void> save(PlayerProfile profile) async => _p = profile;
}
