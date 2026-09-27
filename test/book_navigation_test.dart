import 'package:finzoo/features/home/presentation/book/book_content.dart';
import 'package:finzoo/features/home/presentation/book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 40));
  }
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.disableAnimations;

  final total = BookContent.flatPageCount;

  testWidgets('flips cover to last without answers', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: BookPage()));
    await _settle(tester);
    expect(find.textContaining('1 /'), findsWidgets);

    for (var i = 1; i < total; i++) {
      await tester.tapAt(const Offset(267, 795));
      await _settle(tester);
    }
    expect(find.textContaining('$total / $total'), findsOneWidget);
  });

  testWidgets('free flip past action without answering', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Страница «Попробуй» первого урока — упражнение не блокирует листание.
    await tester.pumpWidget(const MaterialApp(home: BookPage(startPage: 3)));
    await _settle(tester);
    expect(find.textContaining('доступная сумма'), findsOneWidget);
    expect(find.textContaining('4 /'), findsOneWidget);

    await tester.tapAt(const Offset(267, 795));
    await _settle(tester);
    expect(find.textContaining('5 /'), findsOneWidget);
  });

  testWidgets('toc jumps to lesson', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: BookPage(startAtToc: true)),
    );
    await _settle(tester);
    expect(find.text('Оглавление'), findsWidgets);

    await tester.tap(find.text('Копим на мечту').first);
    await _settle(tester);
    expect(find.textContaining('Копим'), findsWidgets);
  });
}
