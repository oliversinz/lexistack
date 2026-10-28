import 'dart:convert';

import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import 'prng.dart';
import 'scoring.dart';
import 'saved_value.dart';

enum GameStatus { playing, won, lostPendingDecision, lostFinal }

enum Rejection {
  invalidState,
  invalidSelection,
  invalidTile,
  selectionFull,
  noChange,
  noEligibleCategory,
  livesFull,
  unaffordable,
  staleAttempt,
}

sealed class GameOutcome {
  const GameOutcome();
}

final class Applied extends GameOutcome {
  const Applied();
}

final class Rejected extends GameOutcome {
  const Rejected(this.reason);
  final Rejection reason;
}

final class AlreadyGuessed extends GameOutcome {
  const AlreadyGuessed();
}

final class Solved extends GameOutcome {
  const Solved(this.category);
  final Category category;
}

final class Mismatch extends GameOutcome {
  const Mismatch({required this.isOneAway});
  final bool isOneAway;
}

final class EvaluatedGuess {
  EvaluatedGuess(List<Tile> tiles, {required this.correct})
    : tileIds = List.unmodifiable(tiles.map((tile) => tile.id)),
      tiers = List.unmodifiable(tiles.map((tile) => tile.difficultyTier));

  final List<String> tileIds;
  final List<int> tiers;
  final bool correct;
}

/// One attempt. Content is the shared immutable model; mutable session data
/// stays private. UI/controllers use transitions, never write game state.
final class Game {
  Game(this.level, {required this.seed})
    : _random = StableRandom(seed),
      _tiles = {for (final tile in level.tiles) tile.id: tile},
      _order = level.tiles.map((tile) => tile.id).toList() {
    _random.shuffle(_order);
  }

  Game._restored(this.level, this.seed, int rngState)
    : _random = StableRandom(rngState),
      _tiles = {for (final tile in level.tiles) tile.id: tile},
      _order = [];

  /// Re-evaluate history through the real transitions, then restore only data
  /// whose references and cross-field invariants have been checked. Historical
  /// hints may refer to subsequently solved categories.
  factory Game.restore(Level level, Object? value) {
    final data = savedMap(value);
    final seed = savedInt(data['seed'], 1, StableRandom.modulus - 1);
    final rng = savedInt(data['rng'], 1, StableRandom.modulus - 1);
    final status = GameStatus.values
        .where((s) => s.name == data['status'])
        .firstOrNull;
    requireSaved(status != null, 'Unknown game status');
    final lives = savedInt(data['lives'], 0, 4);
    final mistakes = savedInt(data['mistakes'], 0, 1820);
    final extras = savedInt(data['extraLives'], 0, mistakes);
    final combo = savedInt(data['combo'], 0, 4);
    requireSaved(lives == 4 + extras - mistakes, 'Impossible life arithmetic');
    final replay = Game(level, seed: seed);
    for (final raw in savedList(data['guesses'])) {
      requireSaved(!replay.isFinal, 'Guesses after victory');
      final row = savedMap(raw);
      final ids = savedStrings(row['ids']);
      final tiers = savedList(row['tiers'])
          .map((t) => savedInt(t, 1, 4))
          .toList();
      final correct = savedBool(row['correct']);
      requireSaved(ids.length == 4 && tiers.length == 4);
      requireSaved(
        ids.every(replay._eligible),
        'Guessed solved or unknown tile',
      );
      requireSaved(
        jsonEncode(tiers) ==
            jsonEncode(
              ids.map((id) => replay.tile(id).difficultyTier).toList(),
            ),
      );
      if (replay.status == GameStatus.lostPendingDecision) replay.extraLife();
      replay.deselect();
      for (final id in ids) {
        replay.toggle(id);
      }
      final outcome = replay.submit();
      requireSaved(
        outcome is Solved || outcome is Mismatch,
        'Duplicate evaluated guess',
      );
      requireSaved((outcome is Solved) == correct, 'Wrong guess correctness');
    }
    requireSaved(replay.mistakes == mistakes && replay.combo == combo);
    requireSaved(
      replay.extraLivesUsed <= extras,
      'Impossible rescue chronology',
    );
    requireSaved(
      replay.solvedIds.length == 4
          ? status == GameStatus.won
          : status != GameStatus.won,
    );
    requireSaved(
      lives == 0
          ? status == GameStatus.lostPendingDecision ||
                status == GameStatus.lostFinal
          : status == GameStatus.playing || status == GameStatus.won,
    );
    final solved = savedStrings(data['solved']);
    requireSaved(
      jsonEncode(solved) == jsonEncode(replay.solvedIds),
      'Solved chronology mismatch',
    );
    final wrong = savedStrings(data['wrong']);
    requireSaved(
      wrong.length == replay.wrongSignatures.length &&
          wrong.every(replay.wrongSignatures.contains),
    );
    final order = savedStrings(data['order']);
    // Length alone is insufficient: savedStrings also requires unique IDs.
    requireSaved(
      order.length == replay.order.length && order.every(replay.order.contains),
      'Board is not an unsolved permutation',
    );
    final selection = savedStrings(data['selection']);
    requireSaved(selection.length <= 4 && selection.every(order.contains));
    if (lives == 0) {
      requireSaved(
        jsonEncode(selection) == jsonEncode(replay.selection),
        'Pending selection changed',
      );
    }
    final game = Game._restored(level, seed, rng);
    game._order.addAll(order);
    game._selection.addAll(selection);
    game._solved.addAll(solved);
    game._guesses.addAll(replay.guesses);
    game._wrongSignatures.addAll(wrong);
    final categories = {for (final c in level.categories) c.id: c};
    for (final entry in savedMap(data['pairs']).entries) {
      final pair = savedStrings(entry.value);
      final category = categories[entry.key];
      requireSaved(category != null && pair.length == 2);
      requireSaved(pair.every((id) => category!.tiles.any((t) => t.id == id)));
      requireSaved(pair.contains(category!.tiles.first.id), 'Impossible pair');
      game._pairs[entry.key] = List.unmodifiable(pair);
    }
    final peeked = savedStrings(data['peeked']);
    requireSaved(peeked.every(categories.containsKey));
    game._peeked.addAll(peeked);
    game._status = status!;
    game._lives = lives;
    game._mistakes = mistakes;
    game._combo = combo;
    game._extraLivesUsed = extras;
    return game;
  }

