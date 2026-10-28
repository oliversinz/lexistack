import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/progress.dart';
import 'package:lexistack/app/progress_controller.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/core/game.dart';

import '../support/progress_fixture.dart';

void main() {
  test('F3-R01 failed read never overwrites existing progress on save retry', () async {
    final clock = TestClock();
    final original = await player(clock: clock);
    final board = firstBoard(original);
    win(board);
    win(BoardController(original, original.enterDaily()!));
    clock.day(1);
    original.enterDaily();
    board.newAttempt();
    board.pairMagnet();
    board.categoryPeek();
    mistake(board, 0);
    board.toggle(board.game.order.first);
    original.setSettings(theme: 'dark', haptics: false);
    await original.flush();
    final document = (original.storage as MemoryProgressStorage).value!;
    final store = MemoryProgressStorage(document)..failRead = true;

    final unavailable = await player(store: store, clock: clock);
    expect(unavailable.initialized, isFalse);
    expect(unavailable.loadStatus, ProgressLoadStatus.failed);
    expect(unavailable.loadWarning, isNotNull);
    expect(unavailable.storageWarning, isNull);
    expect(unavailable.saved, isFalse);
    expect(store.value, document);
    unavailable.retrySave();
    await unavailable.flush();
    expect(
      store.value == document,
      isTrue,
      reason: 'A failed read must not replace unknown saved data with defaults',
    );

    final placeholder = unavailable.state.encode();
    expect(unavailable.unlocked(board.game.level), isFalse);
    expect(unavailable.enterCampaign(board.game.level), isNull);
    expect(unavailable.enterCampaign(board.game.level, replay: true), isNull);
    expect(unavailable.continueCampaign(), isNull);
    expect(unavailable.enterDaily(), isNull);
    expect(unavailable.isCurrent(board.attempt), isFalse);
    var actionCalled = false;
    expect(
      unavailable.apply(board.attempt, (game) {
        actionCalled = true;
        return game.pairMagnet();
      }, price: 30),
      isA<Rejected>(),
    );
    expect(actionCalled, isFalse);
    final blockedBoard = BoardController(unavailable, board.attempt);
    expect(blockedBoard.pairMagnet(), isA<Rejected>());
    expect(blockedBoard.categoryPeek(), isA<Rejected>());
    expect(blockedBoard.extraLife(), isA<Rejected>());
    win(blockedBoard); // Even attempted completion cannot settle or pay out.
    expect(blockedBoard.game.isFinal, isFalse);
    unavailable.setSettings(theme: 'light', haptics: false);
    unavailable.reset(confirmed: true);
    unavailable.refreshDay();
    await unavailable.flush();
    expect(unavailable.state.encode(), placeholder);
    expect(store.value, document);
    expect(store.writes, isEmpty);

    await unavailable.retryLoad(); // Continued failure must stay unavailable.
    expect(unavailable.loadStatus, ProgressLoadStatus.failed);
    expect(store.value, document);
    expect(store.writes, isEmpty);

    store.failRead = false;
    final recovery = unavailable.retryLoad();
    expect(unavailable.loadStatus, ProgressLoadStatus.loading);
    expect(unavailable.initialized, isFalse);
    expect(unavailable.continueCampaign(), isNull);
    unavailable.retrySave();
    unavailable.reset(confirmed: true);
    await recovery;
    expect(unavailable.initialized, isTrue);
    expect(unavailable.loadStatus, ProgressLoadStatus.ready);
    expect(unavailable.loadWarning, isNull);
    expect(unavailable.storageWarning, isNull);
    expect(unavailable.recoveryNotice, isNull);
    expect(unavailable.saved, isTrue);
    // Includes coins, achievements, finalized history, both attempts and settings.
    expect(unavailable.state.toJson(), original.state.toJson());
    expect(unavailable.state.coins, 205);
    expect(unavailable.state.results, hasLength(2));
    expect(store.value, document);
    expect(store.writes, isEmpty);

    final restored = BoardController(
      unavailable,
      unavailable.state.attempts[board.attempt.levelId]!,
    );
    expect(restored.attempt.id, board.attempt.id);
    expect(restored.pairMagnet(), isA<Applied>());
    expect(unavailable.state.coins, 175);
    // Load retries after initialization cannot discard newer in-memory changes.
    await unavailable.retryLoad();
    await unavailable.flush();
    final again = await player(store: store, clock: clock);
    expect(again.state.toJson(), unavailable.state.toJson());
    expect(again.state.results, hasLength(2));
    expect(again.state.coins, 175);
  });

  test(
    'F3-R01 successful null read initializes legitimate fresh defaults',
    () async {
      final store = MemoryProgressStorage();
      final p = ProgressController(
        catalog: installedCatalog(),
        storage: store,
        clock: TestClock().call,
      );
      expect(p.loadStatus, ProgressLoadStatus.notLoaded);
      expect(p.initialized, isFalse);
      p.retrySave();
      expect(p.continueCampaign(), isNull);
      final loading = p.load();
      expect(p.loadStatus, ProgressLoadStatus.loading);
      p.retrySave();
      await loading;
      expect(p.initialized, isTrue);
      expect(p.saved, isTrue);
      expect(p.state.toJson(), Progress().toJson());
      expect(p.loadWarning, isNull);
      expect(p.recoveryNotice, isNull);
      expect(store.value, isNull);
      expect(store.writes, isEmpty);
      firstBoard(p).pairMagnet();
      await p.flush();
      expect((await player(store: store)).state.coins, 120);
    },
  );

  for (final document in ['{', '{"version":99}']) {
    test(
      'F3-R01 retry validates malformed/unsupported document $document',
      () async {
        final store = MemoryProgressStorage(document)..failRead = true;
        final p = await player(store: store);
        expect(p.initialized, isFalse);
        expect(p.recoveryNotice, isNull);
        store.failRead = false;
        await p.retryLoad();
        expect(p.initialized, isTrue);
        expect(p.loadWarning, isNull);
        expect(p.storageWarning, isNull);
        expect(p.recoveryNotice, isNotNull);
        expect(p.state.toJson(), Progress().toJson());
        expect(store.value, document);
        expect(store.writes, isEmpty);
        firstBoard(p).pairMagnet();
        await p.flush();
        expect((await player(store: store)).state.coins, 120);
      },
    );
  }
}
