import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/core/game.dart';
import 'package:lexistack/ui/app.dart';
import 'package:lexistack/ui/board_screen.dart';

import '../app_test.dart' show TestBundle;

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      150,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enterBoard(WidgetTester tester) async {
  await tester.pumpWidget(LexiStackApp(bundle: TestBundle()));
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('Explore collection'),
    150,
    scrollable: find.byType(Scrollable).first,
  );
  await tapVisible(tester, find.text('Explore collection'));
  await tapVisible(tester, find.text('Table Talk'));
  await tapVisible(tester, find.text('Play / Resume preview'));
}

Finder tile(String word) => find.byKey(ValueKey('tile-$word'));
Game game(WidgetTester t) =>
    t.widget<BoardScreen>(find.byType(BoardScreen)).controller.game;

Future<void> submitWords(WidgetTester tester, List<String> words) async {
  if (game(tester).selection.isNotEmpty) {
    await tapVisible(tester, find.text('Deselect'));
  }
  for (final word in words) {
    await tapVisible(tester, tile(word));
  }
  await tapVisible(tester, find.byKey(const Key('submit')));
}

const wrongs = [
  ['TOAST', 'WAFFLE', 'MUFFIN', 'FORK'],
  ['TOAST', 'WAFFLE', 'FORK', 'SPOON'],
  ['TOAST', 'FORK', 'SERVE', 'TRAFFIC'],
  ['WAFFLE', 'SPOON', 'LOVE', 'PAPER'],
];

Future<void> pendingLoss(WidgetTester tester) async {
  for (final row in wrongs) {
    await submitWords(tester, row);
  }
}

