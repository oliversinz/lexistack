import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/ui/app.dart';
import 'package:lexistack/ui/theme.dart';

import '../app_test.dart' show TestBundle;
import 'board_test.dart' show viewport, tile;
import 'progress_test.dart' show board;

const captureKey = Key('capture');
final submit = find.byKey(const Key('submit'));
final dock = find.byKey(const Key('action-dock'));
final tray = find.byKey(const Key('selection-tray'));

Future<void> start(WidgetTester t, Size size, double scale) async {
  viewport(t, size, scale: scale);
  t.view.padding = const FakeViewPadding(top: 24, bottom: 24);
  t.view.viewPadding = const FakeViewPadding(top: 24, bottom: 24);
  addTearDown(t.view.resetPadding);
  addTearDown(t.view.resetViewPadding);
  await t.pumpWidget(
    RepaintBoundary(
      key: captureKey,
      child: LexiStackApp(
        bundle: TestBundle(),
        storage: MemoryProgressStorage(),
        clock: () => DateTime(2026, 10, 28),
      ),
    ),
  );
  await t.pumpAndSettle();
}

void visible(
  WidgetTester t,
  Finder target,
  Size size, {
  bool aboveDock = false,
}) {
  final rect = t.getRect(target);
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.right, lessThanOrEqualTo(size.width));
  expect(rect.top, greaterThanOrEqualTo(24));
  expect(
    rect.bottom,
    lessThanOrEqualTo(aboveDock ? t.getRect(dock).top : size.height - 24),
  );
  expect(target.hitTestable(), findsOneWidget);
}

