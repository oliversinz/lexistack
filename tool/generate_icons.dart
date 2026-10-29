// Run: flutter test tool/generate_icons.dart
// Render the existing production mark directly at each required output size.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/ui/common.dart';
import 'package:lexistack/ui/theme.dart';

void main() {
  testWidgets('render Paper Arcade launcher and web icons', (t) async {
    t.view.physicalSize = const Size(512, 512);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    const key = Key('icon');
    await t.pumpWidget(
      RepaintBoundary(
        key: key,
        child: Theme(
          data: lexistackTheme(),
          child: const ColoredBox(
            color: paper,
            // The full mark fits inside the maskable icon's central safe circle.
            child: Center(child: PuzzleMark(size: 280)),
          ),
        ),
      ),
    );
    final outputs = <String, int>{
      for (final (density, size) in [
        ('mdpi', 48),
        ('hdpi', 72),
        ('xhdpi', 96),
        ('xxhdpi', 144),
        ('xxxhdpi', 192),
      ])
        'android/app/src/main/res/mipmap-$density/ic_launcher.png': size,
      'web/favicon.png': 32,
      for (final size in [192, 512]) ...{
        'web/icons/Icon-$size.png': size,
        'web/icons/Icon-maskable-$size.png': size,
      },
    };
    await t.runAsync(() async {
      final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(key));
      for (final entry in outputs.entries) {
        final image = await boundary.toImage(pixelRatio: entry.value / 512);
        final data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        await File(entry.key).writeAsBytes(data.buffer.asUint8List());
        expect(image.width, entry.value);
        expect(image.height, entry.value);
        image.dispose();
      }
    });
  });
}
