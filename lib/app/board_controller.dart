import 'package:flutter/foundation.dart';

import '../core/game.dart';

/// F2 only: retained while the app lives, with no wallet or disk writes.
class BoardController extends ChangeNotifier {
  BoardController(Game game) : _game = game;

  Game _game;
  Game get game => _game;
  String feedback = 'Find four words that belong together.';

  void _apply(GameOutcome outcome, [String? success]) {
    if (outcome is Rejected) return;
    feedback = switch (outcome) {
      Solved(:final category) => 'Correct! ${category.title}',
      Mismatch(isOneAway: true) => 'One Away! Change one word and try again.',
      Mismatch() => 'Not a group. Try a different connection.',
      AlreadyGuessed() => 'Already guessed! No life lost.',
      _ => success ?? 'Find four words that belong together.',
    };
    notifyListeners();
  }

  void toggle(String id) => _apply(_game.toggle(id));
  void drag(String id, {String? target}) =>
      _apply(_game.drag(id, target: target));
  void deselect() => _apply(_game.deselect());
  void shuffle() =>
      _apply(_game.shuffle(), 'Shuffled. Your selection is kept.');
  void submit() => _apply(_game.submit());
  void pairMagnet() => _apply(_game.pairMagnet(), 'A matching pair is marked.');
  void categoryPeek() =>
      _apply(_game.categoryPeek(), 'A category title is open.');
  void extraLife() =>
      _apply(_game.extraLife(), 'One life restored. Same attempt.');
  void revealLoss() => _apply(_game.revealLoss());

  void newAttempt() {
    _game = Game(_game.level, seed: _game.seed);
    feedback = 'New F2 preview attempt.';
    notifyListeners();
  }
}
