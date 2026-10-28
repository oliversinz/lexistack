import 'dart:convert';

import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../core/content_identity.dart';
import '../core/daily.dart';
import '../core/game.dart';
import '../core/saved_value.dart';
import '../core/scoring.dart';

// Bound imported counters well below the web integer precision limit.
const maxCounter = 1000000000000;
int attemptNumber(String id) {
  requireSaved(RegExp(r'^a[1-9][0-9]*$').hasMatch(id));
  return savedInt(int.tryParse(id.substring(1)), 1, maxCounter);
}

class Attempt {
  Attempt({
    required this.id,
    required this.game,
    required this.entered,
    this.date,
  });
  final String id;
  final Game game;
  final String? date;
  int entered;
  String get levelId => game.level.id;
  Map<String, Object?> toJson() => {
    'id': id,
    'levelId': levelId,
    'date': date,
    'entered': entered,
    'fingerprint': contentFingerprint(game.level),
    'game': game.snapshot(),
  };

  static Attempt restore(Object? raw, Map<String, Level> levels) {
    final data = savedMap(raw);
    final id = savedString(data['id']);
    attemptNumber(id);
    final level = levels[savedString(data['levelId'])];
    requireSaved(level != null, 'Level no longer installed');
    requireSaved(
      data['fingerprint'] == contentFingerprint(level!),
      'Content changed',
    );
    final date = data['date'] == null ? null : savedString(data['date']);
    if (date != null) parseDay(date);
    return Attempt(
      id: id,
      game: Game.restore(level, data['game']),
      entered: savedInt(data['entered'], 1, maxCounter),
      date: date,
    );
  }
}

class Achievement {
  Achievement(this.bestStars, {this.practicePaid = false});
  int bestStars;
  bool practicePaid;
  Map<String, Object?> toJson() => {
    'bestStars': bestStars,
    'practicePaid': practicePaid,
  };
}

class DailyOutcome {
  DailyOutcome(this.id, this.won);
  final String id;
  final bool won;
  Map<String, Object?> toJson() => {'id': id, 'won': won};
}

/// Catalog-independent history. Board data is optional on recovery; losing it
/// cannot erase the statistical result, its settlement, or its share rows.
class FinalizedResult {
  FinalizedResult({
    required this.id,
    required this.levelId,
    required this.date,
    required this.header,
    required this.won,
    required this.mistakes,
    required this.groups,
    required this.rows,
    required this.reward,
    required this.rewardKind,
    this.board,
  });
  final String id, levelId, header, rewardKind;
  final String? date;
  final bool won;
  final int mistakes, groups, reward;
  final List<Map<String, Object?>> rows;
  final Map<String, dynamic>? board;
  int get stars => won ? starsForMistakes(mistakes) : 0;
  String get shareText {
    const emoji = ['🟨', '🟩', '🟦', '🟪'];
    final rating = won
        ? '${'★' * stars}${'☆' * (3 - stars)}'
        : '$groups/4 groups';
    return [
      header,
      '$rating · $mistakes mistakes',
      for (final row in rows)
        (row['tiers'] as List<int>).map((t) => emoji[t - 1]).join(),
    ].join('\n');
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'levelId': levelId,
    'date': date,
    'header': header,
    'won': won,
    'mistakes': mistakes,
    'groups': groups,
    'rows': rows,
    'reward': reward,
    'rewardKind': rewardKind,
    'board': board,
  };

