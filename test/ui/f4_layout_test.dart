import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/ui/app.dart';
import 'package:lexistack/ui/board_screen.dart';
import 'package:lexistack/ui/catalog_screens.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../support/progress_fixture.dart' as fixture;
import 'board_test.dart' show viewport, tapVisible, submitWords, tile;
import 'progress_test.dart' show board;

// Navigation/layout fixture only: four independent copies of known groups.
// This is never validated as new production content or written to assets.
Catalog fourPacks() {
  final original = fixture.installedCatalog().packs.first;
  return Catalog(
    manifest: Manifest(
      campaign: [for (var p = 1; p <= 4; p++) 'fixture$p.json'],
    ),
    packs: [
      for (var p = 1; p <= 4; p++)
        Pack(
          source: 'fixture$p.json',
          schemaVersion: 2,
          id: 'fixture$p',
          title: 'Fixture collection $p',
          description: 'Eight test puzzles.',
          levels: [
            for (final (i, l) in original.levels.indexed)
              Level(
                id: 'fixture${p}_$i',
                packId: 'fixture$p',
                title: l.title,
                categories: [
                  for (final c in l.categories)
                    Category(
                      id: c.id,
                      title: c.difficultyTier == 1
                          ? 'A longer category title for a compact screen: ${c.title}'
                          : c.title,
                      difficultyTier: c.difficultyTier,
                      triviaFact: c.triviaFact,
                      tiles: [
                        for (final t in c.tiles)
                          Tile(
                            levelId: 'fixture${p}_$i',
                            categoryId: c.id,
                            ordinal: t.ordinal,
                            difficultyTier: t.difficultyTier,
                            // A real ten-letter synonym for a small amount.
                            text:
                                i == 7 &&
                                    c.difficultyTier == 2 &&
                                    t.ordinal == 3
                                ? 'SMATTERING'
                                : t.text,
                          ),
                      ],
                    ),
                ],
                redHerrings: l.redHerrings,
              ),
          ],
        ),
    ],
  );
}