Future<void> capture(WidgetTester t, String name) async {
  if (!const bool.fromEnvironment('CAPTURE')) return;
  await t.runAsync(() async {
    final boundary = t.renderObject<RenderRepaintBoundary>(
      find.byKey(captureKey),
    );
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    await File('docs/evidence/f4-d01/$name.png')
        .writeAsBytes(bytes.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final icons = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File(
              '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts/MaterialIcons-Regular.otf',
            ).readAsBytesSync(),
          ),
        ),
      );
    await icons.load();
    for (final (family, file) in [
      ('Fraunces', 'fraunces'),
      ('DM Sans', 'dmsans'),
    ]) {
      final loader = FontLoader(family)
        ..addFont(
          Future.value(
            ByteData.sublistView(
              File('assets/fonts/$file.ttf').readAsBytesSync(),
            ),
          ),
        );
      await loader.load();
    }
  });

  testWidgets(
    'F4-D01 390x844 actual 16 tile rectangles + Submit inside SafeArea without scrolling',
    (t) async {
      const size = Size(390, 844);
      await start(t, size, 1);
      visible(t, find.text('Continue Campaign'), size);
      visible(t, find.text('Play Daily'), size);
      await capture(t, 'home-widget-390');
      await t.tap(find.text('Continue Campaign'));
      await t.pumpAndSettle();
      final b = board(t);
      final scroll = t.state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(const Key('board-scroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(scroll.position.pixels, 0);
      debugPrint(
        '390x844 grid=${t.getRect(find.byKey(const Key('tile-grid')))} submit=${t.getRect(submit)} dock=${t.getRect(dock)} safeY=24..820 scroll=${scroll.position.pixels}',
      );
      expect(b.game.order.length, 16);
      for (final word in b.game.level.tiles) {
        visible(t, tile(word.text), size, aboveDock: true);
        expect(
          t.getSize(tile(word.text)).shortestSide,
          greaterThanOrEqualTo(48),
        );
      }
      visible(t, submit, size);
      await capture(t, 'board-fresh-widget-390');
      for (final word in ['TOAST', 'WAFFLE', 'MUFFIN', 'BAGEL']) {
        await t.tap(tile(word));
        await t.pumpAndSettle();
      }
      expect(t.widget<FilledButton>(submit).onPressed, isNotNull);
      expect(scroll.position.pixels, 0);
      for (final word in b.game.level.tiles) {
        visible(t, tile(word.text), size, aboveDock: true);
      }
      visible(t, submit, size);
      await capture(t, 'board-selected-widget-390');
      await t.tap(submit);
      await t.pumpAndSettle();
      expect(b.game.solvedIds.length, 1);
      expect(
        find.text(b.game.level.categories.first.triviaFact),
        findsOneWidget,
      );
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'F4-D01 360x640 1.3x anchored action, real tray drag, one/two solves and facts',
    (t) async {
      const size = Size(360, 640);
      await start(t, size, 1.3);
      await t.tap(find.text('Continue Campaign'));
      await t.pumpAndSettle();
      final b = board(t);
      final dockRect = t.getRect(dock);
      debugPrint(
        '360x640 scale=1.3 grid=${t.getRect(find.byKey(const Key('tile-grid')))} submit=${t.getRect(submit)} dock=$dockRect safeY=24..616',
      );
      for (final word in b.game.level.tiles) {
        visible(t, tile(word.text), size, aboveDock: true);
      }
      visible(t, submit, size);
      final drag = await t.startGesture(t.getCenter(tile('TOAST')));
      await t.pump(const Duration(milliseconds: 600));
      await drag.moveTo(t.getCenter(tray));
      await t.pump(const Duration(milliseconds: 100));
      await drag.up();
      await t.pumpAndSettle();
      expect(b.game.selection.map(b.game.tile).map((x) => x.text), ['TOAST']);
      for (final word in ['WAFFLE', 'MUFFIN', 'BAGEL']) {
        await t.tap(tile(word));
        await t.pumpAndSettle();
      }
      visible(t, submit, size);
      for (final id in b.game.selection) {
        visible(t, tile(b.game.tile(id).text), size, aboveDock: true);
      }
      await capture(t, 'board-small');
      await t.tap(submit);
      await t.pumpAndSettle();
      expect(b.game.solvedIds.length, 1);
      expect(
        find.text(b.game.level.categories.first.triviaFact),
        findsOneWidget,
      );
      for (var group = 1; group <= 2; group++) {
        // Only the secondary scroll region moves; the dock cannot move or overlap it.
        await t.ensureVisible(find.byKey(const Key('tile-grid')));
        await t.pumpAndSettle();
        for (final word in b.game.level.categories[group].tiles) {
          visible(t, tile(word.text), size, aboveDock: true);
          await t.tap(tile(word.text));
          await t.pumpAndSettle();
        }
        expect(t.getRect(dock), dockRect);
        visible(t, submit, size);
        for (final id in b.game.selection) {
          visible(t, tile(b.game.tile(id).text), size, aboveDock: true);
        }
        if (group == 2) await capture(t, 'board-small-two-solved');
        await t.tap(submit);
        await t.pumpAndSettle();
        expect(b.game.solvedIds.length, group + 1);
        expect(
          find.text(b.game.level.categories[group].triviaFact),
          findsOneWidget,
        );
      }
      // Older facts are explicitly expandable, including their exact words.
      final old = find.text('Tier 1 · BREAKFAST BAKES');
      await t.ensureVisible(old);
      await t.pumpAndSettle();
      await t.tap(old);
      await t.pumpAndSettle();
      expect(
        find.text(b.game.level.categories.first.triviaFact),
        findsOneWidget,
      );
      visible(t, submit, size);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'F4-D01 real Home and Board use Paper Arcade canvas, ink, CTA and selected tile',
    (t) async {
      await start(t, const Size(390, 844), 1);
      for (final dark in [false, true]) {
        if (dark) {
          board(t).progress.setSettings(theme: 'dark');
          await t.pumpAndSettle();
        } else {
          final c = Theme.of(t.element(find.text('Continue Campaign')))
              .colorScheme;
          expect(c.surface, paper);
          expect(c.primary, violet);
          expect(c.onSurface, ink);
          await t.tap(find.text('Continue Campaign'));
          await t.pumpAndSettle();
        }
        await t.tap(tile('TOAST'));
        await t.pumpAndSettle();
        final c = Theme.of(t.element(submit)).colorScheme;
        expect(c.surface, dark ? midnight : paper);
        expect(c.primary, dark ? lilac : violet);
        final faces = t.widgetList<Container>(
          find.descendant(of: tile('TOAST'), matching: find.byType(Container)),
        );
        expect(
          faces.any(
            (x) =>
                x.decoration is BoxDecoration &&
                (x.decoration as BoxDecoration).color == c.primary,
          ),
          isTrue,
        );
        for (final pair in [
          (c.onSurface, c.surface),
          (c.onSurface, c.surfaceContainerLow),
          (c.onPrimary, c.primary),
          (c.onSurfaceVariant, c.surfaceContainerHigh),
          (c.onPrimaryContainer, c.primaryContainer),
          (c.onSecondary, c.secondary),
          for (final tier in tierColors) (tierInk, tier),
        ]) {
          final a = pair.$1.computeLuminance(), b = pair.$2.computeLuminance();
          expect(
            (a > b ? a + .05 : b + .05) / (a > b ? b + .05 : a + .05),
            greaterThanOrEqualTo(4.5),
          );
        }
        await t.tap(tile('TOAST'));
        await t.pumpAndSettle();
      }
    },
  );
}
