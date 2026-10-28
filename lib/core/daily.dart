import 'prng.dart';
import 'saved_value.dart';

typedef LocalClock = DateTime Function();

/// Civil components, represented at UTC midnight. Never elapsed local hours.
DateTime civilDay(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);
String dayKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

DateTime parseDay(String key) {
  requireSaved(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key));
  final date = DateTime.tryParse('${key}T00:00:00Z');
  requireSaved(date != null && date.year >= 1 && dayKey(date) == key);
  return date!;
}

int dailyIndex(DateTime date) =>
    civilDay(date).difference(DateTime.utc(2026)).inDays;
int dailyPoolIndex(DateTime date, int length) => dailyIndex(date) % length;

/// Normalized modulo + 1: epoch -> 1, 2026-01-09 -> 9,
/// 2026-10-28 -> 301. Always in Park–Miller's 1..2147483646 range.
int dailySeed(DateTime date) =>
    dailyIndex(date) % (StableRandom.modulus - 1) + 1;