Future<void> fixtureApp(
  WidgetTester t,
  Catalog catalog,
  MemoryProgressStorage store,
) async {
  await t.pumpWidget(
    LexiStackApp(
      storage: store,
      clock: fixture.TestClock().call,
      loadCatalog: () async => ValidationReport(
        mode: ValidationMode.partial,
        catalog: catalog,
        diagnostics: [],
        packs: [],
        candidate: null,
        meetsStrictMinimum: false,
        isInitialBenchmark: false,
      ),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
    'UI-03 four packs keep independent locks; Play Resume View Result Replay and Next work',
    (t) async {
      viewport(t, const Size(390, 844));
      final catalog = fourPacks();
      await fixtureApp(t, catalog, MemoryProgressStorage());
      await tapVisible(t, find.text('Campaign'));
      for (final pack in catalog.packs) {
        final card = find.ancestor(
          of: find.text(pack.title),
          matching: find.byType(PackCard),
        );
        await t.scrollUntilVisible(
          find.text(pack.title),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await t.pumpAndSettle();
        await tapVisible(
          t,
          find.descendant(of: card, matching: find.text('Explore collection')),
        );
        final locked = find.byKey(ValueKey('level-${pack.levels[1].id}'));
        expect(t.widget<InkWell>(locked).onTap, isNull);
        await tapVisible(t, locked);
        expect(find.byType(LevelEntryScreen), findsNothing);
        t
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .jumpTo(0);
        await t.pumpAndSettle();
        await tapVisible(t, find.text('Table Talk'));
        await tapVisible(t, find.text('Play'));
        expect(board(t).game.level.packId, pack.id);
        await tapVisible(t, tile('TOAST'));
        await t.pageBack();
        await t.pumpAndSettle();
        await tapVisible(t, find.text('Resume'));
        expect(board(t).game.selection.length, 1);
        await t.pageBack();
        await t.pumpAndSettle();
        await t.pageBack();
        await t.pumpAndSettle();
        await t.pageBack();
        await t.pumpAndSettle();
      }
      await t.pageBack();
      await t.pumpAndSettle();
      t
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await t.pumpAndSettle();
      await tapVisible(t, find.text('Continue Campaign'));
      expect(board(t).game.level.packId, 'fixture4');
      for (final c in board(t).game.level.categories) {
        await submitWords(t, c.tiles.map((x) => x.text).toList());
      }
      final p = board(t).progress;
      final count = p.state.sequence;
      await tapVisible(t, find.text('Next connection'));
      // Continue prioritizes an existing unfinished attempt in another pack.
      expect(board(t).game.level.packId, 'fixture3');
      expect(p.state.results.length, 1);
      expect(p.state.sequence, count + 1);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'UI-03 all-won Continue opens pack selector without creating replay',
    (t) async {
      viewport(t, const Size(390, 844));
      final catalog = fourPacks();
      final store = MemoryProgressStorage();
      final p = await fixture.player(store: store, catalog: catalog);
      for (final pack in catalog.packs) {
        for (final level in pack.levels) {
          final b = BoardController(p, p.enterCampaign(level)!);
          fixture.win(b);
          b.dispose();
        }
      }
      await p.flush();
      final saved = store.value;
      await fixtureApp(t, catalog, store);
      await tapVisible(t, find.text('Continue Campaign'));
      expect(find.byType(PacksScreen), findsOneWidget);
      expect(find.byType(BoardScreen), findsNothing);
      expect(store.value, saved);
    },
  );

  for (final (size, scale) in [
    (const Size(360, 640), 1.3),
    (const Size(390, 844), 1.0),
    (const Size(390, 844), 1.3),
    (const Size(1280, 800), 1.3),
  ]) {
    for (final dark in [false, true]) {
      testWidgets(
        'UI-10 long groups, two-word tiles, 2 solves, full result and Settings $size scale=$scale dark=$dark',
        (t) async {
          viewport(t, size, scale: scale);
          final catalog = fourPacks();
          final store = MemoryProgressStorage();
          final p = await fixture.player(store: store, catalog: catalog);
          p.setSettings(theme: dark ? 'dark' : 'light');
          // The final fixture combines whole-word phrases and a ten-letter tile.
          for (final level in catalog.packs.first.levels.take(7)) {
            final b = BoardController(p, p.enterCampaign(level)!);
            fixture.win(b);
            b.dispose();
          }
          p.enterCampaign(catalog.packs.first.levels[7]);
          await p.flush();
          await fixtureApp(t, catalog, store);
          if (size.width > 520) {
            final frame = t.getRect(find.byKey(const Key('app-frame')));
            expect(frame.width, 460);
            expect(frame.center.dx, size.width / 2);
          }
          await tapVisible(t, find.text('Continue Campaign'));
          expect(find.text('CLOVE\nHITCH'), findsOneWidget);
          expect(find.text('SHEET\nBEND'), findsOneWidget);
          expect(find.text('SMATTERING'), findsOneWidget);
          final categories = board(t).game.level.categories;
          for (final c in categories.take(2)) {
            await submitWords(t, c.tiles.map((x) => x.text).toList());
          }
          expect(board(t).game.solvedIds.length, 2);
          expect(board(t).game.order.length, 8);
          expect(find.textContaining('A longer category title'), findsWidgets);
          await tapVisible(t, find.text('Category Peek · 40'));
          for (final word in categories[2].tiles) {
            await tapVisible(t, tile(word.text));
          }
          expect(find.textContaining('Selected 4/4'), findsOneWidget);
          expect(
            t.widget<FilledButton>(find.byKey(const Key('submit'))).onPressed,
            isNotNull,
          );
          await tapVisible(t, find.byKey(const Key('submit')));
          await submitWords(t, categories[3].tiles.map((x) => x.text).toList());
          await tapVisible(t, find.text('The red herrings'));
          expect(t.takeException(), isNull);
          await t.pageBack();
          await t.pumpAndSettle();
          await tapVisible(t, find.byTooltip('Settings'));
          await tapVisible(t, find.text('Reset progress'));
          expect(find.text('Reset all progress?'), findsOneWidget);
          await tapVisible(t, find.text('Cancel'));
          expect(t.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'UI-11 keyboard focus activates the same tile action without bypassing cap',
    (t) async {
      viewport(t, const Size(390, 844));
      await fixtureApp(t, fourPacks(), MemoryProgressStorage());
      await tapVisible(t, find.text('Continue Campaign'));
      await tapVisible(t, tile('TOAST'));
      final ink = t.widget<InkWell>(tile('TOAST'));
      expect(ink.canRequestFocus, isTrue);
      // Focus.of resolves the InkWell focus from its rendered child.
      Focus.of(
        t.element(
          find.descendant(
            of: tile('TOAST'),
            matching: find.byType(AnimatedScale),
          ),
        ),
      ).requestFocus();
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(board(t).game.selection, isEmpty);
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, isNotNull);
      expect(t.takeException(), isNull);
    },
  );
}
