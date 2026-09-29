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

  testWidgets('flips first to last', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: BookPage()));
    await _settle(tester);
    expect(find.textContaining('1 / $total'), findsOneWidget);

    for (var i = 1; i < total; i++) {
      await tester.tapAt(const Offset(258, 785));
      await _settle(tester);
    }
    expect(find.textContaining('$total / $total'), findsOneWidget);
  });

  testWidgets('free flip past quiz', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: BookPage(startPage: 4)));
    await _settle(tester);
    expect(find.textContaining('5 / 6'), findsOneWidget);

    await tester.tapAt(const Offset(258, 785));
    await _settle(tester);
    expect(find.textContaining('6 / 6'), findsOneWidget);
  });
}
