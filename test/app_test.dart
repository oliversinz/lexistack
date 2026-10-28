import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/ui/app.dart';
import 'package:lexistack/app/storage.dart';

class TestBundle extends CachingAssetBundle {
  final files = {
    for (final name in ['manifest.json', 'pack1.json', 'daily.json'])
      'assets/levels/$name': File('assets/levels/$name').readAsStringSync(),
  };

  @override
  Future<ByteData> load(String key) async {
    final contents = files[key];
    if (contents == null) throw FlutterError('Missing test asset: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(contents)));
  }
}

void main() {
  Future<void> reveal(
    WidgetTester tester,
    String label, [
    double delta = 200,
  ]) async {
    await tester.scrollUntilVisible(
      find.text(label),
      delta,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'actual app shows production metadata and navigates Home / pack / level / back',
    (tester) async {
      await tester.pumpWidget(
        LexiStackApp(
          bundle: TestBundle(),
          storage: MemoryProgressStorage(),
          clock: () => DateTime(2026, 10, 28),
        ),
      );
      await tester.pumpAndSettle();
      await reveal(tester, 'Explore collection');
      expect(find.text('Everyday Echoes'), findsOneWidget);
      expect(find.text('0 / 8 solved · Available offline'), findsOneWidget);
      expect(find.byTooltip('Settings'), findsOneWidget);
      await reveal(tester, 'Explore collection', -200);
      await tester.tap(find.text('Explore collection'));
      await tester.pumpAndSettle();
      expect(find.text('Table Talk'), findsOneWidget);
      await tester.tap(find.text('Table Talk'));
      await tester.pumpAndSettle();
      expect(find.text('Everyday Echoes · Level 1'), findsOneWidget);
      expect(find.text('16 words'), findsOneWidget);
      expect(find.text('4 hidden connections'), findsOneWidget);
      expect(find.text('BREAKFAST BAKES'), findsNothing);
      await reveal(tester, 'Back to collection');
      await tester.tap(find.text('Back to collection'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Explore collection'), findsOneWidget);
    },
  );

  testWidgets('malformed asset shows file diagnostics and retry recovers', (
    tester,
  ) async {
    final bundle = TestBundle();
    final original = bundle.files['assets/levels/pack1.json']!;
    bundle.files['assets/levels/pack1.json'] = '{broken';
    await tester.pumpWidget(
      LexiStackApp(
        bundle: bundle,
        storage: MemoryProgressStorage(),
        clock: () => DateTime(2026, 10, 28),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Collection could not load'), findsOneWidget);
    expect(find.textContaining('json.syntax'), findsOneWidget);
    expect(find.textContaining('pack1.json'), findsOneWidget);
    expect(find.text('Explore collection'), findsNothing);
    bundle.files['assets/levels/pack1.json'] = original;
    await reveal(tester, 'Retry');
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Everyday Echoes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing bundled file is named without crashing', (tester) async {
    final bundle = TestBundle()..files.remove('assets/levels/pack1.json');
    await tester.pumpWidget(
      LexiStackApp(
        bundle: bundle,
        storage: MemoryProgressStorage(),
        clock: () => DateTime(2026, 10, 28),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Cannot read bundled asset assets/levels/pack1.json'),
      findsOneWidget,
    );
    expect(find.text('Explore collection'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(360, 640),
    const Size(390, 844),
    const Size(1280, 800),
  ]) {
    testWidgets('navigation remains reachable at $size and enlarged text', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        LexiStackApp(
          bundle: TestBundle(),
          storage: MemoryProgressStorage(),
          clock: () => DateTime(2026, 10, 28),
        ),
      );
      await tester.pumpAndSettle();
      await reveal(tester, 'Explore collection');
      await tester.tap(find.text('Explore collection'));
      await tester.pumpAndSettle();
      await reveal(tester, 'Hidden in Plain Sight');
      final locked = tester.widget<InkWell>(
        find.byKey(const ValueKey('level-pack1_lvl08')),
      );
      expect(locked.onTap, isNull);
      await reveal(tester, 'Table Talk', -200);
      await tester.tap(find.text('Table Talk'));
      await tester.pumpAndSettle();
      expect(find.text('Everyday Echoes · Level 1'), findsOneWidget);
      await reveal(tester, 'Back to collection');
      await tester.tap(find.text('Back to collection'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
