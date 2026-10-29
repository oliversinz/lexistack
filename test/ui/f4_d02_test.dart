import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'board_test.dart' show tapVisible, tile;
import 'f4_d01_test.dart' show start, captureKey, submit, dock, visible;
import 'progress_test.dart' show board;

Future<void> snapshot(WidgetTester t, String name) async {
  if (!const bool.fromEnvironment('CAPTURE')) return;
  await t.runAsync(() async {
    final boundary = t.renderObject<RenderRepaintBoundary>(
      find.byKey(captureKey),
    );
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    await File('docs/evidence/f4-d02/$name.png')
        .writeAsBytes(bytes.buffer.asUint8List());
    image.dispose();
  });
}

RenderParagraph paragraph(WidgetTester t, Finder text) =>
    t.renderObject<RenderParagraph>(
      find.descendant(of: text, matching: find.byType(RichText)),
    );

void font(WidgetTester t, String text, String family) {
  final finder = find.text(text);
  expect(finder, findsOneWidget);
  expect(paragraph(t, finder).text.style!.fontFamily, family, reason: text);
}

void auditFonts(WidgetTester t) {
  // Inspect the merged style handed to the renderer, including inherited
  // AppBar/body styles, rather than searching source declarations.
  for (final element in find.byType(Text).evaluate()) {
    final text = element.widget as Text;
    final brand =
        text.data == 'LexiStack' || text.data == 'Good words.\nGreat company.';
    // Multiple pack cards reuse the same const Text widget; audit each element.
    final rendered = paragraph(
      t,
      find.byElementPredicate((candidate) => identical(candidate, element)),
    );
    expect(
      rendered.text.style!.fontFamily,
      brand ? 'Fraunces' : 'DM Sans',
      reason: text.data,
    );
  }
  expect(t.takeException(), isNull);
}

Future<void> back(WidgetTester t) async {
  await t.pageBack();
  await t.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final (family, path) in [
      ('Fraunces', 'assets/fonts/fraunces.ttf'),
      ('DM Sans', 'assets/fonts/dmsans.ttf'),
      (
        'MaterialIcons',
        '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts/MaterialIcons-Regular.otf',
      ),
    ]) {
      final loader = FontLoader(family)
        ..addFont(
          Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
        );
      await loader.load();
    }
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'F4-D02 resolved fonts and layout: ${brightness.name}, small/phone/wide',
      (t) async {
        t.platformDispatcher.platformBrightnessTestValue = brightness;
        addTearDown(t.platformDispatcher.clearPlatformBrightnessTestValue);
        for (final (size, scale) in [
          (const Size(360, 640), 1.3),
          (const Size(390, 844), 1.0),
          (const Size(1280, 800), 1.3),
        ]) {
          await t.pumpWidget(const SizedBox());
          await start(t, size, scale);
          final mode = brightness.name;
          expect(
            Theme.of(t.element(find.text('LexiStack'))).brightness,
            brightness,
          );
          font(t, 'LexiStack', 'Fraunces');
          font(t, 'Good words.\nGreat company.', 'Fraunces');
          font(t, 'Daily 2026-10-28', 'DM Sans');
          font(t, 'The puzzle shelf', 'DM Sans');
          expect(
            paragraph(t, find.text('Daily 2026-10-28')).didExceedMaxLines,
            isFalse,
          );
          expect(
            paragraph(
              t,
              find.text('Good words.\nGreat company.'),
            ).didExceedMaxLines,
            isFalse,
          );
          auditFonts(t);
          if (size.width == 390) {
            visible(t, find.text('Continue Campaign'), size);
            visible(t, find.text('Play Daily'), size);
            await snapshot(t, 'widget-home-$mode-390');
          }

          await tapVisible(t, find.text('Campaign'));
          font(t, 'Campaign', 'DM Sans');
          font(t, 'Follow your curiosity.', 'DM Sans');
          auditFonts(t);
          await tapVisible(t, find.text('Explore collection').first);
          font(t, 'Everyday Echoes', 'DM Sans');
          font(t, '01', 'DM Sans');
          auditFonts(t);
          await back(t);
          await back(t);

          await tapVisible(t, find.text('Continue Campaign'));
          font(t, '1 · Table Talk', 'DM Sans');
          auditFonts(t);
          for (final word in board(t).game.level.tiles) {
            visible(t, tile(word.text), size, aboveDock: true);
          }
          visible(t, submit, size);
          final dockBounds = t.getRect(dock);
          for (final word in ['TOAST', 'WAFFLE', 'MUFFIN', 'BAGEL']) {
            await t.tap(tile(word));
            await t.pumpAndSettle();
          }
          expect(t.widget<FilledButton>(submit).onPressed, isNotNull);
          visible(t, submit, size);
          if (size.width == 360 && brightness == Brightness.dark) {
            await snapshot(t, 'widget-board-dark-360-1.3');
          }
          await t.tap(submit);
          await t.pumpAndSettle();
          expect(t.getRect(dock), dockBounds);
          visible(t, submit, size);
          auditFonts(t);
          // Reach a genuine result through the existing controller to inspect
          // its typography; gameplay transitions have separate regression tests.
          final b = board(t);
          for (final group in b.game.remainingCategories.toList()) {
            for (final word in group.tiles) {
              b.toggle(word.id);
            }
            b.submit();
            await t.pumpAndSettle();
            if (b.game.solvedIds.length == 2) {
              expect(t.getRect(dock), dockBounds);
              visible(t, submit, size);
            }
          }
          font(t, 'You found every connection!', 'DM Sans');
          font(t, '+50 coins awarded for this attempt', 'DM Sans');
          auditFonts(t);
          await tapVisible(t, find.text('Copy result'));
          await back(t);

          await tapVisible(t, find.byTooltip('Statistics'));
          font(t, 'Statistics', 'DM Sans');
          font(t, 'Every connection counts.', 'DM Sans');
          font(t, '1 game played', 'DM Sans');
          font(t, 'Daily rhythm', 'DM Sans');
          expect(
            paragraph(t, find.text('1 game played')).didExceedMaxLines,
            isFalse,
          );
          auditFonts(t);
          if (size.width == 1280 && brightness == Brightness.light) {
            expect(t.getSize(find.byKey(const Key('app-frame'))).width, 460);
            await snapshot(t, 'widget-stats-light-1280-1.3');
          }
          await back(t);
          await tapVisible(t, find.byTooltip('Settings'));
          font(t, 'Settings', 'DM Sans');
          font(t, 'Make yourself at home.', 'DM Sans');
          auditFonts(t);
          await tapVisible(t, find.text('Reset progress'));
          auditFonts(t);
          await tapVisible(t, find.text('Cancel'));
          debugPrint(
            'F4-D02 $mode ${size.width}x${size.height} scale=$scale: resolved font roles, render/layout and fixed dock PASS',
          );
        }
      },
    );
  }
}
