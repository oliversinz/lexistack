import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/ui/catalog_screens.dart';

import '../support/progress_fixture.dart';
import 'board_test.dart' show viewport, tapVisible;
import 'f5_catalog_test.dart' show app, openPack;
import 'progress_test.dart' show board;

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final (family, file) in [
      ('Fraunces', 'fraunces'),
      ('DM Sans', 'dmsans'),
    ]) {
      await (FontLoader(
        family,
      )..addFont(rootBundle.load('assets/fonts/$file.ttf'))).load();
    }
  });
  for (final (size, scale) in [
    (const Size(360, 640), 1.3),
    (const Size(390, 844), 1.0),
  ]) {
    testWidgets(
      'Pack 6 sixteen-stage progress and lower navigation at $size/$scale',
      (t) async {
        viewport(t, size, scale: scale);
        final p = await player();
        final pack = p.campaignPacks.last;
        for (final level in pack.levels.take(8)) {
          win(BoardController(p, p.enterCampaign(level)!));
        }
        await p.flush();
        await app(t, p.storage as MemoryProgressStorage);
        await tapVisible(t, find.text('Campaign'));
        final card = find.ancestor(
          of: find.text(pack.title),
          matching: find.byType(PackCard),
        );
        await t.ensureVisible(card);
        await t.pumpAndSettle();
        expect(
          find.descendant(
            of: card,
            matching: find.text('8 / 16 solved · Available offline'),
          ),
          findsOneWidget,
        );
        final bars = find.descendant(
          of: card,
          matching: find.byWidgetPredicate(
            (w) => w is Container && w.constraints?.maxHeight == 6,
          ),
        );
        expect(bars, findsNWidgets(16));
        final colors = Theme.of(t.element(card)).colorScheme;
        final barWidgets = t.widgetList<Container>(bars).toList();
        expect(
          barWidgets.take(8).every((w) => w.color == colors.primary),
          isTrue,
        );
        expect(
          barWidgets.skip(8).every((w) => w.color == colors.outlineVariant),
          isTrue,
        );
        for (final bar in bars.evaluate()) {
          expect(t.getSize(find.byWidget(bar.widget)).width, greaterThan(0));
        }
        await openPack(t, pack.title);
        expect(
          find.text('16 levels · Win a stage to unlock the next'),
          findsOneWidget,
        );
        for (final (index, level) in pack.levels.indexed.skip(8)) {
          final entry = find.byKey(ValueKey('level-${level.id}'));
          await t.ensureVisible(entry);
          await t.pumpAndSettle();
          expect(entry.hitTestable(), findsOneWidget);
          expect(t.widget<InkWell>(entry).onTap != null, index == 8);
          expect(t.takeException(), isNull);
        }
        await tapVisible(t, find.byKey(const ValueKey('level-pack6_lvl09')));
        await tapVisible(t, find.text('Play'));
        expect(board(t).game.level.id, 'pack6_lvl09');
        expect(t.takeException(), isNull);
      },
    );
  }
}
