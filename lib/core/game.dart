import 'dart:convert';

import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import 'prng.dart';
import 'scoring.dart';

enum GameStatus { playing, won, lostPendingDecision, lostFinal }

enum Rejection {
  invalidState,
  invalidSelection,
  invalidTile,
  selectionFull,
  noChange,
  noEligibleCategory,
  livesFull,
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
