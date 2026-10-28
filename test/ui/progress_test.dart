import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/ui/app.dart';
import 'package:lexistack/ui/board_screen.dart';

import '../app_test.dart' show TestBundle;
import '../support/progress_fixture.dart'
    show TestClock, player, firstBoard, win;
import 'board_test.dart'
    show enterBoard, viewport, tapVisible, submitWords, pendingLoss, tile;

BoardController board(WidgetTester t) =>
    t.widget<BoardScreen>(find.byType(BoardScreen)).controller;
Future<void> solve(WidgetTester t) async {
  for (final c in board(t).game.remainingCategories) {
    await submitWords(t, c.tiles.map((t) => t.text).toList());
  }
}

Future<void> home(
  WidgetTester t,
  MemoryProgressStorage storage,
  TestClock clock,
) async {
  await t.pumpWidget(
    LexiStackApp(bundle: TestBundle(), storage: storage, clock: clock.call),
  );
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
    'F3-R01 read failure hides gameplay and save controls; Retry load restores progress',
    (t) async {
      viewport(t, const Size(360, 640), scale: 1.3);
      final clock = TestClock();
      final store = MemoryProgressStorage();
      final original = await player(store: store, clock: clock);
      final active = firstBoard(original);
      win(active);
      active.newAttempt();
      active.pairMagnet();
      await original.flush();
      final document = store.value;
      final writeCount = store.writes.length;
      store.failRead = true;
      await home(t, store, clock);
      expect(find.byKey(const Key('load-warning')), findsOneWidget);
      expect(
        find.textContaining('Saved progress could not be loaded.'),
        findsOneWidget,
      );
      expect(find.text('Retry load'), findsOneWidget);
      expect(find.text('Retry save'), findsNothing);
      expect(find.byKey(const Key('storage-warning')), findsNothing);
      expect(find.byKey(const Key('wallet')), findsNothing);
      expect(find.byKey(const Key('stats-summary')), findsNothing);
      expect(find.text('Continue Campaign'), findsNothing);
      expect(find.text('Explore collection'), findsNothing);
      expect(find.text('Play Daily'), findsNothing);
      expect(find.text('Reset progress'), findsNothing);
      await tapVisible(t, find.text('Retry load'));
      expect(find.byKey(const Key('load-warning')), findsOneWidget);
      expect(store.value, document);
      expect(store.writes, hasLength(writeCount));

      store.failRead = false;
      await tapVisible(t, find.text('Retry load'));
      expect(find.byKey(const Key('load-warning')), findsNothing);
      expect(find.text('Retry load'), findsNothing);
      expect(find.text('Retry save'), findsNothing);
      expect(find.text('170 coins'), findsOneWidget);
      expect(find.textContaining('1 game played'), findsOneWidget);
      expect(store.value, document);
      expect(store.writes, hasLength(writeCount));
      await tapVisible(t, find.text('Continue Campaign'));
      expect(board(t).attempt.id, active.attempt.id);
      expect(board(t).game.snapshot(), active.game.snapshot());
      expect(board(t).coins, 170);
      expect(board(t).progress.state.results, hasLength(1));
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'F3 actual first win, paid hint, explicit replay reward and saved result',
    (t) async {
      viewport(t, const Size(390, 844));
      final store = MemoryProgressStorage();
      await enterBoard(t, store: store);
      await tapVisible(t, find.text('Pair Magnet · 30'));
      expect(board(t).coins, 120);
      expect(find.text('Pair 1'), findsNWidgets(2));
      await solve(t);
      expect(find.text('+50 coins awarded for this attempt'), findsOneWidget);
      expect(find.text('170 coins'), findsOneWidget);
      expect(board(t).progress.state.gamesPlayed, 1);
      await tapVisible(t, find.text('Back to level'));
      await tapVisible(t, find.text('View saved result'));
      expect(board(t).coins, 170);
      expect(board(t).progress.state.gamesPlayed, 1);
      final old = board(t).attempt.id;
      await tapVisible(t, find.text('Replay · New attempt'));
      expect(board(t).attempt.id, isNot(old));
      await solve(t);
      expect(find.text('+5 coins awarded for this attempt'), findsOneWidget);
      expect(board(t).coins, 175);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'F3 unaffordable pending rescue disabled; explicit reveal still works',
    (t) async {
      viewport(t, const Size(360, 640), scale: 1.3);
      await enterBoard(t);
      await tapVisible(t, find.text('Category Peek · 40'));
      await tapVisible(t, find.text('Pair Magnet · 30'));
      await tapVisible(t, find.text('Pair Magnet · 30'));
      expect(board(t).coins, 50);
      await pendingLoss(t);
      expect(
        t.widget<FilledButton>(find.byKey(const Key('rescue'))).onPressed,
        isNull,
      );
      for (final c in board(t).game.level.categories) {
        expect(find.textContaining(c.title), findsNothing);
        expect(find.text(c.triviaFact), findsNothing);
      }
      expect(find.textContaining('Not enough coins to rescue'), findsOneWidget);
      await tapVisible(t, find.byKey(const Key('reveal-loss')));
      expect(board(t).coins, 50);
      expect(board(t).progress.state.gamesPlayed, 1);
      expect(find.text('Loss accepted · Solutions revealed'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'F3 production app reconstruction retains paid hints selection order and shuffle',
    (t) async {
      viewport(t, const Size(390, 844));
      final store = MemoryProgressStorage();
      final clock = TestClock();
      await enterBoard(t, store: store, clock: clock);
      await tapVisible(t, tile('TOAST'));
      await tapVisible(t, tile('SERVE'));
      await tapVisible(t, find.text('Pair Magnet · 30'));
      await tapVisible(t, find.text('Category Peek · 40'));
      await tapVisible(t, find.text('Shuffle'));
      final before = jsonEncode(board(t).game.snapshot());
      final id = board(t).attempt.id;
      await board(t).progress.flush();
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle();
      await enterBoard(t, store: store, clock: clock);
      expect(jsonEncode(board(t).game.snapshot()), before);
      expect(board(t).attempt.id, id);
      expect(board(t).coins, 80);
      expect(find.text('Peek: BREAKFAST BAKES'), findsOneWidget);
      expect(find.text('Pair 1'), findsNWidgets(2));
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'F3 Daily real UI result/reentry cannot repeat payout across reconstruction',
    (t) async {
      viewport(t, const Size(390, 844));
      final store = MemoryProgressStorage();
      final clock = TestClock();
      await home(t, store, clock);
      await tapVisible(t, find.text('Play Daily'));
      expect(find.text('Daily 2026-10-28'), findsOneWidget);
      expect(board(t).game.level.id, 'daily_lvl05');
      await solve(t);
      expect(board(t).coins, 225);
      expect(find.byKey(const Key('share-data')), findsOneWidget);
      expect(find.text('Replay · New attempt'), findsNothing);
      await board(t).progress.flush();
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle();
      await home(t, store, clock);
      await tapVisible(t, find.text('View Daily result'));
      expect(board(t).coins, 225);
      expect(board(t).progress.state.gamesPlayed, 1);
      expect(find.text('+75 coins awarded for this attempt'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'F3 midnight stale screen rejects purchase; resume and next Daily use new date',
    (t) async {
      viewport(t, const Size(390, 844));
      final store = MemoryProgressStorage();
      final clock = TestClock(DateTime(2028, 2, 28, 23, 59));
      await home(t, store, clock);
      await tapVisible(t, find.text('Play Daily'));
      final oldId = board(t).attempt.id;
      await tapVisible(t, find.text('Category Peek · 40'));
      clock.day(1);
      // The already rendered enabled control is intentionally stale at this tap.
      await tapVisible(t, find.text('Pair Magnet · 30'));
      expect(board(t).coins, 110);
      expect(board(t).game.pairs, isEmpty);
      expect(find.textContaining('A new day has begun'), findsOneWidget);
      await tapVisible(t, find.text('Back to level'));
      await tapVisible(t, find.text('Play Daily'));
      expect(board(t).date, '2028-02-29');
      expect(board(t).attempt.id, isNot(oldId));
      expect(board(t).progress.state.gamesPlayed, 0);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'F3 visible save failure, retry, Reset cancellation/confirmation and reopen',
    (t) async {
      viewport(t, const Size(390, 844));
      final store = MemoryProgressStorage()..failWrites = 1;
      final clock = TestClock();
      await enterBoard(t, store: store, clock: clock);
      expect(find.byKey(const Key('storage-warning')), findsOneWidget);
      expect(find.textContaining('Progress not saved.'), findsOneWidget);
      await tapVisible(t, find.text('Retry save'));
      expect(find.byKey(const Key('storage-warning')), findsNothing);
      await tapVisible(t, find.text('Pair Magnet · 30'));
      final controller = board(t).progress;
      await t.pageBack();
      await t.pumpAndSettle();
      await t.pageBack();
      await t.pumpAndSettle();
      await t.pageBack();
      await t.pumpAndSettle();
      await tapVisible(t, find.byTooltip('Settings'));
      await tapVisible(t, find.text('Reset progress'));
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();
      expect(controller.state.coins, 120);
      await tapVisible(t, find.text('Reset progress'));
      await t.tap(find.widgetWithText(TextButton, 'Reset progress').last);
      await t.pumpAndSettle();
      expect(controller.state.coins, 150);
      expect(controller.state.attempts, isEmpty);
      expect(controller.state.gamesPlayed, 0);
      await controller.flush();
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle();
      await home(t, store, clock);
      expect(find.text('150 coins'), findsOneWidget);
      expect(find.textContaining('0 games played'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
}
