import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/core/game.dart';

import 'board_test.dart' show tapVisible, tile, submitWords;
import 'f4_d01_test.dart' show start, captureKey, submit;
import 'progress_test.dart' show board;

Future<void> capture(WidgetTester t, String name, Size size) async {
  expect(t.takeException(), isNull);
  if (!const bool.fromEnvironment('CAPTURE')) return;
  await t.runAsync(() async {
    final boundary = t.renderObject<RenderRepaintBoundary>(
      find.byKey(captureKey),
    );
    final image = await boundary.toImage(pixelRatio: 1);
    expect(image.width, size.width.toInt());
    expect(image.height, size.height.toInt());
    final data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
    await Directory('docs/screenshots').create(recursive: true);
    await File('docs/screenshots/$name.png')
        .writeAsBytes(data.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> scrollTop(WidgetTester t) async {
  t.state<ScrollableState>(find.byType(Scrollable).first).position.jumpTo(0);
  await t.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final (family, path) in [
      ('Fraunces', 'assets/fonts/fraunces.ttf'),
      ('DM Sans', 'assets/fonts/dmsans.ttf'),
      ('LexiStack Symbols', 'assets/fonts/symbols.ttf'),
      ('LexiStack Emoji', 'assets/fonts/emoji.ttf'),
      (
        'MaterialIcons',
        '${File(Platform.resolvedExecutable).parent.parent.parent.path}/material_fonts/MaterialIcons-Regular.otf',
      ),
    ]) {
      await (FontLoader(family)..addFont(
            Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
          ))
          .load();
    }
  });

  testWidgets(
    'PLT-07 phone captures from real catalog and settled transitions',
    (t) async {
      const size = Size(390, 844);
      await start(t, size, 1);
      expect(find.text('150 coins'), findsOneWidget);
      await capture(t, '01_home', size);
      await tapVisible(t, find.text('Campaign'));
      for (final title in [
        'Everyday Echoes',
        'Science & Nature',
        'World History & Myth',
        'Pop Culture & Wordplay',
      ]) {
        expect(find.text(title), findsOneWidget);
      }
      await capture(t, '05_packs', size);
      await tapVisible(t, find.text('Explore collection').first);
      expect(find.text('Table Talk'), findsOneWidget);
      await capture(t, '05_packs_levels', size);
      await t.pageBack();
      await t.pumpAndSettle();
      await t.pageBack();
      await t.pumpAndSettle();
      await tapVisible(t, find.text('Continue Campaign'));
      final b = board(t);
      final categories = b.game.level.categories;
      for (final word in categories.first.tiles) {
        await tapVisible(t, tile(word.text));
      }
      expect(b.game.selection, hasLength(4));
      expect(t.widget<FilledButton>(submit).onPressed, isNotNull);
      await scrollTop(t);
      await capture(t, '02_board_selected', size);
      await tapVisible(t, submit);
      await submitWords(t, categories[1].tiles.map((x) => x.text).toList());
      expect(b.game.solvedIds, hasLength(2));
      // Opening the first collapsed card is a real UI action, preserving both facts.
      await tapVisible(t, find.text('Tier 1 · ${categories.first.title}'));
      for (final category in categories.take(2)) {
        expect(find.text(category.triviaFact), findsOneWidget);
      }
      await scrollTop(t);
      await capture(t, '03_board_solved', size);
      for (final category in categories.skip(2)) {
        await submitWords(t, category.tiles.map((x) => x.text).toList());
      }
      await b.progress.flush();
      expect(b.game.status, GameStatus.won);
      expect(b.game.stars, 3);
      expect(b.result!.reward, 50);
      expect(b.coins, 200);
      expect(b.progress.state.gamesPlayed, 1);
      await scrollTop(t);
      await capture(t, '04_result', size);
      for (final category in categories) {
        await t.ensureVisible(find.text(category.triviaFact));
        await t.pumpAndSettle();
        expect(find.text(category.triviaFact).hitTestable(), findsOneWidget);
      }
      await capture(t, '04_result_facts', size);
      final note = b.game.level.redHerrings.first.note;
      await t.ensureVisible(find.text(note));
      await t.pumpAndSettle();
      expect(find.text(note).hitTestable(), findsOneWidget);
      await capture(t, '04_result_red_herrings', size);
    },
  );

  testWidgets('PLT-07 desktop production board centered at width 460', (
    t,
  ) async {
    const size = Size(1280, 800);
    await start(t, size, 1);
    await tapVisible(t, find.text('Continue Campaign'));
    final frame = t.getRect(find.byKey(const Key('app-frame')));
    expect(frame.width, 460);
    expect(frame.center.dx, 640);
    expect(board(t).game.order, hasLength(16));
    await capture(t, '06_desktop_frame', size);
  });
}
