import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/core/game.dart';
import 'package:lexistack/ui/app.dart';
import 'package:lexistack/ui/catalog_screens.dart';
import 'package:lexistack/ui/common.dart';
import 'package:lexistack/ui/theme.dart';

import '../support/content_fixture.dart' show initialCatalog;
import '../support/progress_fixture.dart';
import 'board_test.dart' show viewport, tapVisible, submitWords, tile;
import 'progress_test.dart' show board;

Future<void> app(WidgetTester t, MemoryProgressStorage store) async {
  // Intentionally no TestBundle: exercise production asset registration.
  await t.pumpWidget(LexiStackApp(storage: store, clock: TestClock().call));
  await t.pumpAndSettle();
}

Future<void> openPack(WidgetTester t, String title) async {
  final card = find.ancestor(
    of: find.text(title),
    matching: find.byType(PackCard),
  );
  await tapVisible(
    t,
    find.descendant(of: card, matching: find.text('Explore collection')),
  );
}

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

  testWidgets(
    'F5 real bundle shelf: all five packs, eight stages, independent progress, new boards',
    (t) async {
      viewport(t, const Size(390, 844));
      final catalog = installedCatalog();
      final p = await player();
      win(
        BoardController(p, p.enterCampaign(p.campaignPacks[1].levels.first)!),
      );
      await p.flush();
      await app(t, p.storage as MemoryProgressStorage);
      expect(find.text('Campaign · 1 / 40 stages solved'), findsOneWidget);
      await tapVisible(t, find.text('Campaign'));
      expect(find.byType(PackCard), findsNWidgets(5));
      expect(find.text('Daily Stack'), findsNothing);
      for (final pack in catalog.packs.take(5)) {
        expect(find.text(pack.title), findsOneWidget);
        expect(find.text(pack.description), findsOneWidget);
        final card = find.ancestor(
          of: find.text(pack.title),
          matching: find.byType(PackCard),
        );
        expect(
          find.descendant(
            of: card,
            matching: find.text(
              '${pack.id == 'pack2' ? 1 : 0} / 8 solved · Available offline',
            ),
          ),
          findsOneWidget,
        );
        await openPack(t, pack.title);
        expect(
          find.text('8 levels · Win a stage to unlock the next'),
          findsOneWidget,
        );
        for (final (i, level) in pack.levels.indexed) {
          final entry = find.byKey(ValueKey('level-${level.id}'));
          expect(entry, findsOneWidget);
          expect(
            t.widget<InkWell>(entry).onTap != null,
            i == 0 || (pack.id == 'pack2' && i == 1),
          );
          if (i == 0) {
            final stars = find.descendant(
              of: entry,
              matching: find.byType(StarRow),
            );
            expect(t.widget<StarRow>(stars).stars, pack.id == 'pack2' ? 3 : 0);
          }
        }
        await tapVisible(
          t,
          find.byKey(ValueKey('level-${pack.levels.first.id}')),
        );
        expect(find.text('${pack.title} · Level 1'), findsOneWidget);
        await tapVisible(
          t,
          find.text(pack.id == 'pack2' ? 'Replay · New attempt' : 'Play'),
        );
        expect(board(t).game.level.id, pack.levels.first.id);
        expect(board(t).game.order, hasLength(16));
        await submitWords(
          t,
          pack.levels.first.categories.first.tiles.map((t) => t.text).toList(),
        );
        expect(board(t).game.solvedIds, [
          pack.levels.first.categories.first.id,
        ]);
        expect(
          find.text(pack.levels.first.categories.first.triviaFact),
          findsOneWidget,
        );
        if (pack.id == 'pack3') {
          for (final category in pack.levels.first.categories.skip(1)) {
            await submitWords(t, category.tiles.map((t) => t.text).toList());
          }
          expect(board(t).game.status, GameStatus.won);
        }
        for (var back = 0; back < 3; back++) {
          await t.pageBack();
          await t.pumpAndSettle();
        }
        expect(find.byType(PacksScreen), findsOneWidget);
        if (pack.id == 'pack3') {
          expect(
            find.descendant(
              of: card,
              matching: find.text('1 / 8 solved · Available offline'),
            ),
            findsOneWidget,
            reason:
                'The existing shelf route must refresh immediately after a win',
          );
        }
        expect(t.takeException(), isNull);
      }
    },
  );

  for (final (size, scale) in [
    (const Size(360, 640), 1.3),
    (const Size(390, 844), 1.0),
    (const Size(1280, 800), 1.0),
  ]) {
    testWidgets(
      'F5 real long labels and intended group interaction at $size/$scale',
      (t) async {
        viewport(t, size, scale: scale);
        for (final title in [
          'SCIENTISTS WITH ELEMENT NAMESAKES',
          'WORDS USING ONLY ROMAN NUMERAL LETTERS',
          'BEGIN AND END WITH THE SAME LETTER',
        ]) {
          final p = await player();
          final pack = p.campaignPacks.firstWhere(
            (p) =>
                p.levels.any((l) => l.categories.any((c) => c.title == title)),
          );
          final level = pack.levels.firstWhere(
            (l) => l.categories.any((c) => c.title == title),
          );
          for (final earlier in pack.levels.takeWhile(
            (l) => l.id != level.id,
          )) {
            win(BoardController(p, p.enterCampaign(earlier)!));
          }
          p.enterCampaign(level);
          await p.flush();
          await t.pumpWidget(const SizedBox());
          await app(t, p.storage as MemoryProgressStorage);
          await tapVisible(t, find.text('Continue Campaign'));
          expect(board(t).game.level.id, level.id);
          final category = level.categories.firstWhere((c) => c.title == title);
          for (final word in level.tiles) {
            expect(tile(word.text), findsOneWidget);
            expect(
              t.getSize(tile(word.text)).shortestSide,
              greaterThanOrEqualTo(48),
            );
          }
          await submitWords(t, category.tiles.map((t) => t.text).toList());
          expect(board(t).game.solvedIds, [category.id]);
          expect(board(t).game.lives, 4);
          final reveal = find.text('Tier ${category.difficultyTier} · $title');
          expect(reveal, findsOneWidget);
          await t.ensureVisible(reveal);
          await t.pumpAndSettle();
          final paragraph = t.renderObject<RenderParagraph>(reveal);
          expect(paragraph.didExceedMaxLines, isFalse);
          expect(find.text(category.triviaFact), findsOneWidget);
          final submit = find.byKey(const Key('submit'));
          expect(submit.hitTestable(), findsOneWidget);
          expect(t.getRect(submit).bottom, lessThanOrEqualTo(size.height));
          if (size.width > 520) {
            final frame = t.getRect(find.byKey(const Key('app-frame')));
            expect(frame.width, 460);
            expect(frame.center.dx, size.width / 2);
          }
          expect(t.takeException(), isNull);
        }
      },
    );
  }

  testWidgets(
    'F5 all Campaign won opens shelf; explicit replay remains available',
    (t) async {
      viewport(t, const Size(390, 844));
      final p = await player();
      for (final level in p.campaignPacks.expand((p) => p.levels)) {
        win(BoardController(p, p.enterCampaign(level)!));
      }
      await p.flush();
      await app(t, p.storage as MemoryProgressStorage);
      expect(find.text('Campaign · 40 / 40 stages solved'), findsOneWidget);
      await tapVisible(t, find.text('Continue Campaign'));
      expect(find.byType(PacksScreen), findsOneWidget);
      await openPack(t, p.campaignPacks.last.title);
      await tapVisible(t, find.text(p.campaignPacks.last.levels.first.title));
      await tapVisible(t, find.text('Replay · New attempt'));
      expect(board(t).game.status, GameStatus.playing);
      expect(board(t).game.level.id, 'pack5_lvl01');
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('Pack 5 all eight boards, tier colors, results, Continue and replay', (t) async {
    viewport(t, const Size(390, 844));
    final old = await player(catalog: initialCatalog());
    for (final level in old.campaignPacks.expand((p) => p.levels)) {
      win(BoardController(old, old.enterCampaign(level)!));
    }
    await old.flush();
    await app(t, old.storage as MemoryProgressStorage);
    expect(find.text('Campaign · 32 / 40 stages solved'), findsOneWidget);
    await tapVisible(t, find.text('Continue Campaign'));
    final pack = installedCatalog().packs[4];
    for (final (index, level) in pack.levels.indexed) {
      expect(board(t).game.level.id, level.id);
      expect(find.text('${index + 1} · ${level.title}'), findsOneWidget);
      expect(board(t).game.order, hasLength(16));
      for (final category in level.categories) {
        await submitWords(t, category.tiles.map((t) => t.text).toList());
        expect(board(t).game.guesses.last.tiers, List.filled(4, category.difficultyTier));
        final label = find.text('Tier ${category.difficultyTier} · ${category.title}');
        expect(label, findsOneWidget);
        final card = t.widget<Container>(find.byKey(ValueKey('category-${category.id}')));
        expect((card.decoration! as BoxDecoration).color, tierColors[category.difficultyTier - 1]);
        if (level.id == 'pack5_lvl04' && category.difficultyTier == 1) {
          // Tier 2 is last in the source array, but must be hinted next.
          final tier2 = level.categories.singleWhere((c) => c.difficultyTier == 2);
          await tapVisible(t, find.text('Boosters'));
          await tapVisible(t, find.text('Category Peek · 40'));
          expect(board(t).game.peekedIds, [tier2.id]);
          await tapVisible(t, find.text('Pair Magnet · 30'));
          expect(board(t).game.pairs.keys, [tier2.id]);
        }
      }
      expect(board(t).game.status, GameStatus.won);
      expect(find.text('You found every connection!'), findsOneWidget);
      for (final category in level.categories) {
        expect(find.text(category.triviaFact), findsOneWidget);
      }
      for (final hint in level.redHerrings) {
        expect(find.text(hint.note), findsOneWidget);
      }
      expect(board(t).result!.reward, 50);
      expect(t.takeException(), isNull);
      await tapVisible(t, find.text('Next connection'));
    }
    expect(find.byType(PacksScreen), findsOneWidget);
    await openPack(t, pack.title);
    await tapVisible(t, find.byKey(ValueKey('level-${pack.levels.last.id}')));
    await tapVisible(t, find.text('Replay · New attempt'));
    expect(board(t).game.level.id, 'pack5_lvl08');
    expect(board(t).game.order, hasLength(16));
    expect(board(t).game.status, GameStatus.playing);
    expect(t.takeException(), isNull);
  });
}
