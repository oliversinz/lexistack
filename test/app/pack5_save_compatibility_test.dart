import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/core/content_identity.dart';
import 'package:lexistack/core/game.dart';

import '../support/content_fixture.dart';
import '../support/progress_fixture.dart';

void main() {
  for (final original in [initialCatalog(), pack5Catalog()]) {
    final nextPack = original.manifest.campaign.length + 1;
    for (final finishedDaily in [false, true]) {
      test(
        '${original.packs.expand((p) => p.levels).length}-level save expands unchanged with ${finishedDaily ? 'final' : 'active'} Daily and unfinished replay',
        () async {
          final clock = TestClock(DateTime(2026, 10, 28));
          final old = await player(catalog: original, clock: clock);
          // Complete every old Campaign stage, including a two-star first win.
          for (final level in old.campaignPacks.expand((p) => p.levels)) {
            final b = BoardController(old, old.enterCampaign(level)!);
            if (level.id == 'pack2_lvl01') mistake(b, 0);
            win(b);
          }
          final replay = firstBoard(old, replay: true);
          win(
            replay,
          ); // Consume the one-time +5 practice payout before expansion.
          win(BoardController(old, old.enterDaily()!));
          clock.day(1);
          replay.newAttempt();
          replay.pairMagnet();
          replay.categoryPeek();
          pending(replay); // Preserve pending loss and its paid effects.
          final daily = BoardController(old, old.enterDaily()!);
          daily.pairMagnet();
          daily.categoryPeek();
          mistake(daily, 0);
          submitIds(
            daily,
            daily.game.level.categories.last.tiles.map((t) => t.id),
          );
          daily.shuffle();
          daily.toggle(daily.game.order.last);
          if (finishedDaily) win(daily);
          old.setSettings(theme: 'dark', haptics: false);
          await old.flush();
          final snapshot = old.state.toJson();
          final store = MemoryProgressStorage(
            (old.storage as MemoryProgressStorage).value,
          );
          final expanded = await player(store: store, clock: clock);
          expect(expanded.recoveryNotice, isNull);
          expect(expanded.state.toJson(), snapshot);
          expect(
            store.writes,
            isEmpty,
            reason: 'Loading never changes rewards or spends coins',
          );
          expect(jsonDecode(store.value!)['version'], 1);
          expect(expanded.state.campaign['pack2_lvl01']!.bestStars, 2);
          expect(expanded.state.campaign['pack1_lvl01']!.practicePaid, isTrue);
          for (final pack in original.packs) {
            final installed = expanded.catalog.packs.firstWhere(
              (p) => p.id == pack.id,
            );
            expect(
              installed.levels.map(contentFingerprint),
              pack.levels.map(contentFingerprint),
            );
          }
          final added = expanded.campaignPacks.skip(
            original.manifest.campaign.length,
          );
          for (final pack5 in added) {
            expect(expanded.unlocked(pack5.levels.first), isTrue);
            expect(pack5.levels.skip(1).any(expanded.unlocked), isFalse);
            for (final level in pack5.levels) {
              expect(expanded.state.campaign.containsKey(level.id), isFalse);
              expect(expanded.state.attempts.containsKey(level.id), isFalse);
              expect(expanded.resultFor(level.id), isNull);
            }
          }
          expect(expanded.state.currentStreak(clock()), finishedDaily ? 2 : 1);
          expect(expanded.state.bestDailyStreak, finishedDaily ? 2 : 1);
          final balance = expanded.state.coins;
          final resumed = BoardController(
            expanded,
            expanded.continueCampaign()!,
          );
          expect(resumed.attempt.id, replay.attempt.id);
          expect(resumed.game.snapshot(), replay.game.snapshot());
          expect(resumed.game.revealedCategories, isEmpty);
          expect(resumed.extraLife(), isA<Applied>());
          win(resumed);
          expect(expanded.state.results.last.reward, 0);
          expect(expanded.state.coins, balance - 60);
          expect(expanded.state.campaign['pack1_lvl01']!.bestStars, 3);
          final resumedDaily = BoardController(
            expanded,
            expanded.enterDaily()!,
          );
          expect(resumedDaily.attempt.id, daily.attempt.id);
          expect(resumedDaily.game.snapshot(), daily.game.snapshot());
          if (!finishedDaily) {
            win(resumedDaily);
            expect(
              expanded.state.results.last.reward,
              55,
            ); // Two stars + Daily bonus.
          }
          final settled = expanded.state.toJson();
          expanded.enterDaily();
          resumedDaily.submit();
          expect(expanded.state.toJson(), settled);
          final next = expanded.continueCampaign()!;
          expect(next.levelId, 'pack${nextPack}_lvl01');
          final fresh = BoardController(expanded, next);
          expect(fresh.game.order, hasLength(16));
          expect(fresh.game.mistakes, 0);
          expect(fresh.game.pairs, isEmpty);
          win(fresh);
          expect(expanded.state.results.last.reward, 50);
          expect(expanded.continueCampaign()!.levelId, 'pack${nextPack}_lvl02');
          await expanded.flush();
          final again = await player(store: store, clock: clock);
          expect(again.state.toJson(), expanded.state.toJson());
          expect(again.recoveryNotice, isNull);
        },
      );
    }

    test(
      'Daily selection and seeds survive expansion from $nextPack packs',
      () async {
        for (var day = 1; day <= 16; day++) {
          final clock = TestClock(DateTime(2026, 11, day));
          final old = await player(catalog: original, clock: clock);
          final expanded = await player(clock: clock);
          expect(
            expanded.dailyLevels.map((l) => l.id),
            old.dailyLevels.map((l) => l.id),
          );
          final before = old.enterDaily()!;
          final after = expanded.enterDaily()!;
          expect(after.levelId, startsWith('daily_'));
          expect(after.toJson(), before.toJson());
          await old.flush();
          await expanded.flush();
        }
      },
    );
  }
}
