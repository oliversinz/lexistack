/// Park–Miller (16807, modulus 2^31 - 1). State is in 1..2147483646.
/// The largest multiplication is < 2^46, so every operation is exact on
/// both Dart VM integers and JavaScript numbers. No overflow/bitwise tricks.
/// Shuffle is descending Fisher–Yates, choosing next() % (i + 1).
final class StableRandom {
  StableRandom(int seed) : _state = seed {
    if (seed < 1 || seed >= modulus) {
      throw RangeError.range(seed, 1, modulus - 1, 'seed');
    }
  }

  static const modulus = 2147483647;
  int _state;
  int get state => _state;

  int next() => _state = (_state * 16807) % modulus;

  void shuffle<T>(List<T> items) {
    for (var i = items.length - 1; i > 0; i--) {
      final j = next() % (i + 1);
      final item = items[i];
      items[i] = items[j];
      items[j] = item;
    }
  }
}
