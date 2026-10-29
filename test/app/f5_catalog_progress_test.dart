import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/progress_controller.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/core/game.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../support/content_fixture.dart';
import '../support/progress_fixture.dart';

// Exact pre-F5 manifest arrangement; unchanged frozen pack1 and Daily bytes.
Catalog legacyCatalog() => validateCatalog(
  manifestContents: '{"campaign":["pack1.json"],"daily":"daily.json"}',
  files: installedFiles(),
  mode: ValidationMode.partial,
).catalog!;

Future<ProgressController> legacyPlayer(TestClock clock) async {
  final p = await player(clock: clock, catalog: legacyCatalog());
  final first = firstBoard(p);
  win(first);
  first.newAttempt();
  win(first); // First replay payout is already consumed.
  final second = BoardController(
    p,
    p.enterCampaign(p.campaignPacks.first.levels[1])!,
  );
  win(second);
  for (var i = 0; i < 2; i++) {
    win(BoardController(p, p.enterDaily()!));
    clock.day(1);
  }
  first.newAttempt();
  first.pairMagnet();
  first.categoryPeek();
  mistake(first, 0);
  submitIds(first, first.game.level.categories.first.tiles.map((t) => t.id));
  first.shuffle();
  first.toggle(first.game.order.last);
  first.toggle(first.game.order.first);
  second.newAttempt();
  second.pairMagnet();
  second.categoryPeek();
  pending(second);
  p.enterCampaign(p.campaignPacks.first.levels[2]);
  final daily = BoardController(p, p.enterDaily()!);
  daily.pairMagnet();
  daily.categoryPeek();
  mistake(daily, 0);
  submitIds(daily, daily.game.level.categories.last.tiles.map((t) => t.id));
  daily.shuffle();
  daily.toggle(daily.game.order.last);
  p.setSettings(theme: 'dark', haptics: false);
  await p.flush();
  return p;
}

