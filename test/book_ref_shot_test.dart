import 'dart:io';

import 'package:finzoo/features/home/presentation/book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ui_shot_capture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture designer step1 screenshot', (tester) async {
    final out = Directory('build/ui_shots')..createSync(recursive: true);
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const RepaintBoundary(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BookPage(startPage: 1, animationsEnabled: false),
        ),
      ),
    );
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(BookPage));
      await precacheImage(
        const AssetImage('assets/book/safety/png/book_page_02.png'),
        ctx,
      );
    });

    final file = await captureUiShot(
      tester,
      path: '${out.path}/book_ref_step1.png',
      settlePumps: 12,
    );
    expect(file.existsSync(), isTrue);
  });
}
