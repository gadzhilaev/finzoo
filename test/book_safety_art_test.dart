import 'package:finzoo/features/home/presentation/book/book_content.dart';
import 'package:finzoo/features/home/presentation/book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('book is exactly 6 cleaned runtime screens from обучение/', () {
    expect(BookContent.screens.length, 6);
    expect(BookContent.flatPageCount, 6);
    expect(
      BookContent.screens.map((s) => s.asset).toList(),
      [
        'assets/book/runtime/book_page_01.png',
        'assets/book/runtime/book_page_02.png',
        'assets/book/runtime/book_page_03.png',
        'assets/book/runtime/book_page_04.png',
        'assets/book/runtime/book_page_05.png',
        'assets/book/runtime/book_page_06.png',
      ],
    );
    expect(BookContent.screens.where((s) => s.quiz).length, 2);
  });

  testWidgets('page 1 shows cleaned runtime art', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: BookPage()));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    expect(find.textContaining('1 / 6'), findsOneWidget);
    expect(
      find.image(
        const AssetImage('assets/book/runtime/book_page_01.png'),
      ),
      findsOneWidget,
    );
    // Raw designer PNG with status/nav must not be used.
    expect(
      find.image(
        const AssetImage('assets/book/safety/png/book_page_01.png'),
      ),
      findsNothing,
    );
  });

  testWidgets('step1 cleaned runtime page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: BookPage(startPage: 1)));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    expect(
      find.image(
        const AssetImage('assets/book/runtime/book_page_02.png'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('2 / 6'), findsOneWidget);
  });

  testWidgets('quiz overlay works', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: BookPage(startPage: 4)));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 40));
    }
    // Tap left choice (Мошенник) at designer coords.
    await tester.tapAt(const Offset(110, 630));
    await tester.pump();
    expect(find.text('Проверить ответ'), findsOneWidget);
    await tester.tap(find.text('Проверить ответ'));
    await tester.pump();
    expect(find.textContaining('Верно'), findsWidgets);
  });
}
