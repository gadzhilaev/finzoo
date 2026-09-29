import 'package:finzoo/features/home/presentation/book/animated_book_background.dart';
import 'package:finzoo/features/home/presentation/book/book_content.dart';
import 'package:finzoo/features/home/presentation/book/book_widgets.dart';
import 'package:finzoo/features/home/presentation/book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('runtime assets under assets/book/runtime/', () {
    expect(BookContent.screens.length, 6);
    for (final s in BookContent.screens) {
      expect(s.asset, startsWith('assets/book/runtime/'));
    }
  });

  testWidgets('single counter and single nav pair on page 1', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: BookPage()));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }

    expect(find.text('1 / 6'), findsOneWidget);
    expect(find.byType(BookArrowButton), findsNWidgets(2));
    expect(find.byType(AnimatedBookBackground), findsOneWidget);

    // Back disabled, forward enabled
    final buttons = tester.widgetList<BookArrowButton>(find.byType(BookArrowButton)).toList();
    expect(buttons[0].forward, isFalse);
    expect(buttons[0].enabled, isFalse);
    expect(buttons[1].forward, isTrue);
    expect(buttons[1].enabled, isTrue);
  });

  testWidgets('last page next disabled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: BookPage(startPage: 5)));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    expect(find.text('6 / 6'), findsOneWidget);
    final buttons = tester.widgetList<BookArrowButton>(find.byType(BookArrowButton)).toList();
    expect(buttons[0].enabled, isTrue);
    expect(buttons[1].enabled, isFalse);
  });
}
