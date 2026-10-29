import 'dart:convert';
import 'dart:io';

import 'content_fixture.dart';

/// Mechanical test data only: never installed as editorial puzzles.
Map<String, dynamic> candidateFixture({required bool conflicting}) {
  final raw =
      jsonDecode(installedFiles()['pack2.json']!) as Map<String, dynamic>;
  raw['pack']['id'] = 'candidate';
  raw['pack']['title'] = 'Synthetic candidate';
  const colors = [
    'APRICOT',
    'BURGUNDY',
    'COPPER',
    'CREAM',
    'MAGENTA',
    'TEAL',
    'VIOLET',
    'TAUPE',
  ];
  const objects = [
    'BASKET',
    'BUCKET',
    'CABINET',
    'CUSHION',
    'DOOR',
    'DRAWER',
    'FOLDER',
    'HAMMER',
    'HANDLE',
    'LADDER',
    'LANTERN',
    'NAPKIN',
    'PENCIL',
    'RIBBON',
    'SHOVEL',
    'TOWEL',
  ];
  for (var i = 0; i < 8; i++) {
    final level = raw['levels'][i];
    level['id'] = 'candidate_lvl${i + 1}';
    level['packId'] = 'candidate';
    if (conflicting) continue;
    for (var j = 0; j < 4; j++) {
      final category = level['categories'][j];
      category['id'] = 'candidate_g${i}_$j';
      category['title'] = 'Synthetic fixture group $i $j';
      category['tiles'] = [
        for (var k = 0; k < 4; k++) '${colors[i]} ${objects[j * 4 + k]}',
      ];
      category['triviaFact'] = 'A synthetic fixture exercises catalog validation without adding production content.';
    }
    level['redHerrings'] = [
      {
        'tiles': [level['categories'][0]['tiles'][0]],
        'note': 'A test-only reference checks that the named tile belongs to this board.',
      },
    ];
  }
  return raw;
}

/// Export temporary inputs for literal CLI verification, outside production.
void main(List<String> args) {
  final directory = Directory(args.single)..createSync(recursive: true);
  for (final conflicting in [false, true]) {
    File(
      '${directory.path}/${conflicting ? 'invalid' : 'valid'}-addition.json',
    ).writeAsStringSync(jsonEncode(candidateFixture(conflicting: conflicting)));
  }
  stdout.writeln('Synthetic CLI fixtures: ${directory.absolute.path}');
}
