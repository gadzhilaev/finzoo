import 'dart:io';

import 'package:finzoo/features/home/presentation/book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/ui_shot_capture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('360 cover', (tester) async {
    final out = Directory('build/ui_shots')..createSync(recursive: true);
    await tester.binding.setSurfaceSize(const Size(360, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const RepaintBoundary(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BookPage(animationsEnabled: false),
        ),
      ),
    );
    final file = await captureUiShot(
      tester,
      path: '${out.path}/sim_book_cover_360.png',
      settlePumps: 24,
    );
    expect(file.existsSync(), isTrue);
  });
}
