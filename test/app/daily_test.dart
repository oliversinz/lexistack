import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/progress.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/core/daily.dart';
import 'package:lexistack/core/game.dart';
import 'package:lexistack/core/share.dart';

import '../support/progress_fixture.dart';

void main() {
  test(
    'DAY-01/02 independent civil-day and seed goldens including DST and leap',
    () {
      final cases = {
        '2025-12-31': (-1, 7, 2147483646),
        '2026-01-01': (0, 0, 1),
        '2026-01-09': (8, 0, 9),
        '2026-03-08': (66, 2, 67), // US spring transition
        '2026-03-29': (87, 7, 88), // Europe spring transition
        '2026-10-25': (297, 1, 298), // Europe autumn transition
        '2026-10-28': (300, 4, 301),
        '2026-11-01': (304, 0, 305), // US autumn transition
        '2028-02-28': (788, 4, 789),
        '2028-02-29': (789, 5, 790),
        '2028-03-01': (790, 6, 791),
      };
      for (final e in cases.entries) {
        final day = parseDay(e.key);
        for (final hour in [0, 1, 12, 23]) {
          final local = DateTime(day.year, day.month, day.day, hour, 59);
          expect(dailyIndex(local), e.value.$1, reason: e.key);
          expect(dailyPoolIndex(local, 8), e.value.$2);
          expect(dailySeed(local), e.value.$3);
        }
      }
      for (final bad in [
        '2028-02-30',
        '2026-2-01',
        '0000-01-01',
        '2026-13-01',
        'junk',
      ]) {
        expect(() => parseDay(bad), throwsFormatException);
      }
    },
  );

  test('DAY-02 same civil date gives identical fresh board; cycle repeats only the level', () async {
    final clock = TestClock();
    final p = await player(clock: clock);
    final a = p.enterDaily()!;
    expect(a.levelId, 'daily_lvl05');
    expect(a.game.seed, 301);
    final other = await player(clock: clock);
    expect(other.enterDaily()!.game.order, a.game.order);
    expect(p.enterDaily(), same(a));
    clock.day(8);
    final next = p.enterDaily()!;
    expect(next.levelId, a.levelId);
    expect(next.game.seed, 309);
    expect(next.id, isNot(a.id));
    expect(next.game.order, isNot(a.game.order));
    expect(p.state.gamesPlayed, 0);
  });

  test(
    'DAY-03/04 finalized Daily reopens one result and reward once; no replay',
    () async {
      final store = MemoryProgressStorage();
      final clock = TestClock();
      var p = await player(store: store, clock: clock);
      final b = BoardController(p, p.enterDaily()!);
      win(b);
      expect(p.state.coins, 225);
      expect(p.state.results.single.reward, 75);
      final id = b.attempt.id;
      b.newAttempt();
      expect(b.attempt.id, id);
      expect(p.enterDaily()!.id, id);
      expect(
        b.result!.shareText,
        formatShare(b.game, DailyHeader(clock.value)),
      );
      expect(
        b.result!.shareText,
        startsWith('LexiStack · Daily 2026-10-28\n★★★ · 0 mistakes\n'),
      );
      for (final tile in b.game.level.tiles) {
        expect(b.result!.shareText, isNot(contains(tile.text)));
      }
      await p.flush();
      p = await player(store: store, clock: clock);
      expect(p.enterDaily()!.id, id);
      expect(p.state.coins, 225);
      expect(p.state.gamesPlayed, 1);
      expect(p.recoveryNotice, isNull);
      clock.day(8);
      final next = BoardController(p, p.enterDaily()!);
      win(next);
      expect(p.state.coins, 300);
      expect(p.state.results.map((r) => r.reward), [75, 75]);
      expect(p.state.currentStreak(clock.value), 1);
    },
  );

  test('DAY-03 stale pending or playing Daily cannot submit, charge, reveal or complete', () async {
    for (final loss in [false, true]) {
      final clock = TestClock(DateTime(2026, 3, 28, 23, 59));
      final store = MemoryProgressStorage();
      final p = await player(clock: clock, store: store);
      final b = BoardController(p, p.enterDaily()!);
      b.categoryPeek();
      if (loss) {
        pending(b);
      } else {
        for (final c in b.game.level.categories.take(3)) {
          submitIds(b, c.tiles.map((t) => t.id));
        }
        for (final t in b.game.remainingCategories.single.tiles) {
          b.toggle(t.id);
        }
      }
      final old = jsonEncode(b.game.snapshot());
      clock.day(1);
      for (final action in [
        b.submit,
        b.pairMagnet,
        b.categoryPeek,
        b.extraLife,
        b.revealLoss,
        b.shuffle,
      ]) {
        expect(action(), isA<Rejected>());
      }
      expect(jsonEncode(b.game.snapshot()), old);
      expect(p.state.coins, 110);
      expect(p.state.gamesPlayed, 0);
      expect(p.state.dailyAttempt, isNull);
      final next = p.enterDaily()!;
      expect(next.id, isNot(b.attempt.id));
      expect(next.date, '2026-03-29');
      await p.flush();
      final reloaded = await player(clock: clock, store: store);
      expect(reloaded.enterDaily()!.id, next.id);
    }
  });

  test('DAY-03 previous-day pending discarded on restart; loss closes only its date', () async {
    final store = MemoryProgressStorage();
    final clock = TestClock();
    var p = await player(clock: clock, store: store);
    pending(BoardController(p, p.enterDaily()!));
    await p.flush();
    clock.day(1);
    p = await player(clock: clock, store: store);
    expect(p.state.dailyAttempt, isNull);
    expect(p.state.gamesPlayed, 0);
    final b = BoardController(p, p.enterDaily()!);
    pending(b);
    b.revealLoss();
    final closedId = b.attempt.id;
    expect(p.enterDaily()!.id, closedId);
    clock.day(1);
    expect(p.enterDaily()!.id, isNot(closedId));
    expect(p.state.gamesPlayed, 1);
  });

  test(
    'DAY-05 streak today/yesterday, loss, gaps, best retained after restart',
    () async {
      final clock = TestClock(DateTime(2028, 2, 27));
      final store = MemoryProgressStorage();
      var p = await player(clock: clock, store: store);
      for (var day = 0; day < 3; day++) {
        win(BoardController(p, p.enterDaily()!));
        expect(p.state.currentStreak(clock.value), day + 1);
        clock.day(1);
        expect(p.state.currentStreak(clock.value), day + 1);
      }
      final loss = BoardController(p, p.enterDaily()!);
      pending(loss);
      loss.revealLoss();
      expect(p.state.currentStreak(clock.value), 0);
      expect(p.state.bestDailyStreak, 3);
      clock.day(1);
      win(BoardController(p, p.enterDaily()!));
      expect(p.state.currentStreak(clock.value), 1);
      clock.day(2);
      expect(p.state.currentStreak(clock.value), 0);
      win(BoardController(p, p.enterDaily()!));
      expect(p.state.currentStreak(clock.value), 1);
      await p.flush();
      p = await player(clock: clock, store: store);
      expect(p.state.bestDailyStreak, 3);
      expect(p.state.currentStreak(clock.value), 1);
    },
  );

  test('DAY-06 finalized-only statistics, independent buckets and catalog-free history', () async {
    final store = MemoryProgressStorage((Progress()..coins = 1000).encode());
    final p = await player(store: store);
    final b = firstBoard(p);
    expect(p.state.gamesPlayed, 0);
    pending(b);
    expect(p.state.gamesPlayed, 0);
    b.revealLoss();
    for (var m = 0; m < 5; m++) {
      b.newAttempt();
      for (var i = 0; i < m; i++) {
        mistake(b, i);
      }
      if (b.game.lives == 0) b.extraLife();
      win(b);
    }
    expect(p.state.gamesPlayed, 6);
    expect(p.state.wins, 5);
    expect(p.state.winRate, 5 / 6);
    expect(p.state.perfectWins, 1);
    expect(p.state.winMistakeBuckets, [1, 1, 1, 1, 1]);
    await p.flush();
    final reloaded = await player(store: store, catalog: twoPacks());
    expect(reloaded.state.gamesPlayed, 6);
    expect(reloaded.state.winMistakeBuckets, [1, 1, 1, 1, 1]);
    expect(
      reloaded.state.results.first.shareText,
      startsWith('LexiStack · Everyday Echoes #1\n0/4 groups · 4 mistakes'),
    );
    expect(reloaded.state.campaign['pack1_lvl01']!.bestStars, 3);
  });
}
