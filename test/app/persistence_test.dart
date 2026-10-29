import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/progress.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/core/game.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../support/progress_fixture.dart';

Future<Map<String, dynamic>> richSave() async {
  final p = await player();
  final b = firstBoard(p);
  win(b);
  b.newAttempt();
  b.categoryPeek();
  b.pairMagnet();
  mistake(b, 0);
  submitIds(b, b.game.level.categories.first.tiles.map((t) => t.id));
  b.toggle(b.game.level.categories[1].tiles.last.id);
  b.shuffle();
  p.enterCampaign(p.campaignPacks.first.levels[1]);
  final daily = BoardController(p, p.enterDaily()!);
  daily.toggle(daily.game.order.first);
  await p.flush();
  return jsonDecode((p.storage as MemoryProgressStorage).value!);
}

void main() {
  test('PER-01/02 exact partial/hinted round-trip and next shuffle matches uninterrupted', () async {
    final p = await player();
    final b = firstBoard(p);
    b.pairMagnet();
    b.categoryPeek();
    mistake(b, 0);
    submitIds(b, b.game.level.categories.first.tiles.map((t) => t.id));
    b.toggle(b.game.order.last);
    b.toggle(b.game.order.first);
    b.shuffle();
    final expected = jsonEncode(b.game.snapshot());
    await p.flush();
    final reloaded = await player(store: p.storage as MemoryProgressStorage);
    final again = firstBoard(reloaded);
    expect(jsonEncode(again.game.snapshot()), expected);
    expect(reloaded.state.coins, 80);
    expect(reloaded.recoveryNotice, isNull);
    b.shuffle();
    again.shuffle();
    expect(again.game.order, b.game.order);
    expect(again.game.rngState, b.game.rngState);
    expect(again.game.selection, b.game.selection);
    expect(
      again.game.pairs,
      isNotEmpty,
      reason: 'Hints on solved categories remain legitimate',
    );
  });

  test(
    'PER-02 pending hinted loss retains concealment and rescue arithmetic',
    () async {
      final p = await player();
      final b = firstBoard(p);
      b.categoryPeek();
      b.pairMagnet();
      pending(b);
      await p.flush();
      final r = await player(store: p.storage as MemoryProgressStorage);
      final restored = firstBoard(r);
      expect(restored.game.snapshot(), b.game.snapshot());
      expect(restored.game.revealedCategories, isEmpty);
      expect(restored.game.revealedRedHerrings, isEmpty);
      expect(restored.extraLife(), isA<Applied>());
      expect(r.state.coins, 20);
      expect(restored.game.lives, 1);
      expect(restored.game.extraLivesUsed, 1);
      expect(restored.game.stars, 1);
      await r.flush();
      final again = await player(store: r.storage as MemoryProgressStorage);
      expect(firstBoard(again).game.snapshot(), restored.game.snapshot());
    },
  );

  final corruptions = <String, void Function(Map<String, dynamic>)>{
    'PER-04 known duplicate plus missing ID, unchanged length': (g) =>
        g['order'][1] = g['order'][0],
    'missing tile': (g) => g['order'].removeLast(),
    'extra tile': (g) => g['order'].add('unknown'),
    'unknown tile': (g) => g['order'][0] = 'unknown',
    'duplicate selection': (g) => g['selection'].add(g['selection'][0]),
    'solved tile selected': (g) =>
        g['selection'].add(g['guesses'][1]['ids'][0]),
    'selection over cap': (g) => g['selection'] = g['order'].take(5).toList(),
    'duplicate solved group': (g) => g['solved'].add(g['solved'][0]),
    'unknown solved group': (g) => g['solved'][0] = 'missing',
    'duplicate guessed-set ID': (g) =>
        g['guesses'][0]['ids'][1] = g['guesses'][0]['ids'][0],
    'invalid guess tier': (g) => g['guesses'][0]['tiers'][0] = 9,
    'wrong true tier': (g) => g['guesses'][0]['tiers'][0] = 4,
    'false correctness': (g) => g['guesses'][0]['correct'] = true,
    'already solved group guessed again': (g) =>
        g['guesses'].add(g['guesses'][1]),
    'repeated wrong evaluation': (g) => g['guesses'].add(g['guesses'][0]),
    'wrong signature mismatch': (g) => g['wrong'] = [],
    'duplicate wrong signature': (g) => g['wrong'].add(g['wrong'][0]),
    'impossible lives': (g) => g['lives'] = 4,
    'impossible rescues': (g) => g['extraLives'] = 2,
    'impossible status': (g) => g['status'] = 'won',
    'unknown status': (g) => g['status'] = 'aborted',
    'false mistake count': (g) => g['mistakes'] = 2,
    'false combo': (g) => g['combo'] = 3,
    'invalid RNG': (g) => g['rng'] = 0,
    'invalid seed': (g) => g['seed'] = 2147483647,
    'fractional lives': (g) => g['lives'] = 3.0,
    'unknown peek': (g) => g['peeked'].add('missing'),
    'duplicate peek': (g) => g['peeked'].add(g['peeked'][0]),
    'invalid pair membership': (g) => g['pairs']['g1'][0] = g['order'][0],
    'duplicate pair tile': (g) => g['pairs']['g1'][1] = g['pairs']['g1'][0],
    'wrong pair root': (g) => g['pairs'] = [],
  };
  for (final entry in corruptions.entries) {
    test('PER-04/05/06 salvage around ${entry.key}', () async {
      final data = await richSave();
      final wallet = data['coins'];
      final validId = data['attempts'][1]['id'];
      entry.value(data['attempts'][0]['game']);
      final p = await player(store: MemoryProgressStorage(jsonEncode(data)));
      expect(p.state.coins, wallet);
      expect(p.state.campaign['pack1_lvl01']!.bestStars, 3);
      expect(p.state.results, hasLength(1));
      expect(p.state.results.single.reward, 50);
      expect(p.state.attempts.keys, ['pack1_lvl02']);
      expect(p.state.attempts.values.single.id, validId);
      expect(p.state.dailyAttempt, isNotNull);
      expect(p.recoveryNotice, isNotNull);
    });
  }

  test('PER-03 missing/orphan level preserves history wallet and unrelated attempt', () async {
    final data = await richSave();
    data['attempts'][0]['levelId'] = 'renamed';
    final p = await player(store: MemoryProgressStorage(jsonEncode(data)));
    expect(p.state.attempts.keys, ['pack1_lvl02']);
    expect(p.state.gamesPlayed, 1);
    expect(p.state.coins, 130);
    expect(p.state.campaign['pack1_lvl01']!.bestStars, 3);
  });

  test('PER-07 changed words/title/trivia under same IDs invalidate only matching attempt', () async {
    final data = await richSave();
    final catalog = installedCatalog();
    final old = catalog.packs.first;
    final l = old.levels.first;
    final changed = Level(
      id: l.id,
      packId: l.packId,
      title: '${l.title} changed',
      categories: l.categories,
      redHerrings: l.redHerrings,
    );
    final replacement = Catalog(
      manifest: catalog.manifest,
      packs: [
        Pack(
          source: old.source,
          schemaVersion: 2,
          id: old.id,
          title: old.title,
          description: old.description,
          levels: [changed, ...old.levels.skip(1)],
        ),
        ...catalog.packs.skip(1),
      ],
    );
    final p = await player(
      store: MemoryProgressStorage(jsonEncode(data)),
      catalog: replacement,
    );
    expect(p.state.attempts.keys, ['pack1_lvl02']);
    expect(p.state.dailyAttempt, isNotNull);
    expect(p.state.coins, 130);
    expect(p.state.results.single.shareText, contains('★★★'));
    expect(
      p.enterCampaign(changed),
      isNull,
      reason: 'Keep history without recreating incompatible final board',
    );
  });

  for (final root in [
    '{',
    '[]',
    'null',
    '42',
    '{"version":99}',
    '{"version":1.0}',
  ]) {
    test('PER-06 unreadable root $root resets with notice', () async {
      final p = await player(store: MemoryProgressStorage(root));
      expect(p.state.toJson(), Progress().toJson());
      expect(p.recoveryNotice, isNotNull);
    });
  }

  test('PER-06 independently salvage wallet, settings, history, campaign and Daily', () async {
    final p = await player();
    win(firstBoard(p));
    win(BoardController(p, p.enterDaily()!));
    final raw = jsonDecode(p.state.encode());
    raw['attempts'] = 'bad';
    raw['settings'] = {'theme': 'bogus', 'haptics': false};
    raw['campaign']['bad'] = {'bestStars': 99, 'practicePaid': false};
    raw['daily']['nonsense'] = {};
    final loaded = await player(store: MemoryProgressStorage(jsonEncode(raw)));
    expect(loaded.state.coins, 275);
    expect(loaded.state.gamesPlayed, 2);
    expect(loaded.state.daily.keys, ['2026-10-28']);
    expect(loaded.state.campaign.keys, ['pack1_lvl01']);
    expect(loaded.state.theme, 'system');
    expect(loaded.state.haptics, isFalse);
  });

  test('PER-05 duplicate result IDs and tampered reward ledger never create fresh payouts', () async {
    for (final mutation in ['duplicate', 'reward', 'flag', 'extra-first']) {
      final p = await player();
      final b = firstBoard(p);
      win(b);
      b.newAttempt();
      win(b);
      final raw = jsonDecode(p.state.encode());
      if (mutation == 'duplicate') raw['results'].add(raw['results'][0]);
      if (mutation == 'reward') raw['results'][0]['reward'] = 75;
      if (mutation == 'flag') {
        raw['campaign']['pack1_lvl01']['practicePaid'] = false;
      }
      if (mutation == 'extra-first') {
        final copy = jsonDecode(jsonEncode(raw['results'][0]));
        copy['id'] = 'a999';
        raw['results'].add(copy);
      }
      final store = MemoryProgressStorage(jsonEncode(raw));
      final loaded = await player(store: store);
      expect(loaded.state.coins, 205);
      expect(
        loaded.state.results.map((r) => r.id).toSet().length,
        loaded.state.results.length,
      );
      final replay = firstBoard(loaded, replay: true);
      win(replay);
      expect(loaded.state.coins, 205);
      await loaded.flush();
      final again = await player(store: store);
      win(firstBoard(again, replay: true));
      expect(again.state.coins, 205);
    }
  });

  test('PER-05 corrupt Daily summary closes date while retaining valid Daily outcome', () async {
    final p = await player();
    win(BoardController(p, p.enterDaily()!));
    final data = jsonDecode(p.state.encode());
    data['results'][0]['reward'] = 0;
    final loaded = await player(store: MemoryProgressStorage(jsonEncode(data)));
    expect(loaded.state.coins, 225);
    expect(loaded.state.daily['2026-10-28']!.won, isTrue);
    expect(loaded.enterDaily(), isNull);
    expect(loaded.state.results, isEmpty);
    expect(loaded.recoveryNotice, isNotNull);
  });

  test(
    'PER-08 slower earlier write cannot overwrite newer captured snapshot',
    () async {
      final store = MemoryProgressStorage();
      final held = Completer<void>();
      final started = <String>[];
      store.beforeWrite = (text) async {
        started.add(text);
        if (started.length == 1) await held.future;
      };
      final p = await player(store: store);
      final b = firstBoard(p);
      b.pairMagnet();
      b.categoryPeek();
      await Future<void>.delayed(Duration.zero);
      expect(
        started,
        hasLength(1),
        reason: 'A faster later write must not even start',
      );
      expect(jsonDecode(started.single)['coins'], 150);
      expect(p.saved, isFalse);
      held.complete();
      await p.flush();
      expect(store.writes.map((s) => jsonDecode(s)['coins']), [150, 120, 80]);
      expect(jsonDecode(store.value!)['coins'], 80);
      expect(p.saved, isTrue);
    },
  );

  test(
    'PER-09 failed writes reported, queue recovers and explicit retry works',
    () async {
      final store = MemoryProgressStorage()..failWrites = 1;
      final p = await player(store: store);
      final b = firstBoard(p);
      await p.flush();
      expect(p.storageWarning, contains('not saved'));
      expect(p.saved, isFalse);
      expect(store.value, isNull);
      b.pairMagnet();
      await p.flush();
      expect(p.storageWarning, isNull);
      expect(p.saved, isTrue);
      expect(jsonDecode(store.value!)['coins'], 120);
      store.failWrites = 1;
      b.categoryPeek();
      await p.flush();
      expect(p.saved, isFalse);
      p.retrySave();
      await p.flush();
      expect(p.saved, isTrue);
      expect(jsonDecode(store.value!)['coins'], 80);
    },
  );

  test('PER-09 reset cancel/confirm, defaults, stale handles, ordered reopen and failure', () async {
    final store = MemoryProgressStorage();
    final p = await player(store: store);
    final b = firstBoard(p);
    win(b);
    win(BoardController(p, p.enterDaily()!));
    p.setSettings(theme: 'dark', haptics: false);
    await p.flush();
    final before = store.value;
    p.reset(confirmed: false);
    await p.flush();
    expect(store.value, before);
    store.failWrites = 1;
    p.reset(confirmed: true);
    await p.flush();
    expect(p.state.toJson(), Progress().toJson());
    expect(p.saved, isFalse);
    expect(store.value, before);
    p.retrySave();
    await p.flush();
    final again = await player(store: store);
    expect(again.state.toJson(), Progress().toJson());
    final fresh = firstBoard(p);
    final snapshot = p.state.encode();
    b.submit();
    b.extraLife();
    expect(p.state.encode(), snapshot);
    expect(p.isCurrent(fresh.attempt), isTrue);
  });
}
