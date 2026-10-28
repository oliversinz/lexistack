import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/core/game.dart';
import 'package:lexistack/ui/board_screen.dart';
import 'package:lexistack/ui/home_screen.dart';
import 'package:lexistack/ui/settings_screen.dart';
import 'package:lexistack/ui/theme.dart';

import '../support/progress_fixture.dart' as fixture;
import 'board_test.dart'
    show
        enterBoard,
        viewport,
        tapVisible,
        tile,
        submitWords,
        pendingLoss,
        wrongs;
import 'progress_test.dart' show board, home, solve;

Future<void> back(WidgetTester t) async {
  await t.pageBack();
  await t.pumpAndSettle();
}

Future<void> recreate(WidgetTester t, MemoryProgressStorage store) async {
  await t.pumpWidget(const SizedBox.shrink());
  await t.pumpAndSettle();
  await home(t, store, fixture.TestClock());
}

void main() {
  final calls = <MethodCall>[];
  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          calls.add(call);
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );
  List<Object?> haptics() => calls
      .where((c) => c.method == 'HapticFeedback.vibrate')
      .map((c) => c.arguments)
      .toList();

  testWidgets(
    'UI-08 actual clipboard Campaign golden, repeated copy and reopen do not pay',
    (t) async {
      viewport(t, const Size(390, 844));
      final store = MemoryProgressStorage();
      await enterBoard(t, store: store);
      expect(find.byKey(const Key('copy-result')), findsNothing);
      await solve(t);
      final p = board(t).progress;
      const golden =
          'LexiStack · Everyday Echoes #1\n★★★ · 0 mistakes\n🟨🟨🟨🟨\n🟩🟩🟩🟩\n🟦🟦🟦🟦\n🟪🟪🟪🟪';
      for (var i = 0; i < 2; i++) {
        await tapVisible(t, find.byKey(const Key('copy-result')));
        expect(
          calls.lastWhere((c) => c.method == 'Clipboard.setData').arguments,
          {'text': golden},
        );
        expect(find.text('Result copied'), findsOneWidget);
        expect(p.state.coins, 200);
        expect(p.state.gamesPlayed, 1);
      }
      await p.flush();
      await recreate(t, store);
      await tapVisible(t, find.text('Explore collection'));
      await tapVisible(t, find.text('Table Talk'));
      await tapVisible(t, find.text('View saved result'));
      await tapVisible(t, find.byKey(const Key('copy-result')));
      expect(board(t).coins, 200);
      expect(board(t).progress.state.gamesPlayed, 1);
      expect(
        calls.lastWhere((c) => c.method == 'Clipboard.setData').arguments,
        {'text': golden},
      );
    },
  );

  testWidgets(
    'UI-07/08 peeked pending loss has no visual or semantic spoilers after reconstruction; exact loss copy',
    (t) async {
      viewport(t, const Size(360, 640), scale: 1.3);
      final semantics = t.ensureSemantics();
      final store = MemoryProgressStorage();
      await enterBoard(t, store: store);
      await tapVisible(t, find.text('Category Peek · 40'));
      await pendingLoss(t);
      final original = board(t).game.snapshot();
      final level = board(t).game.level;
      await board(t).progress.flush();
      await recreate(t, store);
      await tapVisible(t, find.text('Continue Campaign'));
      expect(board(t).game.snapshot(), original);
      expect(find.byKey(const Key('copy-result')), findsNothing);
      final semanticDump = t
          .binding
          .renderViews
          .first
          .owner!
          .semanticsOwner!
          .rootSemanticsNode!
          .toStringDeep();
      for (final c in level.categories) {
        expect(find.textContaining(c.title), findsNothing);
        expect(semanticDump, isNot(contains(c.title)));
        expect(semanticDump, isNot(contains(c.triviaFact)));
        for (final word in c.tiles) {
          expect(semanticDump, isNot(contains(word.text)));
        }
      }
      for (final h in level.redHerrings) {
        expect(semanticDump, isNot(contains(h.note)));
      }
      await tapVisible(t, find.byKey(const Key('rescue')));
      expect(board(t).coins, 50);
      final rescued = board(t).game.snapshot();
      for (final key in ['order', 'selection', 'guesses', 'pairs', 'peeked']) {
        expect(rescued[key], original[key]);
      }
      expect(board(t).game.lives, 1);
      await submitWords(t, ['MUFFIN', 'KNIFE', 'DEUCE', 'LOG']);
      await tapVisible(t, find.byKey(const Key('reveal-loss')));
      expect(board(t).game.status, GameStatus.lostFinal);
      await tapVisible(t, find.byKey(const Key('copy-result')));
      expect(
        calls.lastWhere((c) => c.method == 'Clipboard.setData').arguments,
        {
          'text': 'LexiStack · Everyday Echoes #1\n0/4 groups · 5 mistakes\n🟨🟨🟨🟩\n🟨🟨🟩🟩\n🟨🟩🟦🟪\n🟨🟩🟦🟪\n🟨🟩🟦🟪',
        },
      );
      expect(board(t).extraLife(), isA<Rejected>());
      expect(board(t).coins, 50);
      semantics.dispose();
    },
  );

  testWidgets('UI-08 Daily exact clipboard payload and saved fallback', (
    t,
  ) async {
    viewport(t, const Size(390, 844));
    final store = MemoryProgressStorage();
    await home(t, store, fixture.TestClock());
    await tapVisible(t, find.text('Play Daily'));
    await solve(t);
    const golden =
        'LexiStack · Daily 2026-10-28\n★★★ · 0 mistakes\n🟨🟨🟨🟨\n🟩🟩🟩🟩\n🟦🟦🟦🟦\n🟪🟪🟪🟪';
    await tapVisible(t, find.byKey(const Key('copy-result')));
    expect(calls.lastWhere((c) => c.method == 'Clipboard.setData').arguments, {
      'text': golden,
    });
    expect(find.text('Replay · New attempt'), findsNothing);
    await board(t).progress.flush();
    final saved = jsonDecode(store.value!) as Map<String, dynamic>;
    // Preserve the independent result summary while removing recoverable details.
    (saved['results'] as List).first['board'] = null;
    store.value = jsonEncode(saved);
    await recreate(t, store);
    await tapVisible(t, find.text('View Daily result'));
    expect(
      find.textContaining('Board details are unavailable'),
      findsOneWidget,
    );
    await tapVisible(t, find.byKey(const Key('copy-result')));
    expect(calls.lastWhere((c) => c.method == 'Clipboard.setData').arguments, {
      'text': golden,
    });
    expect(find.byType(BoardScreen), findsNothing);
  });

  testWidgets(
    'UI-08 waits for successful platform transfer; failed copy never reports success',
    (t) async {
      viewport(t, const Size(390, 844));
      await enterBoard(t);
      await solve(t);
      final transfer = Completer<void>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') await transfer.future;
            return null;
          });
      await t.tap(find.byKey(const Key('copy-result')));
      await t.pump();
      expect(find.text('Result copied'), findsNothing);
      expect(
        t.widget<FilledButton>(find.byKey(const Key('copy-result'))).onPressed,
        isNull,
      );
      transfer.completeError(PlatformException(code: 'unavailable'));
      await t.pumpAndSettle();
      expect(
        find.text('Could not copy result. Please try again.'),
        findsOneWidget,
      );
      expect(find.text('Result copied'), findsNothing);
      expect(board(t).coins, 200);
    },
  );

  testWidgets(
    'UI-09 themes retain navigator and board handle; haptics persist; reset invalidates stale handle',
    (t) async {
      viewport(t, const Size(360, 640), scale: 1.3);
      final store = MemoryProgressStorage();
      await enterBoard(t, store: store);
      await tapVisible(t, tile('TOAST'));
      final handle = board(t);
      final state = handle.game.snapshot();
      // Open the actual Settings route above a live board to stress route lifetimes.
      Navigator.of(t.element(find.byType(BoardScreen))).push(
        MaterialPageRoute<void>(
          builder: (_) => SettingsScreen(controller: handle.progress),
        ),
      );
      await t.pumpAndSettle();
      for (final mode in ['dark', 'light', 'system', 'dark']) {
        t
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .jumpTo(0);
        await t.pumpAndSettle();
        await tapVisible(t, find.byKey(ValueKey('theme-$mode')));
        expect(
          t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode!.name,
          mode,
        );
        expect(find.byType(SettingsScreen), findsOneWidget);
      }
      await tapVisible(t, find.byType(SwitchListTile));
      expect(handle.progress.state.haptics, isFalse);
      await back(t);
      expect(identical(board(t), handle), isTrue);
      expect(board(t).game.snapshot(), state);
      calls.clear();
      await tapVisible(t, tile('WAFFLE'));
      await tapVisible(t, find.text('Pair Magnet · 30'));
      expect(haptics(), isEmpty);
      await handle.progress.flush();
      await recreate(t, store);
      expect(
        t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );
      await tapVisible(t, find.text('Continue Campaign'));
      final stale = board(t);
      expect(stale.progress.state.haptics, isFalse);
      calls.clear();
      await tapVisible(t, tile('MUFFIN'));
      expect(haptics(), isEmpty);
      Navigator.of(t.element(find.byType(BoardScreen))).push(
        MaterialPageRoute<void>(
          builder: (_) => SettingsScreen(controller: stale.progress),
        ),
      );
      await t.pumpAndSettle();
      await tapVisible(t, find.text('Reset progress'));
      await t.tap(find.text('Cancel'));
      await t.pumpAndSettle();
      expect(stale.coins, 120);
      await tapVisible(t, find.text('Reset progress'));
      await t.tap(find.widgetWithText(TextButton, 'Reset progress'));
      await t.pumpAndSettle();
      final p = stale.progress;
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(BoardScreen), findsNothing);
      expect(p.isCurrent(stale.attempt), isFalse);
      expect(p.apply(stale.attempt, (g) => g.pairMagnet()), isA<Rejected>());
      expect(p.state.coins, 150);
      expect(p.state.gamesPlayed, 0);
      expect(p.state.results, isEmpty);
      expect(p.state.attempts, isEmpty);
      expect(p.state.daily, isEmpty);
      expect(p.state.haptics, isTrue);
      expect(
        t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.system,
      );
    },
  );

  testWidgets(
    'UI-12 enabled haptics map only successful outcomes, including rescue and rejected fifth/duplicate',
    (t) async {
      viewport(t, const Size(390, 844));
      await enterBoard(t);
      calls.clear();
      await tapVisible(t, tile('TOAST'));
      expect(haptics(), ['HapticFeedbackType.selectionClick']);
      await tapVisible(t, find.text('Deselect'));
      expect(haptics().last, 'HapticFeedbackType.selectionClick');
      await tapVisible(t, find.text('Shuffle'));
      expect(haptics(), hasLength(2));
      await tapVisible(t, find.text('Pair Magnet · 30'));
      expect(haptics().last, 'HapticFeedbackType.lightImpact');
      await submitWords(t, wrongs[0]);
      expect(haptics().last, 'HapticFeedbackType.heavyImpact');
      calls.clear();
      await tapVisible(t, tile('SERVE')); // fifth selection is rejected
      await tapVisible(t, find.byKey(const Key('submit'))); // duplicate
      expect(haptics(), isEmpty);
      await submitWords(t, ['TOAST', 'WAFFLE', 'MUFFIN', 'BAGEL']);
      expect(haptics().last, 'HapticFeedbackType.mediumImpact');
      // Three new wrong sets among the remaining categories reach pending loss.
      for (final words in [
        ['FORK', 'SPOON', 'KNIFE', 'SERVE'],
        ['FORK', 'SPOON', 'SERVE', 'LOVE'],
        ['FORK', 'SERVE', 'TRAFFIC', 'PAPER'],
      ]) {
        await submitWords(t, words);
      }
      expect(board(t).game.status, GameStatus.lostPendingDecision);
      calls.clear();
      await tapVisible(t, find.byKey(const Key('rescue')));
      expect(haptics(), ['HapticFeedbackType.lightImpact']);
      expect(board(t).coins, 60);
    },
  );

  testWidgets(
    'UI-09/12 disabled haptics suppress wrong solve booster rescue after reconstruction',
    (t) async {
      viewport(t, const Size(390, 844));
      final store = MemoryProgressStorage();
      final p = await fixture.player(store: store);
      p.setSettings(haptics: false);
      await p.flush();
      await enterBoard(t, store: store);
      calls.clear();
      await tapVisible(t, find.text('Pair Magnet · 30'));
      await pendingLoss(t);
      await tapVisible(t, find.byKey(const Key('rescue')));
      await solve(t);
      expect(haptics(), isEmpty);
      expect(board(t).coins, 75);
      expect(board(t).progress.state.gamesPlayed, 1);
      final staleFinal = board(t);
      final originalAttempt = staleFinal.attempt;
      Navigator.of(t.element(find.byType(BoardScreen))).push(
        MaterialPageRoute<void>(
          builder: (_) => SettingsScreen(controller: staleFinal.progress),
        ),
      );
      await t.pumpAndSettle();
      await tapVisible(t, find.text('Reset progress'));
      await t.tap(find.widgetWithText(TextButton, 'Reset progress'));
      await t.pumpAndSettle();
      staleFinal.newAttempt();
      expect(staleFinal.attempt, same(originalAttempt));
      expect(staleFinal.progress.state.attempts, isEmpty);
      expect(staleFinal.coins, 150);
    },
  );

  testWidgets(
    'UI-05 exhausted and unaffordable boosters remain disabled with no state change',
    (t) async {
      viewport(t, const Size(390, 844));
      final store = MemoryProgressStorage();
      final p = await fixture.player(store: store);
      // Earn coins normally so all four category purchases are affordable.
      fixture.win(fixture.firstBoard(p));
      await p.flush();
      await home(t, store, fixture.TestClock());
      await tapVisible(t, find.text('Continue Campaign'));
      for (var i = 0; i < 4; i++) {
        await tapVisible(t, find.text('Category Peek · 40'));
      }
      expect(board(t).coins, 40);
      expect(board(t).game.peekedIds.length, 4);
      expect(find.text('No hidden title remains'), findsOneWidget);
      final snapshot = board(t).game.snapshot();
      calls.clear();
      await tapVisible(t, find.text('Category Peek · 40'));
      expect(board(t).game.snapshot(), snapshot);
      expect(board(t).coins, 40);
      expect(haptics(), isEmpty);
      await tapVisible(t, find.text('Pair Magnet · 30'));
      expect(board(t).coins, 10);
      calls.clear();
      await tapVisible(t, find.text('Pair Magnet · 30'));
      await tapVisible(t, find.text('Extra Life · 60'));
      expect(board(t).coins, 10);
      expect(board(t).game.pairs.length, 1);
      expect(haptics(), isEmpty);
    },
  );

  testWidgets(
    'UI-12 platform haptic failure cannot roll back a successful purchase',
    (t) async {
      viewport(t, const Size(390, 844));
      await enterBoard(t);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              throw PlatformException(code: 'unsupported');
            }
            return null;
          });
      await tapVisible(t, find.text('Pair Magnet · 30'));
      expect(board(t).coins, 120);
      expect(board(t).game.pairs.length, 1);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'UI-09 F3-R01 blocks settings and wallet then restores dark/haptics from retry',
    (t) async {
      viewport(t, const Size(360, 640), scale: 1.3);
      final store = MemoryProgressStorage();
      final p = await fixture.player(store: store);
      p.setSettings(theme: 'dark', haptics: false);
      fixture.firstBoard(p).pairMagnet();
      await p.flush();
      final original = store.value;
      final writes = store.writes.length;
      store.failRead = true;
      await home(t, store, fixture.TestClock());
      expect(find.byTooltip('Settings'), findsNothing);
      expect(find.byKey(const Key('wallet')), findsNothing);
      expect(find.text('Reset progress'), findsNothing);
      expect(find.text('Retry save'), findsNothing);
      expect(find.text('Continue Campaign'), findsNothing);
      expect(store.value, original);
      expect(store.writes.length, writes);
      store.failRead = false;
      await tapVisible(t, find.text('Retry load'));
      expect(find.text('120 coins'), findsOneWidget);
      expect(
        t.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );
      await tapVisible(t, find.text('Continue Campaign'));
      calls.clear();
      await tapVisible(t, tile('TOAST'));
      expect(haptics(), isEmpty);
    },
  );

  testWidgets(
    'UI-03 Statistics finalized-only empty and completed values; back and Settings links',
    (t) async {
      viewport(t, const Size(390, 844));
      await home(t, MemoryProgressStorage(), fixture.TestClock());
      await tapVisible(t, find.byTooltip('Statistics'));
      expect(find.textContaining('Your story starts'), findsOneWidget);
      expect(find.text('0 games played'), findsOneWidget);
      await back(t);
      await tapVisible(t, find.text('Continue Campaign'));
      await solve(t);
      await back(t);
      await tapVisible(t, find.byTooltip('Statistics'));
      expect(find.text('1 game played'), findsOneWidget);
      expect(find.text('1 win · 100% win rate'), findsOneWidget);
      expect(find.text('1 perfect win · zero mistakes'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(5));
      await back(t);
      await tapVisible(t, find.byTooltip('Settings'));
      expect(find.text('Saved on this device'), findsOneWidget);
      await back(t);
      expect(find.text('Continue Campaign'), findsOneWidget);
    },
  );

  testWidgets(
    'UI-11 tile semantics unique, selected state and touch targets; four slots and lives',
    (t) async {
      viewport(t, const Size(390, 844));
      final semantics = t.ensureSemantics();
      await enterBoard(t);
      expect(find.bySemanticsLabel('4 of 4 lives'), findsOneWidget);
      for (var tier = 1; tier <= 4; tier++) {
        expect(
          find.bySemanticsLabel('Tier $tier group, hidden'),
          findsOneWidget,
        );
      }
      await tapVisible(t, tile('TOAST'));
      expect(find.bySemanticsLabel('TOAST'), findsOneWidget);
      expect(
        t
            .getSemantics(find.bySemanticsLabel('TOAST'))
            .getSemanticsData()
            .flagsCollection
            .isSelected
            .name,
        'isTrue',
      );
      for (final word in board(t).game.level.tiles) {
        final size = t.getSize(tile(word.text));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
      for (final label in [
        'Shuffle',
        'Deselect',
        'Submit',
        'Pair Magnet · 30',
        'Category Peek · 40',
        'Extra Life · 60',
      ]) {
        final button = find
            .ancestor(
              of: find.text(label),
              matching: find.bySubtype<ButtonStyleButton>(),
            )
            .first;
        expect(t.getSize(button).height, greaterThanOrEqualTo(48));
        expect(t.getSize(button).width, greaterThanOrEqualTo(48));
      }
      semantics.dispose();
    },
  );

  test('UI-11 auditable normal-text contrast in both themes and all tiers', () {
    double ratio(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return (x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05));
    }

    for (final tier in tierColors) {
      expect(ratio(tierInk, tier), greaterThanOrEqualTo(4.5));
    }
    for (final mode in Brightness.values) {
      final c = lexistackTheme(brightness: mode).colorScheme;
      for (final pair in [
        (c.onSurface, c.surface),
        (c.onSurface, c.surfaceContainerHighest),
        (c.onPrimary, c.primary),
        (c.onSurface, c.surfaceContainerLow),
        (c.onSurface, c.surfaceContainerHigh),
      ]) {
        expect(ratio(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
      }
    }
  });

  for (final reduced in [false, true]) {
    testWidgets(
      'UI-06/12 motion reduced=$reduced never repeats settlement when interrupted',
      (t) async {
        viewport(t, const Size(390, 844));
        t.platformDispatcher.accessibilityFeaturesTestValue =
            FakeAccessibilityFeatures(disableAnimations: reduced);
        addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
        await enterBoard(t);
        await tapVisible(t, tile('TOAST'));
        final scale = t.widget<AnimatedScale>(
          find.descendant(
            of: tile('TOAST'),
            matching: find.byType(AnimatedScale),
          ),
        );
        expect(scale.duration, Duration(milliseconds: reduced ? 0 : 120));
        final categories = board(t).game.level.categories;
        for (final category in categories.take(3)) {
          await submitWords(t, category.tiles.map((x) => x.text).toList());
        }
        for (final word in categories.last.tiles) {
          await tapVisible(t, tile(word.text));
        }
        await t.ensureVisible(find.byKey(const Key('submit')));
        await t.pumpAndSettle();
        await t.tap(find.byKey(const Key('submit')));
        await t.pump(); // Settlement precedes the first reveal animation frame.
        final handle = board(t);
        expect(handle.coins, 200);
        expect(handle.progress.state.gamesPlayed, 1);
        final reveal = t.widget<TweenAnimationBuilder<double>>(
          find.descendant(
            of: find.byKey(ValueKey('reveal-${categories.last.id}')),
            matching: find.byType(TweenAnimationBuilder<double>),
          ),
        );
        expect(reveal.duration, Duration(milliseconds: reduced ? 0 : 350));
        await t.pumpWidget(const SizedBox.shrink());
        await t.pump(const Duration(milliseconds: 400));
        expect(handle.progress.state.coins, 200);
        expect(handle.progress.state.gamesPlayed, 1);
        expect(t.takeException(), isNull);
      },
    );
  }
}
