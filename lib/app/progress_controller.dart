import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../core/daily.dart';
import '../core/game.dart';
import '../core/prng.dart';
import '../core/share.dart';
import 'progress.dart';
import 'storage.dart';

/// A transition settles and captures one complete document synchronously;
/// only the serial storage write is asynchronous.
class ProgressController extends ChangeNotifier {
  ProgressController({
    required this.catalog,
    required this.storage,
    required this.clock,
  });
  final Catalog catalog;
  final ProgressStorage storage;
  final LocalClock clock;
  Progress _state = Progress();
  Progress get state => _state;
  Future<void> _writes = Future.value();
  int _revision = 0, _savedRevision = 0;
  bool _disposed = false;
  String? storageWarning;
  String? recoveryNotice;
  bool get saved => _savedRevision == _revision && storageWarning == null;
  String get today => dayKey(clock());
  List<Pack> get campaignPacks =>
      catalog.packs.take(catalog.manifest.campaign.length).toList();
  List<Level> get dailyLevels =>
      catalog.manifest.daily == null ? [] : catalog.packs.last.levels;

  Future<void> load() async {
    try {
      _state = Progress.decode(await storage.read(), catalog, clock());
      if (_state.recovery.isNotEmpty) {
        recoveryNotice = _state.recovery.join(' ');
      }
    } catch (_) {
      storageWarning = 'Progress could not be read. Changes are not yet saved.';
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _save() {
    final document = _state.encode();
    final revision = ++_revision;
    _writes = _writes.then((_) async {
      try {
        await storage.write(document);
        _savedRevision = revision;
        if (revision == _revision) storageWarning = null;
      } catch (_) {
        storageWarning =
            'Progress not saved. Keep the app open and retry saving.';
      }
      _notify();
    });
    _notify();
  }

  Future<void> flush() => _writes;
  void retrySave() => _save();

  void refreshDay() {
    if (_state.dailyAttempt != null && _state.dailyAttempt!.date != today) {
      _state.dailyAttempt = null;
      _save();
    } else {
      _notify();
    }
  }

  bool unlocked(Level level) {
    for (final pack in campaignPacks) {
      final index = pack.levels.indexWhere((l) => l.id == level.id);
      if (index >= 0) {
        return index == 0 ||
            _state.campaign.containsKey(pack.levels[index - 1].id);
      }
    }
    return false;
  }

  FinalizedResult? resultFor(String levelId, {String? date}) => _state.results
      .where(
        (r) => date == null
            ? r.date == null && r.levelId == levelId
            : r.date == date,
      )
      .lastOrNull;
  FinalizedResult? resultById(String id) =>
      _state.results.where((r) => r.id == id).firstOrNull;

  Attempt? _resultBoard(FinalizedResult? result) {
    if (result?.board == null) return null;
    try {
      final attempt = Attempt.restore(result!.board, {
        for (final p in catalog.packs)
          for (final l in p.levels) l.id: l,
      });
      if (attempt.id != result.id ||
          attempt.date != result.date ||
          attempt.levelId != result.levelId ||
          !attempt.game.isFinal ||
          (attempt.game.status == GameStatus.won) != result.won ||
          attempt.game.mistakes != result.mistakes ||
          jsonEncode(attempt.game.snapshot()['guesses']) !=
              jsonEncode(result.rows)) {
        return null;
      }
      return attempt;
    } on FormatException {
      return null;
    }
  }

  Attempt _create(Level level, {String? date}) {
    final serial = ++_state.sequence;
    final attempt = Attempt(
      id: 'a$serial',
      entered: serial,
      date: date,
      game: Game(
        level,
        seed: date == null
            ? serial % (StableRandom.modulus - 1) + 1
            : dailySeed(parseDay(date)),
      ),
    );
    if (date == null) {
      _state.attempts[level.id] = attempt;
    } else {
      _state.dailyAttempt = attempt;
    }
    _save();
    return attempt;
  }

  Attempt? enterCampaign(Level level, {bool replay = false}) {
    if (!unlocked(level)) return null;
    final active = _state.attempts[level.id];
    if (active != null) {
      active.entered = ++_state.sequence;
      _save();
      return active;
    }
    final result = resultFor(level.id);
    if (result != null && !replay) return _resultBoard(result);
    if (_state.campaign.containsKey(level.id) && !replay) return null;
    return _create(level);
  }

  Attempt? continueCampaign() {
    final unfinished = _state.attempts.values.toList()
      ..sort((a, b) => b.entered.compareTo(a.entered));
    if (unfinished.isNotEmpty) {
      return enterCampaign(unfinished.first.game.level);
    }
    for (final pack in campaignPacks) {
      for (final level in pack.levels) {
        if (unlocked(level) && !_state.campaign.containsKey(level.id)) {
          return enterCampaign(level);
        }
      }
    }
    return null;
  }

  Attempt? enterDaily() {
    refreshDay();
    if (_state.daily.containsKey(today)) {
      return _resultBoard(resultFor('', date: today));
    }
    if (_state.unavailableDaily.contains(today) ||
        _state.rewardLocks.contains('*') ||
        dailyLevels.isEmpty) {
      return null;
    }
    return _state.dailyAttempt ??
        _create(
          dailyLevels[dailyPoolIndex(clock(), dailyLevels.length)],
          date: today,
        );
  }

  bool isCurrent(Attempt attempt) =>
      !attempt.game.isFinal &&
      (attempt.date == null
          ? identical(_state.attempts[attempt.levelId], attempt)
          : attempt.date == today && identical(_state.dailyAttempt, attempt));

  GameOutcome apply(
    Attempt attempt,
    GameOutcome Function(Game) action, {
    int price = 0,
  }) {
    if (_state.dailyAttempt?.date != null &&
        _state.dailyAttempt!.date != today) {
      refreshDay();
    }
    if (!isCurrent(attempt)) return const Rejected(Rejection.staleAttempt);
    if (_state.coins < price) return const Rejected(Rejection.unaffordable);
    final outcome = action(attempt.game);
    if (outcome is Rejected || outcome is AlreadyGuessed) return outcome;
    _state.coins -= price;
    if (attempt.game.isFinal) _settle(attempt);
    _save();
    return outcome;
  }

  void _settle(Attempt attempt) {
    if (resultById(attempt.id) != null ||
        _state.retiredIds.contains(attempt.id)) {
      return;
    }
    final game = attempt.game;
    final won = game.status == GameStatus.won;
    var reward = 0;
    var kind = 'loss';
    final locked =
        _state.rewardLocks.contains('*') ||
        _state.rewardLocks.contains(attempt.levelId);
    if (attempt.date != null) {
      if (won && !_state.daily.containsKey(attempt.date) && !locked) {
        reward = starReward(game.stars) + 25;
        kind = 'daily';
      } else if (won) {
        kind = 'suppressed';
      }
      _state.daily[attempt.date!] = DailyOutcome(attempt.id, won);
      _state.dailyAttempt = null;
      final streak = _state.currentStreak(clock());
      if (streak > _state.bestDailyStreak) _state.bestDailyStreak = streak;
    } else {
      if (won) {
        final old = _state.campaign[attempt.levelId];
        if (locked) {
          kind = 'suppressed';
        } else if (old == null) {
          reward = starReward(game.stars);
          kind = 'first';
        } else if (!old.practicePaid) {
          reward = 5;
          kind = 'practice';
        } else {
          kind = 'repeat';
        }
        final achievement = old ?? Achievement(game.stars);
        if (game.stars > achievement.bestStars) {
          achievement.bestStars = game.stars;
        }
        if (kind == 'practice' || locked) achievement.practicePaid = true;
        _state.campaign[attempt.levelId] = achievement;
      }
      _state.attempts.remove(attempt.levelId);
    }
    final pack = catalog.packs.firstWhere((p) => p.id == game.level.packId);
    final header = attempt.date == null
        ? CampaignHeader(
            pack.title,
            pack.levels.indexWhere((l) => l.id == attempt.levelId) + 1,
          ).text
        : DailyHeader(parseDay(attempt.date!)).text;
    _state.coins += reward;
    _state.results.add(
      FinalizedResult(
        id: attempt.id,
        levelId: attempt.levelId,
        date: attempt.date,
        header: header,
        won: won,
        mistakes: game.mistakes,
        groups: game.solvedIds.length,
        reward: reward,
        rewardKind: kind,
        rows: [
          for (final g in game.guesses)
            {'ids': g.tileIds, 'tiers': g.tiers, 'correct': g.correct},
        ],
        board: attempt.toJson(),
      ),
    );
  }

  void setSettings({String? theme, bool? haptics}) {
    if (theme != null && !['system', 'light', 'dark'].contains(theme)) return;
    if (theme != null) _state.theme = theme;
    if (haptics != null) _state.haptics = haptics;
    _save();
  }

  void reset({required bool confirmed}) {
    if (!confirmed) return;
    _state = Progress();
    recoveryNotice = null;
    _save();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
