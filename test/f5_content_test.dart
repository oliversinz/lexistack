import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/core/game.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import 'support/candidate_fixture.dart';
import 'support/content_fixture.dart';

void main() {
  final manifest = installedManifest();
  final files = installedFiles();
  ValidationReport check(Map<String, String> changed) => validateCatalog(
    manifestContents: manifest,
    files: {...files, ...changed},
  );

  test('historical Experiment E snapshot retains its exact identities and totals', () {
    const blobs = {
      'test/fixtures/initial-manifest.json': '6d7cc02ec1f644e1cbb7c98a8bab7f9594c6020d',
      'assets/levels/pack1.json': '5efa3c88c769f74eee872860766681f5c2cc1c64',
      'assets/levels/pack2.json': '32ca5e922e3da3e2b22a42716de87a63e53492f8',
      'assets/levels/pack3.json': 'fc88352362ea575e7c0f38670b0c7e81c24ec070',
      'assets/levels/pack4.json': '54c09ae4c2f0a5d07b95addc42e80eacac33d2c6',
      'assets/levels/daily.json': '5ab06b73921c4a9992e6c9fe8c099ba4c2e4a2e6',
    };
    for (final entry in blobs.entries) {
      final result = Process.runSync('git', ['hash-object', '--no-filters', entry.key]);
      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), entry.value, reason: entry.key);
    }
    final historical = validateCatalog(manifestContents: initialManifest(), files: files);
    expect(historical.diagnostics, isEmpty);
    expect(historical.isInitialBenchmark, isTrue);
    expect(historical.meetsStrictMinimum, isTrue);
    expect(historical.catalog!.manifest.campaign, hasLength(4));
    expect(historical.catalog!.packs, hasLength(5));
    expect(historical.totalLevels, 40);
    expect(historical.totalCategories, 160);
    expect(historical.totalTiles, 640);
  });

  test('approved cs1-pack5-v1 manifest and Pack 5 bytes are immutable', () {
    // Git blob identities from release ba005009089ca54a1d4c203f218e37cfaae62f6e.
    // Pack 5 SHA-256: 46e38caf79689b253b353fd52dd73b95fb84e9e721cff596dba56927f6ad708f.
    for (final entry in {
      'manifest.json': 'e48a157f7da4f00351cef702a8672314084e0ddf',
      'pack5.json': 'ec83e117ed694008b964ae7630b783bcb5ab09fd',
    }.entries) {
      final result = Process.runSync('git', ['hash-object', '--no-filters', 'assets/levels/${entry.key}']);
      expect(result.exitCode, 0);
      expect(result.stdout.toString().trim(), entry.value);
    }
    final report = check({});
    final catalog = report.catalog!;
    expect(catalog.packs.map((p) => p.id), ['pack1', 'pack2', 'pack3', 'pack4', 'pack5', 'daily']);
    expect(catalog.packs.take(5).expand((p) => p.levels), hasLength(40));
    expect(catalog.packs.last.levels, hasLength(8));
    expect(catalog.packs[4].title, 'Unexpected Connections');
    expect(catalog.packs[4].levels[3].categories.map((c) => c.difficultyTier), [1, 4, 3, 2]);
  });

  test('CNT-05/11 every production identity, order and intended solve', () {
    final report = check({});
    expect(report.errors, isEmpty);
    expect(report.warnings, isEmpty);
    expect(report.meetsStrictMinimum, isTrue);
    expect(report.isInitialBenchmark, isFalse);
    expect(report.catalog!.manifest.campaign, [
      'pack1.json',
      'pack2.json',
      'pack3.json',
      'pack4.json',
      'pack5.json',
    ]);
    expect(report.catalog!.manifest.daily, 'daily.json');
    final levelIds = <String>{}, tileIds = <String>{};
    for (final pack in report.catalog!.packs) {
      expect(pack.levels.map((l) => l.id), [
        for (var i = 1; i <= 8; i++)
          '${pack.id}_lvl${i.toString().padLeft(2, '0')}',
      ]);
      for (final level in pack.levels) {
        expect(levelIds.add(level.id), isTrue);
        final game = Game(level, seed: 20261029);
        final twin = Game(level, seed: 1);
        expect(game.order.toSet(), hasLength(16));
        expect(level.categories.map((c) => c.difficultyTier).toSet(), {
          1,
          2,
          3,
          4,
        });
        expect(level.categories, hasLength(4));
        for (final category in level.categories) {
          for (final tile in category.tiles.reversed) {
            expect(tileIds.add(tile.id), isTrue);
            expect(tile.id, jsonEncode([level.id, category.id, tile.ordinal]));
            expect(game.tile(tile.id), same(tile));
            expect(twin.tile(tile.id).categoryId, category.id);
            expect(game.toggle(tile.id), isA<Applied>());
          }
          final result = game.submit();
          expect(result, isA<Solved>());
          expect((result as Solved).category.id, category.id);
          expect(game.solvedIds, contains(category.id));
        }
        expect(game.status, GameStatus.won, reason: level.id);
        expect(game.lives, 4);
        expect(game.mistakes, 0);
        expect(game.stars, 3);
        expect(game.guesses, hasLength(4));
        expect(game.order, isEmpty);
      }
    }
    expect(levelIds, hasLength(48));
    expect(tileIds, hasLength(768));
  });

  final mutations = <String, (String, void Function(dynamic))>{
    'missing metadata': ('schema.type', (p) => p.remove('pack')),
    'missing categories': (
      'schema.type',
      (p) => p['levels'][0].remove('categories'),
    ),
    'missing tier': (
      'schema.type',
      (p) => p['levels'][0]['categories'][0].remove('difficultyTier'),
    ),
    'lowercase tile': (
      'tile.form',
      (p) => p['levels'][0]['categories'][0]['tiles'][0] = 'toast',
    ),
    'trailing space': (
      'tile.form',
      (p) => p['levels'][0]['categories'][0]['tiles'][0] = 'TOAST ',
    ),
    'double spacing': (
      'tile.form',
      (p) => p['levels'][0]['categories'][0]['tiles'][0] = 'RED  TOAST',
    ),
    'overlong word': (
      'tile.form',
      (p) => p['levels'][0]['categories'][0]['tiles'][0] = 'ABCDEFGHIJK',
    ),
    'three words': (
      'tile.form',
      (p) => p['levels'][0]['categories'][0]['tiles'][0] = 'ONE TWO SIX',
    ),
    'punctuation': (
      'tile.form',
      (p) => p['levels'][0]['categories'][0]['tiles'][0] = 'TOAST!',
    ),
    'long trivia': (
      'trivia.length',
      (p) => p['levels'][0]['categories'][0]['triviaFact'] = '${'A' * 160}.',
    ),
    'missing note': (
      'schema.type',
      (p) => p['levels'][0]['redHerrings'][0].remove('note'),
    ),
    'punctuation note': (
      'redHerring.note',
      (p) => p['levels'][0]['redHerrings'][0]['note'] = '...',
    ),
    'malformed references': (
      'schema.type',
      (p) => p['levels'][0]['redHerrings'][0]['tiles'] = 42,
    ),
    'empty references': (
      'redHerring.references',
      (p) => p['levels'][0]['redHerrings'][0]['tiles'] = [],
    ),
    'normalized title': (
      'catalog.categoryTitle',
      (p) => p['levels'][1]['categories'][0]['title'] = '  breakfast   bakes  ',
    ),
    'tile in three levels': (
      'catalog.tileRepetition',
      (p) {
        for (final i in [1, 2]) {
          p['levels'][i]['categories'][0]['tiles'][0] = 'TOAST';
        }
      },
    ),
    'three-tile overlap': (
      'catalog.groupOverlap',
      (p) => p['levels'][1]['categories'][0]['tiles'] = [
        'TOAST',
        'WAFFLE',
        'MUFFIN',
        'BENCH',
      ],
    ),
    'duplicate board': (
      'catalog.duplicateBoard',
      (p) {
        for (var i = 0; i < 4; i++) {
          p['levels'][1]['categories'][i]['tiles'] =
              p['levels'][0]['categories'][i]['tiles'];
        }
        p['levels'][1]['redHerrings'] = p['levels'][0]['redHerrings'];
      },
    ),
  };
  for (final entry in mutations.entries) {
    test('CNT-06/07/08/09 rejects ${entry.key} with diagnostics', () {
      final raw = jsonDecode(files['pack1.json']!);
      entry.value.$2(raw);
      final report = check({'pack1.json': jsonEncode(raw)});
      expect(report.exitCode, 1);
      final d = report.errors.firstWhere((d) => d.code == entry.value.$1);
      expect(d.source, 'pack1.json');
      expect(d.path, startsWith(r'$'));
      expect(d.message, isNotEmpty);
    });
  }

  for (final duplicatePack in [true, false]) {
    test(
      'CNT-06 cross-file duplicate ${duplicatePack ? 'pack' : 'level'} ID',
      () {
        final raw = jsonDecode(files['pack2.json']!);
        if (duplicatePack) {
          raw['pack']['id'] = 'pack1';
          for (final l in raw['levels']) {
            l['packId'] = 'pack1';
          }
        } else {
          raw['levels'][0]['id'] = 'pack1_lvl01';
        }
        final report = check({'pack2.json': jsonEncode(raw)});
        final d = report.errors.firstWhere(
          (d) => d.code == 'id.duplicate${duplicatePack ? 'Pack' : 'Level'}',
        );
        expect(d.source, 'pack2.json');
        expect(d.message, contains('pack1.json'));
      },
    );
  }

  test('CNT-09 40/160 boundaries and warnings are separate from exit code', () {
    for (final length in [40, 160]) {
      final raw = jsonDecode(files['pack1.json']!);
      raw['levels'][0]['categories'][0]['triviaFact'] =
          '${'A' * (length - 1)}.';
      expect(check({'pack1.json': jsonEncode(raw)}).diagnostics, isEmpty);
    }
    final raw = jsonDecode(files['pack1.json']!);
    raw['levels'][0]['categories'][0]['triviaFact'] =
        'A FORK appears in this deliberately unrelated fixture sentence.';
    final report = check({'pack1.json': jsonEncode(raw)});
    expect(
      report.exitCode,
      0,
      reason: 'Advisory warnings do not change the shared CLI exit code',
    );
    expect(
      report.warnings.map((d) => d.code),
      contains('trivia.unrelatedTile'),
    );
    expect(report.isInitialBenchmark, isFalse);
    expect(formatReport(report), contains('WARNING'));
  });

  for (final name in ['pack2.json', 'pack4.json']) {
    test('CNT-03 missing manifest file $name fails strict', () {
      final report = validateCatalog(
        manifestContents: manifest,
        files: {...files}..remove(name),
      );
      expect(report.exitCode, 1);
      expect(
        report.errors.any((d) => d.code == 'file.missing' && d.source == name),
        isTrue,
      );
    });
  }

  test('CNT-10 replacement and both additions are pure previews', () {
    final before = jsonEncode(files);
    for (final kind in ['replacement', 'invalid', 'valid']) {
      final report = validateCatalog(
        manifestContents: manifest,
        files: files,
        mode: ValidationMode.candidate,
        candidateSource: '$kind.json',
        candidateContents: kind == 'replacement'
            ? files['pack2.json']
            : jsonEncode(candidateFixture(conflicting: kind == 'invalid')),
      );
      expect(
        report.candidate!.interpretation,
        kind == 'replacement'
            ? CandidateInterpretation.replacement
            : CandidateInterpretation.addition,
      );
      expect(report.isValid, kind != 'invalid');
      expect(report.totalLevels, kind == 'replacement' ? 48 : 56);
      expect(formatReport(report), contains('preview only'));
      if (kind == 'replacement') {
        expect(report.candidate!.replacedSource, 'pack2.json');
      } else if (kind == 'invalid') {
        expect(
          report.errors.map((d) => d.code),
          containsAll([
            'catalog.categoryTitle',
            'catalog.groupOverlap',
            'catalog.duplicateBoard',
          ]),
        );
      } else {
        expect(report.warnings, isEmpty);
      }
      expect(
        report.catalog?.manifest ?? parseManifest(manifest).value,
        isNotNull,
      );
      expect(jsonEncode(files), before);
      expect(installedFiles(), files);
      expect(installedManifest(), manifest);
    }
  });
}
