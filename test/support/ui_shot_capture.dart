import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Deterministic screenshot capture for widget tests.
///
/// **Hang root cause (proven):** awaiting [RenderRepaintBoundary.toImage] /
/// [ui.Image.toByteData] *outside* [WidgetTester.runAsync] finishes the
/// raster work but leaves FakeAsync unable to complete test teardown
/// (`did not complete` / [TimeoutException]). Flutter's golden matcher uses
/// the same `runAsync` wrap — see `flutter_test` `_matchers_io.dart`.
///
/// Always:
/// - settle with a fixed pump count (never [WidgetTester.pumpAndSettle]);
/// - capture + encode inside [WidgetTester.runAsync];
/// - [ui.Image.dispose] the raster;
/// - for Book hosts pass `animationsEnabled: false` (test-only) so the
///   background [AnimationController.repeat] ticker is not left pending.
Future<File> captureUiShot(
  WidgetTester tester, {
  required String path,
  double pixelRatio = 2.0,
  int settlePumps = 16,
  Duration pumpStep = const Duration(milliseconds: 16),
}) async {
  for (var i = 0; i < settlePumps; i++) {
    await tester.pump(pumpStep);
  }

  final finder = find.byType(RepaintBoundary).first;
  final boundary = tester.renderObject<RenderRepaintBoundary>(finder);
  expect(
    boundary.debugNeedsPaint,
    isFalse,
    reason: 'RepaintBoundary must be painted before toImage',
  );

  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    try {
      final bd = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bd == null) {
        throw StateError('toByteData returned null for $path');
      }
      return bd.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  });

  expect(bytes, isNotNull, reason: 'runAsync capture returned null for $path');
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes!);
  return file;
}
