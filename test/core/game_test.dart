import 'package:flutter_test/flutter_test.dart';

import 'package:lexistack/core/game.dart';
import 'package:lexistack/core/prng.dart';
import 'package:lexistack/core/scoring.dart';
import 'package:lexistack/core/share.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../support/content_fixture.dart';

Level oracleLevel() {
  const words = [
    ['MARS', 'VENUS', 'SATURN', 'JUPITER'],
    ['MERCURY', 'LEAD', 'GOLD', 'IRON'],
    ['OAK', 'BIRCH', 'PINE', 'ELM'],
    ['RED', 'BLUE', 'GREEN', 'WHITE'],
  ];
  return Level(
    id: 'oracle',
    packId: 'test',
    title: 'Rule oracle',
    categories: [
      for (var g = 0; g < 4; g++)
        Category(
          id: 'g$g',
          title: ['PLANETS', 'METALS', 'TREES', 'COLORS'][g],
          difficultyTier: g + 1,
          tiles: [
            for (var i = 0; i < 4; i++)
              Tile(
                levelId: 'oracle',
                categoryId: 'g$g',
                ordinal: i,
                difficultyTier: g + 1,
                text: words[g][i],
              ),
          ],
          triviaFact: 'A synthetic fixture used to test grouping behavior independently.',
        ),
    ],
    redHerrings: [
      RedHerring(tiles: ['WHITE'], note: 'Unrelated to the wrong guesses.'),
      RedHerring(
        tiles: ['MERCURY'],
        note: 'MERCURY is also a planet, but belongs with the metals here.',
      ),
    ],
  );
}

String id(Game game, String text) =>
    game.level.tiles.firstWhere((t) => t.text == text).id;

GameOutcome guess(Game game, List<String> words) {
  game.deselect();
  for (final word in words) {
    game.toggle(id(game, word));
  }
  return game.submit();
}

const wrongs = [
  ['MARS', 'VENUS', 'SATURN', 'MERCURY'],
  ['MARS', 'VENUS', 'MERCURY', 'GOLD'],
  ['MARS', 'OAK', 'RED', 'GOLD'],
  ['VENUS', 'BIRCH', 'BLUE', 'IRON'],
];

void lose(Game game) {
  for (final row in wrongs) {
    guess(game, row);
  }
}

void solveRemaining(Game game) {
  for (final category in game.remainingCategories) {
    guess(game, category.tiles.map((t) => t.text).toList());
  }
}

// Capture every mutable field, so rejected actions cannot silently alter RNG,
// hints, combo, selection order, or history as well as the visible counters.
Object snapshot(Game g) => [
  g.status,
  g.seed,
  g.rngState,
  g.lives,
  g.mistakes,
  g.combo,
  g.extraLivesUsed,
  g.order,
  g.selection,
  g.solvedIds,
  g.wrongSignatures,
  g.pairs,
  g.peekedIds,
  [
    for (final row in g.guesses) [row.tileIds, row.tiers, row.correct],
  ],
];

