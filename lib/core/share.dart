import 'game.dart';

sealed class ShareHeader {
  const ShareHeader();
  String get text;
}

final class CampaignHeader extends ShareHeader {
  const CampaignHeader(this.packTitle, this.levelNumber);
  final String packTitle;
  final int levelNumber;
  @override
  String get text => 'LexiStack · $packTitle #$levelNumber';
}

final class DailyHeader extends ShareHeader {
  const DailyHeader(this.date);

  /// Civil date supplied by the caller; no clock or Daily gameplay here.
  final DateTime date;
  @override
  String get text =>
      'LexiStack · Daily '
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Null rejects sharing an unfinished attempt, including pending loss.
String? formatShare(Game game, ShareHeader header) {
  if (!game.isFinal) return null;
  const emoji = ['🟨', '🟩', '🟦', '🟪'];
  final result = game.status == GameStatus.won
      ? '${'★' * game.stars}${'☆' * (3 - game.stars)}'
      : '${game.solvedIds.length}/4 groups';
  return [
    header.text,
    '$result · ${game.mistakes} mistakes',
    for (final guess in game.guesses)
      guess.tiers.map((tier) => emoji[tier - 1]).join(),
  ].join('\n');
}
