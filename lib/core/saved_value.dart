// Strict, small readers shared by game snapshots and the progress codec.
// Bad save bytes must produce FormatException, never unchecked casts.
void requireSaved(bool condition, [String message = 'Invalid saved value']) {
  if (!condition) throw FormatException(message);
}

Map<String, dynamic> savedMap(Object? value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Expected object');
  }
  return value;
}

List<dynamic> savedList(Object? value) {
  if (value is! List) throw const FormatException('Expected list');
  return value;
}

String savedString(Object? value) {
  if (value is! String || value.isEmpty) {
    throw const FormatException('Expected string');
  }
  return value;
}

int savedInt(Object? value, int min, int max) {
  if (value is! int || value < min || value > max) {
    throw const FormatException('Integer out of range');
  }
  return value;
}

bool savedBool(Object? value) {
  if (value is! bool) throw const FormatException('Expected boolean');
  return value;
}

List<String> savedStrings(Object? value, {bool unique = true}) {
  final values = savedList(value).map(savedString).toList();
  requireSaved(
    !unique || values.toSet().length == values.length,
    'Duplicate IDs',
  );
  return values;
}
