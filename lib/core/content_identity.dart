import 'dart:convert';

import 'package:lexistack_content_contract/lexistack_content_contract.dart';

/// Collision-free semantic fingerprint: canonical JSON of ordered model fields.
/// It ignores JSON whitespace/object-key order, includes all playable/revealed
/// content and source tile order, and uses no runtime hash or platform arithmetic.
String contentFingerprint(Level level) => jsonEncode([
  level.id,
  level.packId,
  level.title,
  for (final c in level.categories)
    [
      c.id,
      c.title,
      c.difficultyTier,
      c.triviaFact,
      for (final t in c.tiles) [t.id, t.text, t.difficultyTier],
    ],
  [
    for (final h in level.redHerrings) [h.tiles, h.note],
  ],
]);
