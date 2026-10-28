import 'package:flutter/foundation.dart';

import '../core/game.dart';
import 'progress.dart';
import 'progress_controller.dart';

/// A board handle; the shared progress controller owns money and persistence.
class BoardController extends ChangeNotifier {
  BoardController(this.progress, Attempt attempt) : _attempt = attempt {
    progress.addListener(notifyListeners);
  }
  final ProgressController progress;
  Attempt _attempt;
  Attempt get attempt => _attempt;
  Game get game => _attempt.game;
  int get coins => progress.state.coins;
  String? get date => _attempt.date;
  bool get expired => date != null && date != progress.today && !game.isFinal;
  bool get active => progress.isCurrent(_attempt);
  bool get canPair => active && coins >= 30 && game.canPair;
  bool get canPeek => active && coins >= 40 && game.canPeek;
  bool get canExtraLife => active && coins >= 60 && game.canExtraLife;
  FinalizedResult? get result => progress.resultById(_attempt.id);
  String feedback = 'Find four words that belong together.';

  GameOutcome _apply(
    GameOutcome Function(Game) action, {
    String? success,
    int price = 0,
  }) {
    final outcome = progress.apply(_attempt, action, price: price);
    feedback = switch (outcome) {
      Solved(:final category) => 'Correct! ${category.title}',
      Mismatch(isOneAway: true) => 'One Away! Change one word and try again.',
      Mismatch() => 'Not a group. Try a different connection.',
      AlreadyGuessed() => 'Already guessed! No life lost.',
      Rejected(reason: Rejection.unaffordable) => 'Not enough coins.',
      Rejected(reason: Rejection.staleAttempt) =>
        'This attempt is no longer active.',
      Rejected() => feedback,
      _ => success ?? 'Find four words that belong together.',
    };
    notifyListeners();
    return outcome;
  }

  GameOutcome toggle(String id) => _apply((g) => g.toggle(id));
  GameOutcome drag(String id, {String? target}) =>
      _apply((g) => g.drag(id, target: target));
  GameOutcome deselect() => _apply((g) => g.deselect());
  GameOutcome shuffle() =>
      _apply((g) => g.shuffle(), success: 'Shuffled. Your selection is kept.');
  GameOutcome submit() => _apply((g) => g.submit());
  GameOutcome pairMagnet() => _apply(
    (g) => g.pairMagnet(),
    price: 30,
    success: 'A matching pair is marked.',
  );
  GameOutcome categoryPeek() => _apply(
    (g) => g.categoryPeek(),
    price: 40,
    success: 'A category title is open.',
  );
  GameOutcome extraLife() => _apply(
    (g) => g.extraLife(),
    price: 60,
    success: 'One life restored. Same attempt.',
  );
  GameOutcome revealLoss() => _apply((g) => g.revealLoss());

  void newAttempt() {
    if (date != null || !game.isFinal) return;
    final next = progress.enterCampaign(game.level, replay: true);
    if (next == null) return;
    _attempt = next;
    feedback = 'New campaign attempt.';
    notifyListeners();
  }

  @override
  void dispose() {
    progress.removeListener(notifyListeners);
    super.dispose();
  }
}
