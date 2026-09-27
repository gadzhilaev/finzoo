import 'dart:io';
import 'dart:ui' as ui;
import 'package:finzoo/features/home/presentation/book_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.disableAnimations;
  testWidgets('360 cover', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 780));
    await tester.pumpWidget(RepaintBoundary(
      child: MaterialApp(debugShowCheckedModeBanner: false, home: BookPage()),
    ));
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final b = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
    final img = await b.toImage(pixelRatio: 2);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    File('build/ui_shots/sim_book_cover_360.png').writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}