void main() {
  for (final pack in installedCatalog().packs.take(5)) {
    test(
      'F5 ECO-03/05 ${pack.id} all eight unlocks independent and durable',
      () async {
        final p = await player();
        for (final other in p.campaignPacks) {
          expect(p.unlocked(other.levels.first), isTrue);
          expect(other.levels.skip(1).any(p.unlocked), isFalse);
        }
        for (final (index, level) in pack.levels.indexed) {
          expect(p.unlocked(level), isTrue);
          win(BoardController(p, p.enterCampaign(level)!));
          if (index < 7) expect(p.unlocked(pack.levels[index + 1]), isTrue);
          if (index < 6) expect(p.unlocked(pack.levels[index + 2]), isFalse);
          for (final other in p.campaignPacks.where((p) => p.id != pack.id)) {
            expect(other.levels.skip(1).any(p.unlocked), isFalse);
          }
        }
        final replay = BoardController(
          p,
          p.enterCampaign(pack.levels.first, replay: true)!,
        );
        pending(replay);
        replay.revealLoss();
        replay.newAttempt();
        mistake(replay, 0);
        win(replay);
        expect(replay.game.stars, 2);
        await p.flush();
        final loaded = await player(store: p.storage as MemoryProgressStorage);
        expect(pack.levels.every(loaded.unlocked), isTrue);
        expect(loaded.state.campaign.keys, pack.levels.map((l) => l.id));
        expect(
          loaded.state.campaign.values.every((a) => a.bestStars == 3),
          isTrue,
        );
        for (final other in loaded.campaignPacks.where(
          (p) => p.id != pack.id,
        )) {
          expect(other.levels.skip(1).any(loaded.unlocked), isFalse);
        }
      },
    );
  }

  test('F5 ECO-06 Continue follows all 40 manifest levels; explicit replay survives completion', () async {
    final p = await player();
    for (final level in p.campaignPacks.expand((p) => p.levels)) {
      final attempt = p.continueCampaign()!;
      expect(attempt.levelId, level.id);
      expect(attempt.date, isNull);
      win(BoardController(p, attempt));
    }
    expect(p.state.campaign, hasLength(40));
    expect(p.state.results, hasLength(40));
    final sequence = p.state.sequence;
    expect(p.continueCampaign(), isNull);
    expect(p.state.sequence, sequence);
    expect(p.state.daily, isEmpty);
    final replay = p.enterCampaign(
      p.campaignPacks.last.levels.first,
      replay: true,
    )!;
    expect(replay.game.status, GameStatus.playing);
    expect(p.continueCampaign(), same(replay));
  });

  test('F5 ECO-06 most recently entered unfinished new pack precedes fresh and Daily', () async {
    final p = await player();
    final a = p.enterCampaign(p.campaignPacks[1].levels.first)!;
    final b = p.enterCampaign(p.campaignPacks[3].levels.first)!;
    pending(BoardController(p, b));
    p.enterDaily();
    expect(p.continueCampaign(), same(b));
    p.enterCampaign(a.game.level);
    expect(p.continueCampaign(), same(a));
    p.enterCampaign(b.game.level);
    await p.flush();
    final restored = await player(store: p.storage as MemoryProgressStorage);
    final continued = restored.continueCampaign()!;
    expect(continued.id, b.id);
    expect(continued.game.status, GameStatus.lostPendingDecision);
    expect(continued.game.revealedCategories, isEmpty);
  });

  test('F5 PER old two-pack v1 save restores unchanged into full production catalog', () async {
    final clock = TestClock(DateTime(2026, 10, 27));
    final old = await legacyPlayer(clock);
    final store = old.storage as MemoryProgressStorage;
    final document = store.value!;
    final fixture = File('test/fixtures/f4-progress-v1.json');
    if (const bool.fromEnvironment('WRITE_F5_FIXTURE')) {
      fixture.parent.createSync(recursive: true);
      fixture.writeAsStringSync('$document\n');
    }
    expect(jsonDecode(fixture.readAsStringSync()), old.state.toJson());
    expect(jsonDecode(document)['version'], 1);
    final restored = await player(
      store: MemoryProgressStorage(document),
      clock: clock,
    );
    expect(restored.recoveryNotice, isNull);
    expect(
      restored.state.toJson(),
      old.state.toJson(),
      reason: 'Every section, ID, counter, payment, hint, selection and board order must survive',
    );
    expect(restored.state.coins, 195);
    expect(restored.state.gamesPlayed, 5);
    expect(restored.state.campaign['pack1_lvl01']!.practicePaid, isTrue);
    expect(restored.state.results.map((r) => r.rewardKind), [
      'first',
      'practice',
      'first',
      'daily',
      'daily',
    ]);
    expect(restored.state.currentStreak(clock()), 2);
    expect(restored.state.bestDailyStreak, 2);
    expect(restored.state.attempts, hasLength(3));
    expect(restored.state.dailyAttempt!.date, '2026-10-29');
    for (final pack in restored.campaignPacks.skip(1)) {
      expect(restored.unlocked(pack.levels.first), isTrue);
      expect(pack.levels.skip(1).any(restored.unlocked), isFalse);
    }
    final writes = (restored.storage as MemoryProgressStorage).writes;
    expect(
      writes,
      isEmpty,
      reason: 'Loading catalog expansion itself never pays or writes',
    );
    await restored.retryLoad();
    expect(restored.state.toJson(), old.state.toJson());
    final rescue = BoardController(
      restored,
      restored.state.attempts['pack1_lvl02']!,
    );
    expect(rescue.game.status, GameStatus.lostPendingDecision);
    expect(rescue.game.revealedCategories, isEmpty);
    expect(rescue.extraLife(), isA<Applied>());
    expect(restored.state.coins, 135);
    final replay = BoardController(
      restored,
      restored.state.attempts['pack1_lvl01']!,
    );
    win(replay);
    expect(restored.state.results.last.reward, 0);
    expect(restored.state.coins, 135);
    final settled = restored.state.encode();
    replay.submit();
    expect(restored.state.encode(), settled);
    await restored.flush();
    final again = await player(
      store: restored.storage as MemoryProgressStorage,
      clock: clock,
    );
    expect(again.state.toJson(), restored.state.toJson());
    expect(again.state.coins, 135);
  });

  test('F5 PER-07 content change drops only affected unfinished board and retains payment locks', () async {
    final clock = TestClock(DateTime(2026, 10, 27));
    final old = await legacyPlayer(clock);
    // A previously quarantined ledger lock is also independent of new packs.
    old.state.rewardLocks.add('pack1_lvl02');
    final files = installedFiles();
    final raw = jsonDecode(files['pack1.json']!);
    raw['levels'][0]['categories'][0]['triviaFact'] = 'This altered test-only fact makes the saved content fingerprint incompatible.';
    final modified = validateCatalog(
      manifestContents: installedManifest(),
      files: {...files, 'pack1.json': jsonEncode(raw)},
    ).catalog!;
    final restored = await player(
      store: MemoryProgressStorage(old.state.encode()),
      clock: clock,
      catalog: modified,
    );
    expect(restored.recoveryNotice, contains('invalid campaign attempt'));
    expect(restored.state.attempts.keys, ['pack1_lvl02', 'pack1_lvl03']);
    final expected = old.state.toJson();
    (expected['attempts'] as List).removeAt(0);
    expect(restored.state.toJson(), expected);
    final replay = firstBoard(restored, replay: true);
    win(replay);
    expect(restored.state.results.last.reward, 0);
    final locked = BoardController(
      restored,
      restored.state.attempts['pack1_lvl02']!,
    );
    locked.extraLife();
    win(locked);
    expect(restored.state.results.last.rewardKind, 'suppressed');
    expect(restored.state.results.last.reward, 0);
  });
}
