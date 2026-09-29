import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finzoo/app.dart';
import 'package:finzoo/features/onboarding/presentation/age_page.dart';
import 'package:finzoo/features/onboarding/presentation/name_page.dart';
import 'package:finzoo/features/onboarding/presentation/pet_setup_page.dart';
import 'package:finzoo/features/splash/presentation/splash_page.dart';
import 'package:finzoo/features/welcome/presentation/welcome_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('splash → welcome → age → name → pet setup', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FinzooApp());
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(WelcomePage), findsOneWidget);

    await tester.tapAt(const Offset(204, 708));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(AgeStep), findsOneWidget);
    expect(find.text('Сколько тебе лет ?'), findsOneWidget);

    await tester.tap(find.text('Далее'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(NameStep), findsOneWidget);
    expect(find.text('Как тебя зовут ?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Миша');
    await tester.tap(find.text('Далее'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(PetSetupPage), findsOneWidget);
  });
}