  static FinalizedResult restore(Object? raw) {
    final data = savedMap(raw);
    final id = savedString(data['id']);
    attemptNumber(id);
    final levelId = savedString(data['levelId']);
    final date = data['date'] == null ? null : savedString(data['date']);
    if (date != null) parseDay(date);
    final won = savedBool(data['won']);
    final mistakes = savedInt(data['mistakes'], 0, 1820);
    final groups = savedInt(data['groups'], 0, 4);
    final reward = savedInt(data['reward'], 0, 75);
    final kind = savedString(data['rewardKind']);
    final stars = starsForMistakes(mistakes);
    final base = starReward(stars);
    final expected = switch (kind) {
      'first' when date == null && won => base,
      'practice' when date == null && won => 5,
      'repeat' when date == null && won => 0,
      'daily' when date != null && won => base + 25,
      'loss' when !won => 0,
      'suppressed' when won => 0,
      _ => -1,
    };
    requireSaved(reward == expected, 'Invalid settlement');
    final solved = <String>{};
    final wrong = <String>{};
    final tiersByCategory = <String, int>{};
    final rows = <Map<String, Object?>>[];
    for (final rawRow in savedList(data['rows'])) {
      requireSaved(solved.length < 4);
      final row = savedMap(rawRow);
      final ids = savedStrings(row['ids']);
      final tiers = savedList(row['tiers'])
          .map((t) => savedInt(t, 1, 4))
          .toList();
      final correct = savedBool(row['correct']);
      requireSaved(ids.length == 4 && tiers.length == 4);
      final categories = <String>{};
      for (var i = 0; i < 4; i++) {
        final tile = savedList(jsonDecode(ids[i]));
        requireSaved(tile.length == 3 && tile[0] == levelId);
        final category = savedString(tile[1]);
        savedInt(tile[2], 0, 3);
        requireSaved(ids[i] == jsonEncode(tile) && !solved.contains(category));
        requireSaved(
          !tiersByCategory.containsKey(category) ||
              tiersByCategory[category] == tiers[i],
        );
        tiersByCategory[category] = tiers[i];
        categories.add(category);
      }
      requireSaved(correct == (categories.length == 1));
      if (correct) {
        solved.add(categories.single);
      } else {
        final sorted = [...ids]..sort();
        requireSaved(wrong.add(jsonEncode(sorted)), 'Duplicate history row');
      }
      rows.add({'ids': ids, 'tiers': tiers, 'correct': correct});
    }
    requireSaved(
      tiersByCategory.values.toSet().length == tiersByCategory.length,
    );
    requireSaved(wrong.length == mistakes && solved.length == groups);
    requireSaved(won ? groups == 4 : groups < 4 && mistakes >= 4);
    final header = savedString(data['header']);
    requireSaved(!header.contains('\n') && header.startsWith('LexiStack · '));
    if (date != null) requireSaved(header == 'LexiStack · Daily $date');
    return FinalizedResult(
      id: id,
      levelId: levelId,
      date: date,
      header: header,
      won: won,
      mistakes: mistakes,
      groups: groups,
      rows: rows,
      reward: reward,
      rewardKind: kind,
      board: data['board'] is Map<String, dynamic>
          ? data['board'] as Map<String, dynamic>
          : null,
    );
  }
}

int starReward(int stars) => switch (stars) {
  3 => 50,
  2 => 30,
  _ => 15,
};

class Progress {
  static const version = 1;
  int coins = 150;
  int sequence = 0;
  final Map<String, Achievement> campaign = {};
  final List<FinalizedResult> results = [];
  final Map<String, DailyOutcome> daily = {};
  final Map<String, Attempt> attempts = {};
  Attempt? dailyAttempt;
  int bestDailyStreak = 0;
  String theme = 'system';
  bool haptics = true;
  // Recovery tombstones prevent corrupt ledger entries becoming fresh payouts.
  final Set<String> retiredIds = {};
  final Set<String> rewardLocks = {};
  final Set<String> unavailableDaily = {};
  final List<String> recovery = [];

  Map<String, Object?> toJson() => {
    'version': version,
    'coins': coins,
    'sequence': sequence,
    'campaign': {for (final e in campaign.entries) e.key: e.value.toJson()},
    'results': results.map((r) => r.toJson()).toList(),
    'daily': {for (final e in daily.entries) e.key: e.value.toJson()},
    'attempts': attempts.values.map((a) => a.toJson()).toList(),
    'dailyAttempt': dailyAttempt?.toJson(),
    'bestDailyStreak': bestDailyStreak,
    'settings': {'theme': theme, 'haptics': haptics},
    'retiredIds': retiredIds.toList(),
    'rewardLocks': rewardLocks.toList(),
    'unavailableDaily': unavailableDaily.toList(),
  };

  String encode() => jsonEncode(toJson());