void viewport(WidgetTester tester, Size size, {double scale = 1}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

void main() {
  testWidgets(
    'UI-02 real pack1 Play, selection cap, solve reveals exact title and trivia',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await enterBoard(tester);
      expect(game(tester).order, hasLength(16));
      expect(
        tester.widget<FilledButton>(find.byKey(const Key('submit'))).onPressed,
        isNull,
      );
      for (final word in ['TOAST', 'WAFFLE', 'MUFFIN', 'BAGEL', 'FORK']) {
        await tapVisible(tester, tile(word));
      }
      expect(game(tester).selection.map(game(tester).tile).map((t) => t.text), [
        'TOAST',
        'WAFFLE',
        'MUFFIN',
        'BAGEL',
      ]);
      await tapVisible(tester, find.byKey(const Key('submit')));
      expect(game(tester).order, hasLength(12));
      expect(game(tester).lives, 4);
      expect(tile('TOAST'), findsNothing);
      expect(find.text('Tier 1 · BREAKFAST BAKES'), findsOneWidget);
      expect(
        find.text(
          'A bagel is traditionally boiled before baking, which helps create its chewy crust.',
        ),
        findsOneWidget,
      );
      expect(find.text('Correct! BREAKFAST BAKES'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'actual UI One Away and reversed duplicate are distinct from mismatch',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await enterBoard(tester);
      await submitWords(tester, wrongs[0]);
      expect(
        find.text('One Away! Change one word and try again.'),
        findsOneWidget,
      );
      expect(game(tester).lives, 3);
      await submitWords(tester, wrongs[0].reversed.toList());
      expect(find.text('Already guessed! No life lost.'), findsOneWidget);
      expect(game(tester).lives, 3);
      expect(game(tester).guesses, hasLength(1));
      await submitWords(tester, wrongs[1]);
      expect(
        find.text('Not a group. Try a different connection.'),
        findsOneWidget,
      );
      expect(game(tester).lives, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'actual long-press drag to tile and tray adds without release toggle',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await enterBoard(tester);
      final drag = await tester.startGesture(tester.getCenter(tile('VOLLEY')));
      await tester.pump(const Duration(milliseconds: 600));
      await drag.moveTo(tester.getCenter(tile('PEARL')));
      await tester.pump(const Duration(milliseconds: 100));
      await drag.up();
      await tester.pumpAndSettle();
      expect(game(tester).selection.map(game(tester).tile).map((t) => t.text), [
        'VOLLEY',
        'PEARL',
      ]);
      final tray = find.byKey(const Key('selection-tray'));
      await tester.ensureVisible(tray);
      await tester.pumpAndSettle();
      final second = await tester.startGesture(tester.getCenter(tile('DEUCE')));
      await tester.pump(const Duration(milliseconds: 600));
      await second.moveTo(tester.getCenter(tray));
      await tester.pump(const Duration(milliseconds: 100));
      await second.up();
      await tester.pumpAndSettle();
      expect(game(tester).selection.map(game(tester).tile).map((t) => t.text), [
        'VOLLEY',
        'PEARL',
        'DEUCE',
      ]);
      await tapVisible(tester, tile('DEUCE'));
      expect(game(tester).selection, hasLength(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'pending loss conceals even peeked solutions, resumes on navigation, rescue and final reveal',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await enterBoard(tester);
      final attempt = game(tester);
      await tapVisible(tester, find.text('Category Peek'));
      expect(find.text('Peek: BREAKFAST BAKES'), findsOneWidget);
      await tapVisible(tester, find.text('Pair Magnet'));
      expect(attempt.pairs, hasLength(1));
      await pendingLoss(tester);
      expect(attempt.status, GameStatus.lostPendingDecision);
      for (final category in attempt.level.categories) {
        expect(find.textContaining(category.title), findsNothing);
        expect(find.text(category.triviaFact), findsNothing);
      }
      expect(find.text(attempt.level.redHerrings.first.note), findsNothing);
      expect(find.byKey(const Key('tile-grid')), findsNothing);
      await tapVisible(tester, find.text('Back to level'));
      await tapVisible(tester, find.text('Play / Resume preview'));
      expect(identical(game(tester), attempt), isTrue);
      expect(find.text('Out of lives · Your choice'), findsOneWidget);
      final order = attempt.order;
      final selected = attempt.selection;
      final rows = attempt.guesses;
      await tapVisible(tester, find.byKey(const Key('rescue')));
      expect(attempt.status, GameStatus.playing);
      expect(attempt.lives, 1);
      expect(attempt.order, order);
      expect(attempt.selection, selected);
      expect(attempt.guesses, rows);
      await submitWords(tester, ['MUFFIN', 'KNIFE', 'DEUCE', 'LOG']);
      expect(attempt.status, GameStatus.lostPendingDecision);
      await tapVisible(tester, find.byKey(const Key('reveal-loss')));
      expect(attempt.status, GameStatus.lostFinal);
      for (final category in attempt.level.categories) {
        expect(
          find.text('Tier ${category.difficultyTier} · ${category.title}'),
          findsOneWidget,
        );
        expect(find.text(category.triviaFact), findsOneWidget);
      }
      expect(find.text(attempt.level.redHerrings.first.note), findsOneWidget);
      expect(find.byKey(const Key('rescue')), findsNothing);
      await tapVisible(tester, find.text('Back to level'));
      await tapVisible(tester, find.text('Play / Resume preview'));
      expect(game(tester).status, GameStatus.lostFinal);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'all four real groups win; replay is explicit and active reset confirms',
    (tester) async {
      viewport(tester, const Size(390, 844));
      await enterBoard(tester);
      final original = game(tester);
      await tapVisible(tester, tile('TOAST'));
      await tapVisible(tester, find.text('Back to level'));
      await tapVisible(tester, find.text('Play / Resume preview'));
      expect(identical(game(tester), original), isTrue);
      expect(original.selection, hasLength(1));
      await tapVisible(tester, find.text('New attempt'));
      await tester.tap(find.text('Keep playing'));
      await tester.pumpAndSettle();
      expect(identical(game(tester), original), isTrue);
      await tapVisible(tester, find.text('New attempt'));
      await tester.tap(find.text('Start new attempt'));
      await tester.pumpAndSettle();
      expect(identical(game(tester), original), isFalse);
      expect(game(tester).selection, isEmpty);
      for (final category in game(tester).level.categories) {
        await submitWords(tester, category.tiles.map((t) => t.text).toList());
      }
      expect(game(tester).status, GameStatus.won);
      expect(find.text('★★★ · 0 mistakes'), findsOneWidget);
      expect(
        find.text(game(tester).level.redHerrings.first.note),
        findsOneWidget,
      );
      await tapVisible(tester, find.text('Replay · New attempt'));
      expect(game(tester).status, GameStatus.playing);
      expect(game(tester).order, hasLength(16));
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [
    const Size(360, 640),
    const Size(390, 844),
    const Size(1280, 800),
  ]) {
    testWidgets(
      'F2 board, pending decision and results usable at $size with 1.3x text',
      (tester) async {
        viewport(tester, size, scale: 1.3);
        await enterBoard(tester);
        final gridSize = tester.getSize(find.byKey(const Key('tile-grid')));
        expect(gridSize.width, lessThanOrEqualTo(460));
        for (final word in game(tester).level.tiles.map((t) => t.text)) {
          final target = tester.getSize(tile(word));
          expect(target.width, greaterThanOrEqualTo(48));
          expect(target.height, greaterThanOrEqualTo(48));
        }
        await pendingLoss(tester);
        await tapVisible(tester, find.byKey(const Key('rescue')));
        for (final category in game(tester).level.categories) {
          await submitWords(tester, category.tiles.map((t) => t.text).toList());
        }
        expect(find.text('★☆☆ · 4 mistakes'), findsOneWidget);
        await tapVisible(tester, find.text('Replay · New attempt'));
        await pendingLoss(tester);
        await tapVisible(tester, find.byKey(const Key('reveal-loss')));
        await tapVisible(tester, find.text('Back to level'));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
