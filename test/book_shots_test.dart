import 'dart:io';
import 'dart:ui' as ui;

import 'package:finzoo/features/home/presentation/book/book_content.dart';
import 'package:finzoo/features/home/presentation/book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.disableAnimations;
  final out = Directory('build/ui_shots')..createSync(recursive: true);

  Future<void> capture(WidgetTester tester, String name, int page) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    await tester.pumpWidget(
      RepaintBoundary(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: BookPage(startPage: page),
        ),
      ),
    );
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byType(RepaintBoundary).first,
    );
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('${out.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  }

  testWidgets('capture book pages', (tester) async {
    final total = BookContent.flatPageCount;
    await capture(tester, 'sim_book_p1', 0);
    await capture(tester, 'sim_book_p2', 1);
    await capture(tester, 'sim_book_p4', 3);
    await capture(tester, 'sim_book_p5', 4);
    await capture(tester, 'sim_book_plast', total - 1);
  });
}
