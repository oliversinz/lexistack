// Direct Dart VM probe: fixed expectations independently produced by the
// BigInteger PowerShell oracle in docs/evidence/f2/prng-oracle.ps1.
// ignore_for_file: avoid_print

import 'package:lexistack/core/prng.dart';

void main() {
  const vectors = {
    1: [
      16807,
      282475249,
      1622650073,
      984943658,
      1144108930,
      470211272,
      101027544,
      1457850878,
    ],
    42: [
      705894,
      1126542223,
      1579310009,
      565444343,
      807934826,
      421520601,
      2095673201,
      1100194760,
    ],
    20261028: [
      1224681370,
      1736512742,
      1266892064,
      354559643,
      1964283123,
      440342930,
      614976948,
      78772025,
    ],
    2147483646: [
      2147466840,
      1865008398,
      524833574,
      1162539989,
      1003374717,
      1677272375,
      2046456103,
      689632769,
    ],
  };
  for (final entry in vectors.entries) {
    final random = StableRandom(entry.key);
    final actual = [for (final _ in entry.value) random.next()];
    if (actual.join(',') != entry.value.join(',')) {
      throw StateError('Seed ${entry.key}: $actual != ${entry.value}');
    }
    print('Seed ${entry.key}: $actual OK');
  }
  final order = List.generate(16, (i) => i);
  final random = StableRandom(20261028)..shuffle(order);
  const expected = [11, 15, 6, 0, 12, 13, 1, 7, 14, 8, 5, 3, 9, 4, 2, 10];
  if (order.join(',') != expected.join(',') || random.state != 1470087647) {
    throw StateError('Shuffle mismatch: $order, ${random.state}');
  }
  print('F2 default seed board indexes: $order; state ${random.state} OK');
}
