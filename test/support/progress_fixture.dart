import 'dart:io';

import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/progress_controller.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/core/game.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

Catalog installedCatalog() => validateCatalog(
  manifestContents: File('assets/levels/manifest.json').readAsStringSync(),
  files: {
    for (final name in ['pack1.json', 'daily.json'])
      name: File('assets/levels/$name').readAsStringSync(),
  },
  mode: ValidationMode.partial,
).catalog!;

class TestClock {
  TestClock([DateTime? date]) : value = date ?? DateTime(2026, 10, 28);
  DateTime value;
  DateTime call() => value;
  void day(int days) =>
      value = DateTime(value.year, value.month, value.day + days);
}

Future<ProgressController> player({
  MemoryProgressStorage? store,
  TestClock? clock,
  Catalog? catalog,
}) async {
  final p = ProgressController(
    catalog: catalog ?? installedCatalog(),
    storage: store ?? MemoryProgressStorage(),
    clock: (clock ?? TestClock()).call,
  );
  await p.load();
  return p;
}

BoardController firstBoard(ProgressController p, {bool replay = false}) =>
    BoardController(
      p,
      p.enterCampaign(p.campaignPacks.first.levels.first, replay: replay)!,
    );

GameOutcome submitIds(BoardController b, Iterable<String> ids) {
  b.deselect();
  for (final id in ids) {
    b.toggle(id);
  }
  return b.submit();
}

const wrongIndexes = [
  [0, 1, 2, 4],
  [0, 1, 4, 5],
  [0, 4, 8, 12],
  [1, 5, 9, 13],
  [2, 6, 10, 14],
  [3, 7, 11, 15],
];
void mistake(BoardController b, int row) =>
    submitIds(b, wrongIndexes[row].map((i) => b.game.level.tiles[i].id));
void pending(BoardController b) {
  for (var i = 0; i < 4; i++) {
    mistake(b, i);
  }
}

void win(BoardController b) {
  for (final category in b.game.remainingCategories) {
    submitIds(b, category.tiles.map((t) => t.id));
  }
}

Catalog twoPacks() {
  final source = installedCatalog().packs.first;
  Level copy(Level l, String packId, String id) => Level(
    id: id,
    packId: packId,
    title: l.title,
    categories: [
      for (final c in l.categories)
        Category(
          id: c.id,
          title: c.title,
          difficultyTier: c.difficultyTier,
          triviaFact: c.triviaFact,
          tiles: [
            for (final t in c.tiles)
              Tile(
                levelId: id,
                categoryId: c.id,
                ordinal: t.ordinal,
                difficultyTier: t.difficultyTier,
                text: t.text,
              ),
          ],
        ),
    ],
    redHerrings: l.redHerrings,
  );
  return Catalog(
    manifest: Manifest(campaign: ['a.json', 'b.json']),
    packs: [
      for (final id in ['a', 'b'])
        Pack(
          source: '$id.json',
          schemaVersion: 2,
          id: id,
          title: 'Synthetic $id',
          description: 'Independent pack fixture',
          levels: [
            for (var i = 0; i < 2; i++) copy(source.levels[i], id, '${id}_$i'),
          ],
        ),
    ],
  );
}