  static Progress decode(String? bytes, Catalog catalog, DateTime today) {
    final p = Progress();
    if (bytes == null) return p;
    late Map<String, dynamic> root;
    try {
      root = savedMap(jsonDecode(bytes));
      savedInt(root['version'], version, version);
    } on FormatException {
      p.recovery.add(
        'Unreadable or unsupported save. Fresh defaults restored.',
      );
      return p;
    }
    void salvage(String name, void Function() read) {
      try {
        read();
      } on FormatException {
        p.recovery.add('Recovered without invalid $name.');
      }
    }

    salvage('wallet', () => p.coins = savedInt(root['coins'], 0, maxCounter));
    salvage(
      'counter',
      () => p.sequence = savedInt(root['sequence'], 0, maxCounter),
    );
    salvage(
      'reward locks',
      () => p.rewardLocks.addAll(savedStrings(root['rewardLocks'])),
    );
    salvage('retired IDs', () {
      for (final id in savedStrings(root['retiredIds'])) {
        salvage('retired ID', () {
          attemptNumber(id);
          p.retiredIds.add(id);
        });
      }
    });
    salvage('unavailable Daily dates', () {
      for (final date in savedStrings(root['unavailableDaily'])) {
        salvage('unavailable date', () {
          parseDay(date);
          p.unavailableDaily.add(date);
        });
      }
    });
    salvage('campaign section', () {
      for (final e in savedMap(root['campaign']).entries) {
        salvage('achievement ${e.key}', () {
          final value = savedMap(e.value);
          p.campaign[savedString(e.key)] = Achievement(
            savedInt(value['bestStars'], 1, 3),
            practicePaid: savedBool(value['practicePaid']),
          );
        });
      }
    });
    final ids = <String>{...p.retiredIds};
    final first = <String>{};
    final practice = <String>{};
    final dates = <String>{};
    // Preserve trustworthy section values; never infer a new reward from load.
    try {
      for (final raw in savedList(root['results'])) {
        try {
          final r = FinalizedResult.restore(raw);
          requireSaved(!ids.contains(r.id), 'Duplicate finalized ID');
          if (r.date != null) requireSaved(!dates.contains(r.date));
          if (r.rewardKind == 'first') requireSaved(!first.contains(r.levelId));
          if (r.rewardKind == 'practice') {
            requireSaved(!practice.contains(r.levelId));
          }
          ids.add(r.id);
          if (r.date != null) dates.add(r.date!);
          if (r.rewardKind == 'first') first.add(r.levelId);
          if (r.rewardKind == 'practice') practice.add(r.levelId);
          p.results.add(r);
        } on FormatException {
          p.recovery.add(
            'Invalid result quarantined; its rewards remain unavailable.',
          );
          if (raw is Map<String, dynamic>) {
            salvage('result ID', () {
              final id = savedString(raw['id']);
              attemptNumber(id);
              if (!ids.contains(id)) p.retiredIds.add(id);
              ids.add(id);
            });
            if (raw['date'] is String) {
              salvage('result date', () {
                parseDay(raw['date']);
                p.unavailableDaily.add(raw['date']);
              });
            } else if (raw['levelId'] is String &&
                (raw['levelId'] as String).isNotEmpty) {
              p.rewardLocks.add(raw['levelId']);
            } else {
              p.rewardLocks.add('*');
            }
          } else {
            p.rewardLocks.add('*');
          }
        }
      }
    } on FormatException {
      p.recovery.add('Invalid history section; rewards locked until Reset.');
      p.rewardLocks.add('*');
    }
    salvage('Daily section', () {
      final dailyIds = <String>{};
      for (final e in savedMap(root['daily']).entries) {
        salvage('Daily outcome ${e.key}', () {
          parseDay(e.key);
          final d = savedMap(e.value);
          final id = savedString(d['id']);
          attemptNumber(id);
          final linked = p.results.where((r) => r.id == id).firstOrNull;
          requireSaved(linked == null || linked.date == e.key);
          requireSaved(dailyIds.add(id));
          p.daily[e.key] = DailyOutcome(id, savedBool(d['won']));
        });
      }
    });
    for (final r in p.results) {
      if (r.date != null) {
        final old = p.daily[r.date];
        if (old != null && (old.id != r.id || old.won != r.won)) {
          p.recovery.add('Daily outcome repaired from finalized history.');
        }
        p.daily[r.date!] = DailyOutcome(r.id, r.won);
      } else if (r.won) {
        final a = p.campaign.putIfAbsent(r.levelId, () => Achievement(r.stars));
        if (r.stars > a.bestStars) a.bestStars = r.stars;
        if (r.rewardKind == 'practice' || r.rewardKind == 'repeat') {
          a.practicePaid = true;
        }
      }
    }
    ids.addAll(p.daily.values.map((d) => d.id));
    salvage(
      'best streak',
      () => p.bestDailyStreak = savedInt(root['bestDailyStreak'], 0, 3652059),
    );
    for (final date in p.daily.keys) {
      final streak = p.currentStreak(parseDay(date));
      if (streak > p.bestDailyStreak) p.bestDailyStreak = streak;
    }
    salvage('settings', () {
      final settings = savedMap(root['settings']);
      salvage('theme', () {
        requireSaved(['system', 'light', 'dark'].contains(settings['theme']));
        p.theme = settings['theme'];
      });
      salvage('haptics', () => p.haptics = savedBool(settings['haptics']));
    });
    final levels = {
      for (final pack in catalog.packs)
        for (final l in pack.levels) l.id: l,
    };
    final campaignLevels = <String>{
      for (final pack in catalog.packs.take(catalog.manifest.campaign.length))
        for (final (index, level) in pack.levels.indexed)
          if (index == 0 || p.campaign.containsKey(pack.levels[index - 1].id))
            level.id,
    };
    final dailyLevels = catalog.manifest.daily == null
        ? <Level>[]
        : catalog.packs.last.levels;
    salvage('attempts section', () {
      for (final raw in savedList(root['attempts'])) {
        salvage('campaign attempt', () {
          final a = Attempt.restore(raw, levels);
          requireSaved(
            a.date == null &&
                !a.game.isFinal &&
                campaignLevels.contains(a.levelId),
          );
          requireSaved(
            !ids.contains(a.id) && !p.attempts.containsKey(a.levelId),
          );
          ids.add(a.id);
          p.attempts[a.levelId] = a;
        });
      }
    });
    if (root['dailyAttempt'] != null) {
      salvage('Daily attempt', () {
        final a = Attempt.restore(root['dailyAttempt'], levels);
        requireSaved(a.date != null);
        // Expired unfinished Daily is deliberately abandoned, never finalized.
        if (a.date != dayKey(today)) return;
        requireSaved(
          dailyLevels.isNotEmpty &&
              a.levelId ==
                  dailyLevels[dailyPoolIndex(today, dailyLevels.length)].id,
        );
        requireSaved(a.game.seed == dailySeed(today));
        requireSaved(
          !ids.contains(a.id) &&
              !a.game.isFinal &&
              !p.daily.containsKey(a.date) &&
              !p.unavailableDaily.contains(a.date),
        );
        ids.add(a.id);
        p.dailyAttempt = a;
      });
    }
    for (final id in {...ids, ...p.daily.values.map((d) => d.id)}) {
      final n = attemptNumber(id);
      if (n > p.sequence) p.sequence = n;
    }
    for (final a in [
      ...p.attempts.values,
      if (p.dailyAttempt != null) p.dailyAttempt!,
    ]) {
      if (a.entered > p.sequence) p.sequence = a.entered;
    }
    if (p.rewardLocks.isNotEmpty || p.unavailableDaily.isNotEmpty) {
      p.recovery.add(
        'Affected recovered rewards or Daily results remain unavailable until Reset.',
      );
    }
    return p;
  }

  int currentStreak(DateTime today) {
    var day = civilDay(today);
    final outcome = daily[dayKey(day)];
    if (outcome == null && unavailableDaily.contains(dayKey(day))) return 0;
    if (outcome != null && !outcome.won) return 0;
    if (outcome == null) day = day.subtract(const Duration(days: 1));
    var count = 0;
    while (daily[dayKey(day)]?.won == true) {
      count++;
      day = day.subtract(const Duration(days: 1));
    }
    return count;
  }

  int get gamesPlayed => results.length;
  int get wins => results.where((r) => r.won).length;
  int get perfectWins => results.where((r) => r.won && r.mistakes == 0).length;
  double get winRate => gamesPlayed == 0 ? 0 : wins / gamesPlayed;
  List<int> get winMistakeBuckets => List.generate(
    5,
    (i) => results
        .where((r) => r.won && (i == 4 ? r.mistakes >= 4 : r.mistakes == i))
        .length,
  );
}
