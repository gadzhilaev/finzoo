import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finzoo/core/profile/player_profile.dart';
import 'package:finzoo/features/home/presentation/book/book_widgets.dart';
import 'package:finzoo/features/onboarding/presentation/onboarding_tutorial_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('onboarding tutorial pages navigate and finish', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var done = false;
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingTutorialPage(
          profile: PlayerProfile.fresh(),
          petName: 'Пушок',
          animationsEnabled: false,
          onDone: () => done = true,
        ),
      ),
    );
    // OnboardingDecor крутит бесконечную анимацию — settle не подходит.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Привет! Я Пушок'), findsOneWidget);
    expect(find.text('1 / 6'), findsOneWidget);

    final nextArrow = find.byWidgetPredicate(
      (w) => w is BookArrowButton && w.forward,
    );

    for (var i = 0; i < 5; i++) {
      await tester.tap(nextArrow);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    expect(find.text('Готово!'), findsOneWidget);
    expect(find.text('Начать игру'), findsOneWidget);

    await tester.tap(find.text('Начать игру'));
    await tester.pump();
    expect(done, isTrue);
  });
}
