import 'dart:io';
import 'dart:ui' as ui;

import 'package:finzoo/features/home/presentation/book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.disableAnimations;

  testWidgets('capture designer step1 screenshot', (tester) async {
    final out = Directory('build/ui_shots')..createSync(recursive: true);
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const RepaintBoundary(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BookPage(startPage: 1),
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
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary).first,
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('${out.path}/book_ref_step1.png');
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
    expect(file.existsSync(), isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
