import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/infrastructure/asset_catalog.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import 'support/content_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifest = installedManifest();
  final files = installedFiles();
  final contents = File('assets/levels/pack1.json').readAsStringSync();
  final daily = File('assets/levels/daily.json').readAsStringSync();
  Map<String, dynamic> fixture() =>
      jsonDecode(contents) as Map<String, dynamic>;
  ValidationReport check({
    String? pack,
    ValidationMode mode = ValidationMode.strict,
  }) => validateCatalog(
    manifestContents: manifest,
    files: {...files, 'pack1.json': pack ?? contents},
    mode: mode,
  );

  test(
    'production pack is schema v2 with eight complete levels and stable IDs',
    () {
      final report = check();
      expect(report.diagnostics, isEmpty);
      expect(report.mode, ValidationMode.strict);
      expect(report.isInitialBenchmark, isFalse);
      expect(report.catalog!.packs, hasLength(7));
      expect(report.totalLevels, 64);
      expect(report.totalCategories, 256);
      expect(report.totalTiles, 1024);
      expect(report.meetsStrictMinimum, isTrue);
      final pack = report.catalog!.packs.first;
      expect(pack.schemaVersion, 2);
      expect(pack.id, 'pack1');
      expect(pack.title, 'Everyday Echoes');
      expect(pack.levels.first.title, 'Table Talk');
      for (final level in pack.levels) {
        expect(level.packId, pack.id);
        expect(level.categories.map((c) => c.difficultyTier).toSet(), {
          1,
          2,
          3,
          4,
        });
        expect(level.tiles.map((t) => t.text).toSet(), hasLength(16));
        for (final category in level.categories) {
          expect(category.tiles, hasLength(4));
          expect(category.triviaFact.runes.length, inInclusiveRange(40, 160));
          for (final tile in category.tiles) {
            expect(tile.id, jsonEncode([level.id, category.id, tile.ordinal]));
          }
        }
      }
      expect(
        pack.levels.expand((l) => l.tiles).map((t) => t.id).toSet(),
        hasLength(128),
      );
    },
  );

  test(
    'production assets load through the real Flutter asset bundle',
    () async {
      final report = await loadAssetCatalog(rootBundle);
      expect(report.diagnostics, isEmpty);
      expect(report.mode, ValidationMode.strict);
      expect(report.isInitialBenchmark, isFalse);
      expect(report.catalog!.packs, hasLength(7));
      expect(
        report.catalog!.packs.first.levels.last.title,
        'Hidden in Plain Sight',
      );
    },
  );

  test('manifest preserves source order and can omit Daily', () {
    expect(parseManifest('{"campaign":["b.json","a.json"]}').value!.files, [
      'b.json',
      'a.json',
    ]);
    expect(parseManifest(manifest).value!.daily, 'daily.json');
  });

  test(
    'partial succeeds; strict rejects campaign count but Daily is installed',
    () {
      expect(check().exitCode, 0);
      final strict = validateCatalog(
        manifestContents: '{"campaign":["pack1.json"],"daily":"daily.json"}',
        files: {'pack1.json': contents, 'daily.json': daily},
      );
      final partial = validateCatalog(
        manifestContents: '{"campaign":["pack1.json"],"daily":"daily.json"}',
        files: {'pack1.json': contents, 'daily.json': daily},
        mode: ValidationMode.partial,
      );
      expect(partial.diagnostics, isEmpty);
      expect(partial.totalLevels, 16);
      expect(formatReport(partial), contains('PARTIAL'));
      expect(strict.exitCode, 1);
      expect(
        strict.errors.map((d) => d.code),
        contains('catalog.campaignCount'),
      );
      expect(
        strict.errors.map((d) => d.code),
        isNot(contains('catalog.dailyMissing')),
      );
      final legacy = validateCatalog(
        manifestContents: '{"campaign":["pack1.json"]}',
        files: {'pack1.json': contents},
        mode: ValidationMode.strict,
      );
      expect(
        legacy.errors.map((d) => d.code),
        containsAll(['catalog.campaignCount', 'catalog.dailyMissing']),
      );
    },
  );

  test('partial cannot ignore a missing listed asset or an empty catalog', () {
    final missing = validateCatalog(
      manifestContents: manifest,
      files: {},
      mode: ValidationMode.partial,
    );
    expect(missing.isValid, isFalse);
    expect(formatReport(missing), contains('pack1.json'));
    expect(
      validateCatalog(
        manifestContents: '{"campaign":[]}',
        files: {},
        mode: ValidationMode.partial,
      ).isValid,
      isFalse,
    );
  });

  test('malformed JSON returns file, line and column', () {
    final parsed = parsePack('{\n"schemaVersion": }', source: 'broken.json');
    expect(parsed.isValid, isFalse);
    final error = parsed.diagnostics.firstWhere((d) => d.code == 'json.syntax');
    expect(error.code, 'json.syntax');
    expect(error.source, 'broken.json');
    expect(error.line, 2);
    expect(error.column, greaterThan(1));
  });

  final mutations = <String, (String, void Function(Map<String, dynamic>))>{
    'wrong schema': ('schema.version', (p) => p['schemaVersion'] = 1),
    'wrong pack ID': (
      'level.packId',
      (p) => p['levels'][0]['packId'] = 'other',
    ),
    'missing level ID': ('id.invalid', (p) => p['levels'][0].remove('id')),
    'duplicate category ID': (
      'id.duplicateCategory',
      (p) => p['levels'][0]['categories'][1]['id'] = 'g1',
    ),
    'three groups': (
      'level.categoryCount',
      (p) => p['levels'][0]['categories'].removeLast(),
    ),
    'three tiles': (
      'category.tileCount',
      (p) => p['levels'][0]['categories'][0]['tiles'].removeLast(),
    ),
    'repeated tier': (
      'level.tiers',
      (p) => p['levels'][0]['categories'][1]['difficultyTier'] = 1,
    ),
    'duplicate board word': (
      'tile.duplicate',
      (p) => p['levels'][0]['categories'][1]['tiles'][0] = 'TOAST',
    ),
    'bad tile type': (
      'schema.type',
      (p) => p['levels'][0]['categories'][0]['tiles'][1] = 42,
    ),
    'short trivia': (
      'trivia.length',
      (p) => p['levels'][0]['categories'][0]['triviaFact'] = 'Too short.',
    ),
    'missing red herring': (
      'redHerring.count',
      (p) => p['levels'][0]['redHerrings'] = [],
    ),
    'off-board red herring': (
      'redHerring.reference',
      (p) => p['levels'][0]['redHerrings'][0]['tiles'] = ['ABSENT'],
    ),
  };
  for (final entry in mutations.entries) {
    test('rejects ${entry.key} with an actionable location', () {
      final raw = fixture();
      entry.value.$2(raw);
      final report = check(pack: jsonEncode(raw));
      expect(report.isValid, isFalse);
      final diagnostic = report.errors.firstWhere(
        (d) => d.code == entry.value.$1,
      );
      expect(diagnostic.source, 'pack1.json');
      expect(diagnostic.path, startsWith(r'$.'));
      expect(diagnostic.message, isNotEmpty);
      if (entry.key == 'bad tile type') {
        expect(diagnostic.path, r'$.levels[0].categories[0].tiles[1]');
        expect(diagnostic.levelId, 'pack1_lvl01');
        expect(diagnostic.categoryId, 'g1');
      }
    });
  }

  test('candidate replacement excludes its old copy; addition checks cross-file duplicates', () {
    final replacement = validateCatalog(
      manifestContents: manifest,
      files: files,
      mode: ValidationMode.candidate,
      candidateContents: contents,
    );
    expect(replacement.isValid, isTrue);
    expect(
      replacement.candidate!.interpretation,
      CandidateInterpretation.replacement,
    );
    final candidate = fixture();
    candidate['pack']['id'] = 'candidate';
    for (final level in candidate['levels']) {
      level['id'] = 'candidate_${level['id']}';
      level['packId'] = 'candidate';
    }
    final addition = validateCatalog(
      manifestContents: manifest,
      files: files,
      mode: ValidationMode.candidate,
      candidateContents: jsonEncode(candidate),
    );
    expect(
      addition.candidate!.interpretation,
      CandidateInterpretation.addition,
    );
    expect(addition.isValid, isFalse);
    expect(
      addition.errors.map((d) => d.code),
      contains('catalog.categoryTitle'),
    );
    expect(File('assets/levels/pack1.json').readAsStringSync(), contents);
    expect(File('assets/levels/manifest.json').readAsStringSync(), manifest);
  });
}
