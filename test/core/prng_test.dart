import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_prng.dart' as probe;

void main() {
  test(
    'ENG-11 independent fixed PRNG vectors and default board order',
    probe.main,
  );
}
