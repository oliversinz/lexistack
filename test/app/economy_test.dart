import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/progress.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/core/game.dart';

import '../support/progress_fixture.dart';

void main() {
  for (final (mistakes, stars, reward) in [
    (0, 3, 50),
    (1, 2, 30),
    (2, 2, 30),
    (3, 1, 15),
    (4, 1, 15),
    (5, 1, 15),
  ]) {
    test(
      'ECO-01/02 independent $mistakes mistakes -> $stars stars +$reward',
      () async {
        final p = await player();
        final b = firstBoard(p);
        expect(p.state.coins, 150);
        var rescues = 0;
        for (var i = 0; i < mistakes; i++) {
          if (b.game.lives == 0) {
            b.extraLife();
            rescues++;
          }
          mistake(b, i);
        }
        if (b.game.lives == 0) {
          b.extraLife();
          rescues++;
        }
        win(b);
        expect(b.game.status, GameStatus.won);
        expect(b.game.stars, stars);
        expect(p.state.coins, 150 - 60 * rescues + reward);
        expect(p.state.campaign[b.game.level.id]!.bestStars, stars);
        expect(p.state.results.single.reward, reward);
        expect(p.state.gamesPlayed, 1);
        final snapshot = p.state.encode();
        b.submit();
        b.extraLife();
        b.revealLoss();
        expect(p.state.encode(), snapshot);
        await p.flush();
        final reopened = await player(
          store: p.storage as MemoryProgressStorage,
        );
        expect(reopened.state.results.single.reward, reward);
        expect(reopened.state.coins, p.state.coins);
        expect(reopened.recoveryNotice, isNull);
      },
    );
  }

  test('ECO-03/04 first successful replay +5 once, failures and restarts cannot farm', () async {
    final store = MemoryProgressStorage();
    var p = await player(store: store);
    var b = firstBoard(p);
    for (var i = 0; i < 3; i++) {
      mistake(b, i);
    }
    win(b);
    expect(p.state.coins, 165);
    expect(p.state.campaign[b.game.level.id]!.bestStars, 1);
    final firstId = b.attempt.id;
    b.newAttempt();
    expect(b.attempt.id, isNot(firstId));
    pending(b);
    b.revealLoss();
    expect(p.state.campaign[b.game.level.id]!.practicePaid, isFalse);
    b.newAttempt();
    win(b);
    expect(p.state.coins, 170);
    expect(p.state.campaign[b.game.level.id]!.bestStars, 3);
    expect(p.state.campaign[b.game.level.id]!.practicePaid, isTrue);
    await p.flush();
    p = await player(store: store);
    b = firstBoard(p);
    expect(b.game.status, GameStatus.won);
    expect(p.state.coins, 170);
    b.newAttempt();
    for (var i = 0; i < 3; i++) {
      mistake(b, i);
    }
    win(b);
    expect(p.state.coins, 170);
    expect(p.state.campaign[b.game.level.id]!.bestStars, 3);
    expect(p.state.results.map((r) => r.reward), [15, 0, 5, 0]);
    expect(p.state.results.map((r) => r.id).toSet(), hasLength(4));
  });

  test(
    'ECO-05/06 independent packs, Continue recent pending, unlock and all won',
    () async {
      final p = await player(catalog: twoPacks());
      final a = p.campaignPacks[0].levels;
      final b = p.campaignPacks[1].levels;
      expect(
        [
          p.unlocked(a[0]),
          p.unlocked(a[1]),
          p.unlocked(b[0]),
          p.unlocked(b[1]),
        ],
        [true, false, true, false],
      );
      expect(p.enterCampaign(a[1]), isNull);
      final a0 = p.continueCampaign()!;
      final b0 = p.enterCampaign(b[0])!;
      expect(p.continueCampaign()!.id, b0.id);
      final boardA = BoardController(p, p.enterCampaign(a[0])!);
      pending(boardA);
      expect(p.continueCampaign()!.id, a0.id);
      boardA.extraLife();
      win(boardA);
      expect(p.unlocked(a[1]), isTrue);
      expect(p.unlocked(b[1]), isFalse);
      expect(p.continueCampaign()!.id, b0.id);
      win(BoardController(p, b0));
      expect(p.continueCampaign()!.levelId, a[1].id);
      win(BoardController(p, p.enterCampaign(a[1])!));
      win(BoardController(p, p.continueCampaign()!));
      final before = p.state.encode();
      expect(p.continueCampaign(), isNull);
      expect(p.state.encode(), before);
    },
  );

  test(
    'ECO-07/08 paid targeting, cap, hint persistence and no repeat charge',
    () async {
      final store = MemoryProgressStorage();
      final p = await player(store: store);
      final b = firstBoard(p);
      final tiles = b.game.level.tiles;
      b.toggle(tiles[10].id);
      expect(b.pairMagnet(), isA<Applied>());
      expect(p.state.coins, 120);
      expect(b.game.pairs['g3'], [tiles[10].id, tiles[8].id]);
      b.categoryPeek();
      expect(p.state.coins, 80);
      expect(b.game.peekedIds, {'g1'});
      final full = p.state.encode();
      expect(b.extraLife(), isA<Rejected>());
      expect(p.state.encode(), full);
      mistake(b, 0);
      b.extraLife();
      expect(p.state.coins, 20);
      expect(b.game.lives, 4);
      final game = jsonEncode(b.game.snapshot());
      await p.flush();
      final reloaded = await player(store: store);
      final again = firstBoard(reloaded);
      expect(jsonEncode(again.game.snapshot()), game);
      expect(reloaded.state.coins, 20);
      for (final buy in [
        again.pairMagnet,
        again.categoryPeek,
        again.extraLife,
      ]) {
        final before = reloaded.state.encode();
        expect(buy(), isA<Rejected>());
        expect(reloaded.state.encode(), before);
      }
    },
  );

  test('ECO-09 no eligible, wrong state, terminal actions preserve complete wallet/game', () async {
    final seed = Progress()..coins = 1000;
    final p = await player(store: MemoryProgressStorage(seed.encode()));
    final b = firstBoard(p);
    for (var i = 0; i < 4; i++) {
      b.pairMagnet();
      b.categoryPeek();
    }
    final allHints = p.state.encode();
    b.pairMagnet();
    b.categoryPeek();
    b.extraLife();
    b.revealLoss();
    expect(p.state.encode(), allHints);
    pending(b);
    final pendingState = p.state.encode();
    b.pairMagnet();
    b.categoryPeek();
    b.submit();
    b.shuffle();
    expect(p.state.encode(), pendingState);
    b.revealLoss();
    final finalState = p.state.encode();
    b.extraLife();
    b.pairMagnet();
    b.categoryPeek();
    b.revealLoss();
    expect(p.state.encode(), finalState);
  });
}
