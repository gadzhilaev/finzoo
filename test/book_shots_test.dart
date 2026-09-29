import 'dart:io';

import 'package:finzoo/features/home/presentation/book/book_content.dart';
import 'package:finzoo/features/home/presentation/book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ui_shot_capture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final out = Directory('build/ui_shots')..createSync(recursive: true);

  Future<void> capture(WidgetTester tester, String name, int page) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    await tester.pumpWidget(
      RepaintBoundary(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BookPage(startPage: page, animationsEnabled: false),
        ),
      ),
    );
    await captureUiShot(
      tester,
      path: '${out.path}/$name.png',
      settlePumps: 20,
    );
  }

  testWidgets('capture book pages', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final total = BookContent.flatPageCount;
    await capture(tester, 'sim_book_p1', 0);
    await capture(tester, 'sim_book_p2', 1);
    await capture(tester, 'sim_book_p4', 3);
    await capture(tester, 'sim_book_p5', 4);
    await capture(tester, 'sim_book_plast', total - 1);
  });
}