  Map<String, Object?> snapshot() => {
    'seed': seed,
    'rng': rngState,
    'status': status.name,
    'lives': lives,
    'mistakes': mistakes,
    'combo': combo,
    'extraLives': extraLivesUsed,
    'order': order,
    'selection': selection,
    'solved': solvedIds,
    'wrong': wrongSignatures.toList(),
    'pairs': pairs,
    'peeked': peekedIds.toList(),
    'guesses': [
      for (final g in guesses)
        {'ids': g.tileIds, 'tiers': g.tiers, 'correct': g.correct},
    ],
  };

  final Level level;
  final int seed;
  final StableRandom _random;
  final Map<String, Tile> _tiles;
  final List<String> _order;
  final List<String> _selection = [];
  final List<String> _solved = [];
  final List<EvaluatedGuess> _guesses = [];
  final Set<String> _wrongSignatures = {};
  final Map<String, List<String>> _pairs = {};
  final Set<String> _peeked = {};
  GameStatus _status = GameStatus.playing;
  int _lives = 4;
  int _mistakes = 0;
  int _combo = 0;
  int _extraLivesUsed = 0;

  GameStatus get status => _status;
  int get lives => _lives;
  int get mistakes => _mistakes;
  int get combo => _combo;
  int get extraLivesUsed => _extraLivesUsed;
  int get rngState => _random.state;
  int get stars => starsForMistakes(_mistakes);
  bool get isFinal =>
      _status == GameStatus.won || _status == GameStatus.lostFinal;
  bool get canSubmit => _status == GameStatus.playing && _selection.length == 4;
  bool get canPair =>
      _status == GameStatus.playing &&
      remainingCategories.any((c) => !_pairs.containsKey(c.id));
  bool get canPeek =>
      _status == GameStatus.playing &&
      remainingCategories.any((c) => !_peeked.contains(c.id));
  bool get canExtraLife => !isFinal && _lives < 4;
  List<String> get order => List.unmodifiable(_order);
  List<String> get selection => List.unmodifiable(_selection);
  List<String> get solvedIds => List.unmodifiable(_solved);
  List<EvaluatedGuess> get guesses => List.unmodifiable(_guesses);
  Set<String> get wrongSignatures => Set.unmodifiable(_wrongSignatures);
  Map<String, List<String>> get pairs => Map.unmodifiable(_pairs);
  Set<String> get peekedIds => Set.unmodifiable(_peeked);
  Tile tile(String id) => _tiles[id]!;

  List<Category> get remainingCategories =>
      level.categories.where((c) => !_solved.contains(c.id)).toList();

  /// Full solution cards are unavailable until solved or explicitly finalized.
  List<Category> get revealedCategories => List.unmodifiable(
    isFinal
        ? level.categories
        : _solved.map((id) => level.categories.firstWhere((c) => c.id == id)),
  );

  List<RedHerring> get revealedRedHerrings {
    if (!isFinal) return const [];
    final wrongWords = _guesses
        .where((g) => !g.correct)
        .expand((g) => g.tileIds)
        .map((id) => tile(id).text)
        .toSet();
    bool relevant(RedHerring h) => h.tiles.any(wrongWords.contains);
    return List.unmodifiable([
      ...level.redHerrings.where(relevant),
      ...level.redHerrings.where((h) => !relevant(h)),
    ]);
  }

