import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:finzoo/app.dart';
import 'package:finzoo/features/onboarding/presentation/age_page.dart';
import 'package:finzoo/features/onboarding/presentation/name_page.dart';
import 'package:finzoo/features/splash/presentation/splash_page.dart';
import 'package:finzoo/features/welcome/presentation/welcome_page.dart';

void main() {
  testWidgets('splash → welcome → age → name', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FinzooApp());
    expect(find.byType(SplashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pump();
    expect(find.byType(WelcomePage), findsOneWidget);

    await tester.tapAt(const Offset(204, 708));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(AgeStep), findsOneWidget);
    expect(find.text('Сколько тебе лет ?'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Далее'), findsOneWidget);

    await tester.tap(find.text('Далее'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(NameStep), findsOneWidget);
    expect(find.text('Как тебя зовут ?'), findsOneWidget);
    expect(find.text('Имя'), findsOneWidget);
    expect(find.text('Далее'), findsOneWidget);
  });
}