void main() {
  Game fresh() => Game(oracleLevel(), seed: 42);

  test('ENG-01/11 fresh state and independently derived board order', () {
    final g = fresh();
    expect(g.status, GameStatus.playing);
    expect(g.lives, 4);
    expect(g.mistakes, 0);
    expect(g.combo, 0);
    expect(g.remainingCategories, hasLength(4));
    expect(g.order.toSet(), hasLength(16));
    expect(g.order.map((id) => g.level.tiles.indexWhere((t) => t.id == id)), [
      12,
      0,
      4,
      5,
      15,
      10,
      3,
      8,
      14,
      1,
      7,
      2,
      9,
      11,
      13,
      6,
    ]);
    expect(g.rngState, 526968160);
  });

  test('ENG-04 exact match on separate fresh instance 1', () {
    final instance1 = fresh();
    expect(
      guess(instance1, ['MARS', 'VENUS', 'SATURN', 'JUPITER']),
      isA<Solved>(),
    );
    expect(instance1.solvedIds, ['g0']);
    expect(instance1.order, hasLength(12));
    expect(instance1.lives, 4);
    expect(instance1.selection, isEmpty);
    expect(instance1.guesses.single.correct, isTrue);
  });

  test('ENG-05/06 fresh instance 2 One Away, reversed duplicate, mismatch', () {
    final instance2 = fresh();
    final result = guess(instance2, wrongs[0]) as Mismatch;
    expect(result.isOneAway, isTrue);
    expect(instance2.lives, 3);
    expect(instance2.solvedIds, isEmpty);
    expect(
      instance2.selection.map(instance2.tile).map((t) => t.text),
      wrongs[0],
    );
    instance2.deselect();
    for (final word in wrongs[0].reversed) {
      instance2.toggle(id(instance2, word));
    }
    final before = snapshot(instance2);
    expect(instance2.submit(), isA<AlreadyGuessed>());
    expect(snapshot(instance2), before);
    expect(instance2.guesses, hasLength(1));
    expect((guess(instance2, wrongs[1]) as Mismatch).isOneAway, isFalse);
    expect(instance2.lives, 2);
    expect(instance2.mistakes, 2);
    expect(instance2.guesses, hasLength(2));
  });

  test('ENG-02 selection guards and immutable exposed collections', () {
    final g = fresh();
    final before = snapshot(g);
    expect(g.submit(), isA<Rejected>());
    expect(g.toggle('not a tile'), isA<Rejected>());
    expect(g.revealLoss(), isA<Rejected>());
    expect(snapshot(g), before);
    for (final word in wrongs[0]) {
      g.toggle(id(g, word));
    }
    final four = snapshot(g);
    expect(g.toggle(id(g, 'IRON')), isA<Rejected>());
    expect(snapshot(g), four);
    expect(() => g.selection.add('invalid'), throwsUnsupportedError);
    expect(() => g.order.clear(), throwsUnsupportedError);
    g.toggle(id(g, 'MARS'));
    expect(g.selection, hasLength(3));
    g.deselect();
    expect(g.selection, isEmpty);
    guess(g, ['MARS', 'VENUS', 'SATURN', 'JUPITER']);
    final solved = snapshot(g);
    expect(g.toggle(id(g, 'MARS')), isA<Rejected>());
    expect(g.drag(id(g, 'IRON'), target: id(g, 'MARS')), isA<Rejected>());
    expect(snapshot(g), solved);
  });

  test(
    'ENG-03 drag adds source then target, tray adds only source, cap four',
    () {
      final g = fresh();
      g.drag(id(g, 'MARS'), target: id(g, 'VENUS'));
      expect(g.selection, [id(g, 'MARS'), id(g, 'VENUS')]);
      g.drag(id(g, 'MARS'), target: id(g, 'VENUS'));
      expect(g.selection, hasLength(2));
      g.drag(id(g, 'SATURN'));
      g.drag(id(g, 'JUPITER'), target: id(g, 'IRON'));
      expect(
        g.selection,
        ['MARS', 'VENUS', 'SATURN', 'JUPITER'].map((w) => id(g, w)),
      );
      final before = snapshot(g);
      g.drag(id(g, 'GOLD'));
      g.drag('unknown', target: id(g, 'MERCURY'));
      expect(snapshot(g), before);
      final taps = fresh();
      for (final word in ['MARS', 'VENUS', 'SATURN', 'JUPITER']) {
        taps.toggle(id(taps, word));
      }
      expect(g.selection, taps.selection);
    },
  );

  test('ENG-11 repeated shuffles preserve selection, history, lives and identities', () {
    final a = fresh();
    final b = fresh();
    guess(a, wrongs[0]);
    guess(b, wrongs[0]);
    final selection = a.selection;
    final rows = a.guesses;
    for (var i = 0; i < 8; i++) {
      a.shuffle();
      b.shuffle();
      expect(a.order, b.order);
      expect(a.rngState, b.rngState);
      expect(a.order.toSet(), a.level.tiles.map((t) => t.id).toSet());
      expect(a.selection, selection);
      expect(a.guesses, rows);
      expect(a.lives, 3);
      expect(a.mistakes, 1);
    }
  });

  test(
    'ENG-07/08 pending loss hides reveals, rescue preserves the same attempt',
    () {
      final g = fresh();
      g.categoryPeek();
      g.pairMagnet();
      lose(g);
      expect(g.status, GameStatus.lostPendingDecision);
      expect(g.lives, 0);
      expect(g.mistakes, 4);
      expect(g.guesses, hasLength(4));
      expect(g.revealedCategories, isEmpty);
      expect(g.revealedRedHerrings, isEmpty);
      final before = snapshot(g);
      for (final action in [
        g.shuffle,
        g.deselect,
        g.submit,
        g.categoryPeek,
        g.pairMagnet,
        () => g.toggle(id(g, 'MARS')),
        () => g.drag(id(g, 'MARS')),
      ]) {
        expect(action(), isA<Rejected>());
        expect(snapshot(g), before);
      }
      final order = g.order;
      final selected = g.selection;
      final rows = g.guesses;
      final rng = g.rngState;
      final pairs = g.pairs;
      final peeks = g.peekedIds;
      expect(g.extraLife(), isA<Applied>());
      expect(g.status, GameStatus.playing);
      expect(g.lives, 1);
      expect(g.order, order);
      expect(g.selection, selected);
      expect(g.guesses, rows);
      expect(g.rngState, rng);
      expect(g.seed, 42);
      expect(g.pairs, pairs);
      expect(g.peekedIds, peeks);
      expect(g.stars, 1);
      expect(g.submit(), isA<AlreadyGuessed>());
      expect(g.lives, 1);
      guess(g, ['MARS', 'BIRCH', 'RED', 'GOLD']);
      expect(g.status, GameStatus.lostPendingDecision);
      expect(g.revealLoss(), isA<Applied>());
      expect(g.status, GameStatus.lostFinal);
      expect(g.revealedCategories, hasLength(4));
      expect(g.revealedRedHerrings.first.tiles, ['MERCURY']);
      assertTerminal(g);
    },
  );

  test('ENG-09/10 correct combo, reset, ordered history, four solves finalize once', () {
    final g = fresh();
    guess(g, ['RED', 'WHITE', 'BLUE', 'GREEN']);
    expect(g.combo, 1);
    guess(g, ['OAK', 'BIRCH', 'PINE', 'ELM']);
    expect(g.combo, 2);
    guess(g, ['MERCURY', 'MARS', 'SATURN', 'VENUS']);
    expect(g.combo, 0);
    expect(g.guesses.last.tiers, [2, 1, 1, 1]);
    expect(g.guesses.map((r) => r.correct), [true, true, false]);
    solveRemaining(g);
    expect(g.status, GameStatus.won);
    expect(g.combo, 2);
    expect(g.order, isEmpty);
    expect(g.solvedIds, hasLength(4));
    expect(g.lives, 3);
    expect(g.guesses, hasLength(5));
    assertTerminal(g);
  });

  test(
    'booster targeting, stable pairs, peek tier order and legal rejection',
    () {
      final g = fresh();
      final start = snapshot(g);
      expect(g.extraLife(), isA<Rejected>());
      expect(snapshot(g), start);
      g.toggle(id(g, 'IRON'));
      g.toggle(id(g, 'PINE'));
      g.pairMagnet();
      expect(g.pairs['g2'], [id(g, 'PINE'), id(g, 'OAK')]);
      g.pairMagnet();
      expect(g.pairs['g0'], [id(g, 'MARS'), id(g, 'VENUS')]);
      g.toggle(id(g, 'PINE')); // Most recent remaining selected tile is IRON.
      g.pairMagnet();
      expect(g.pairs['g1'], [id(g, 'IRON'), id(g, 'MERCURY')]);
      g.pairMagnet();
      final allPairs = snapshot(g);
      expect(g.pairMagnet(), isA<Rejected>());
      expect(snapshot(g), allPairs);
      expect(() => g.pairs['g0']!.clear(), throwsUnsupportedError);
      for (var i = 0; i < 4; i++) {
        expect(g.categoryPeek(), isA<Applied>());
        expect(g.peekedIds.toList(), [for (var j = 0; j <= i; j++) 'g$j']);
      }
      final allPeeks = snapshot(g);
      expect(g.categoryPeek(), isA<Rejected>());
      expect(snapshot(g), allPeeks);
      expect(g.selection, [id(g, 'IRON')]);
      expect(g.revealedCategories, isEmpty);
      expect(g.guesses, isEmpty);
      final h = fresh();
      guess(h, ['MARS', 'VENUS', 'SATURN', 'JUPITER']);
      h.categoryPeek();
      h.pairMagnet();
      expect(h.peekedIds, {'g1'});
      expect(h.pairs.keys, ['g1']);
    },
  );

  test('stars use actual mistakes even after repeated life restoration', () {
    expect([0, 1, 2, 3, 4, 9].map(starsForMistakes), [3, 2, 2, 1, 1, 1]);
    expect(() => starsForMistakes(-1), throwsRangeError);
    for (var mistakes = 0; mistakes <= 4; mistakes++) {
      final g = fresh();
      for (final row in wrongs.take(mistakes)) {
        guess(g, row);
        g.extraLife();
      }
      solveRemaining(g);
      expect(g.status, GameStatus.won);
      expect(g.lives, 4);
      expect(g.stars, [3, 2, 2, 1, 1][mistakes]);
    }
  });

  test('ENG-12 exact campaign and Daily share, finalized only, no duplicate rows', () {
    final g = fresh();
    const campaign = CampaignHeader('Everyday Echoes', 1);
    final daily = DailyHeader(DateTime(2026, 10, 27));
    expect(formatShare(g, campaign), isNull);
    guess(g, wrongs[0]);
    guess(g, wrongs[0].reversed.toList());
    guess(g, ['MARS', 'MERCURY', 'VENUS', 'GOLD']);
    solveRemaining(g);
    const body =
        '★★☆ · 2 mistakes\n🟨🟨🟨🟩\n🟨🟩🟨🟩\n🟨🟨🟨🟨\n🟩🟩🟩🟩\n🟦🟦🟦🟦\n🟪🟪🟪🟪';
    expect(formatShare(g, campaign), 'LexiStack · Everyday Echoes #1\n$body');
    expect(formatShare(g, daily), 'LexiStack · Daily 2026-10-27\n$body');
    final loss = fresh();
    guess(loss, ['RED', 'BLUE', 'GREEN', 'WHITE']);
    for (final row in [
      wrongs[0],
      wrongs[1],
      ['MARS', 'VENUS', 'OAK', 'BIRCH'],
      ['SATURN', 'IRON', 'PINE', 'ELM'],
    ]) {
      guess(loss, row);
    }
    expect(formatShare(loss, daily), isNull);
    loss.revealLoss();
    expect(
      formatShare(loss, daily),
      'LexiStack · Daily 2026-10-27\n1/4 groups · 4 mistakes\n🟪🟪🟪🟪\n🟨🟨🟨🟩\n🟨🟨🟩🟩\n🟨🟨🟦🟦\n🟨🟩🟦🟦',
    );
    final perfect = fresh();
    solveRemaining(perfect);
    expect(formatShare(perfect, campaign)!.split('\n')[1], '★★★ · 0 mistakes');
    final rescued = fresh();
    lose(rescued);
    rescued.extraLife();
    solveRemaining(rescued);
    expect(formatShare(rescued, campaign)!.split('\n')[1], '★☆☆ · 4 mistakes');
  });

  test(
    'all forty installed frozen levels are solvable by their intended groups',
    () {
      final catalog = installedCatalog();
      expect(catalog.packs.expand((p) => p.levels), hasLength(40));
      for (final level in catalog.packs.expand((p) => p.levels)) {
        final g = Game(level, seed: 20261028);
        solveRemaining(g);
        expect(g.status, GameStatus.won, reason: level.id);
        expect(g.stars, 3);
        expect(g.guesses, hasLength(4));
      }
    },
  );

  test('PRNG rejects seeds outside its documented range', () {
    for (final seed in [-1, 0, StableRandom.modulus]) {
      expect(() => StableRandom(seed), throwsRangeError);
    }
  });
}

void assertTerminal(Game g) {
  final before = snapshot(g);
  for (final action in [
    g.submit,
    g.revealLoss,
    g.extraLife,
    g.pairMagnet,
    g.categoryPeek,
    g.shuffle,
    g.deselect,
    () => g.toggle(g.level.tiles.first.id),
    () => g.drag(g.level.tiles.first.id),
  ]) {
    expect(action(), isA<Rejected>());
    expect(snapshot(g), before);
  }
}