  bool _eligible(String id) => _order.contains(id);

  GameOutcome toggle(String id) {
    if (_status != GameStatus.playing) {
      return const Rejected(Rejection.invalidState);
    }
    if (!_eligible(id)) return const Rejected(Rejection.invalidTile);
    if (_selection.remove(id)) return const Applied();
    return _add(id);
  }

  GameOutcome _add(String id) {
    if (_selection.contains(id)) return const Rejected(Rejection.noChange);
    if (_selection.length == 4) return const Rejected(Rejection.selectionFull);
    _selection.add(id);
    return const Applied();
  }

  /// A drop adds the source first, then the optional target within the cap.
  /// Invalid sources/targets reject the entire gesture before changing state.
  GameOutcome drag(String source, {String? target}) {
    if (_status != GameStatus.playing) {
      return const Rejected(Rejection.invalidState);
    }
    if (!_eligible(source) || (target != null && !_eligible(target))) {
      return const Rejected(Rejection.invalidTile);
    }
    final sourceResult = _add(source);
    final targetResult = target == null ? null : _add(target);
    return sourceResult is Applied || targetResult is Applied
        ? const Applied()
        : sourceResult;
  }

  GameOutcome deselect() {
    if (_status != GameStatus.playing) {
      return const Rejected(Rejection.invalidState);
    }
    if (_selection.isEmpty) return const Rejected(Rejection.noChange);
    _selection.clear();
    return const Applied();
  }

  GameOutcome shuffle() {
    if (_status != GameStatus.playing) {
      return const Rejected(Rejection.invalidState);
    }
    _random.shuffle(_order);
    return const Applied();
  }

  GameOutcome submit() {
    if (_status != GameStatus.playing) {
      return const Rejected(Rejection.invalidState);
    }
    if (!canSubmit) return const Rejected(Rejection.invalidSelection);
    final sorted = [..._selection]..sort();
    final signature = jsonEncode(sorted);
    if (_wrongSignatures.contains(signature)) return const AlreadyGuessed();
    final selectedTiles = _selection.map(tile).toList();
    final counts = <String, int>{};
    for (final tile in selectedTiles) {
      counts.update(tile.categoryId, (n) => n + 1, ifAbsent: () => 1);
    }
    final correct = counts.length == 1;
    _guesses.add(EvaluatedGuess(selectedTiles, correct: correct));
    if (correct) {
      final category = remainingCategories.firstWhere(
        (c) => c.id == counts.keys.single,
      );
      _solved.add(category.id);
      _order.removeWhere(_selection.contains);
      _selection.clear();
      _combo++;
      if (_solved.length == 4) _status = GameStatus.won;
      return Solved(category);
    }
    _wrongSignatures.add(signature);
    _mistakes++;
    _lives--;
    _combo = 0;
    if (_lives == 0) _status = GameStatus.lostPendingDecision;
    return Mismatch(isOneAway: counts.values.contains(3));
  }

  List<Category> get _byTier =>
      remainingCategories
        ..sort((a, b) => a.difficultyTier.compareTo(b.difficultyTier));

  GameOutcome pairMagnet() {
    if (_status != GameStatus.playing) {
      return const Rejected(Rejection.invalidState);
    }
    final eligible = _byTier.where((c) => !_pairs.containsKey(c.id)).toList();
    if (eligible.isEmpty) return const Rejected(Rejection.noEligibleCategory);
    final selected = _selection.isEmpty ? null : tile(_selection.last);
    final category = eligible.firstWhere(
      (c) => c.id == selected?.categoryId,
      orElse: () => eligible.first,
    );
    final first = selected?.categoryId == category.id
        ? selected!
        : category.tiles.first;
    final second = category.tiles.firstWhere((t) => t.id != first.id);
    _pairs[category.id] = List.unmodifiable([first.id, second.id]);
    return const Applied();
  }

  GameOutcome categoryPeek() {
    if (_status != GameStatus.playing) {
      return const Rejected(Rejection.invalidState);
    }
    final eligible = _byTier.where((c) => !_peeked.contains(c.id));
    if (eligible.isEmpty) return const Rejected(Rejection.noEligibleCategory);
    _peeked.add(eligible.first.id);
    return const Applied();
  }

  GameOutcome extraLife() {
    if (isFinal) return const Rejected(Rejection.invalidState);
    if (_lives == 4) return const Rejected(Rejection.livesFull);
    _lives++;
    _extraLivesUsed++;
    _status = GameStatus.playing;
    return const Applied();
  }

  GameOutcome revealLoss() {
    if (_status != GameStatus.lostPendingDecision) {
      return const Rejected(Rejection.invalidState);
    }
    _status = GameStatus.lostFinal;
    return const Applied();
  }
}
