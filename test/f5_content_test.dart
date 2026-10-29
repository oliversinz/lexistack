import 'dart:convert';

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

  test('CNT-05/11 every production identity, order and intended solve', () {
    final report = check({});
    expect(report.errors, isEmpty);
    expect(report.warnings, isEmpty);
    expect(report.meetsStrictMinimum, isTrue);
    expect(report.isInitialBenchmark, isTrue);
    expect(report.catalog!.manifest.campaign, [
      'pack1.json',
      'pack2.json',
      'pack3.json',
      'pack4.json',
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
    expect(levelIds, hasLength(40));
    expect(tileIds, hasLength(640));
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
      expect(report.totalLevels, kind == 'replacement' ? 40 : 48);
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
