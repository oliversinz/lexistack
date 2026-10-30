import 'package:flutter_test/flutter_test.dart';
import 'package:lexistack/app/board_controller.dart';
import 'package:lexistack/app/storage.dart';
import 'package:lexistack/core/game.dart';

import '../support/progress_fixture.dart';

void main() {
  test('Pack 6 stages 9 and 16 retain attempts, hints, rewards and replay caps', () async {
    var p = await player();
    final pack = p.campaignPacks.last;
    expect(pack.id, 'pack6');
    expect(pack.levels, hasLength(16));
    final store = p.storage as MemoryProgressStorage;
    for (final (index, level) in pack.levels.indexed) {
      expect(p.unlocked(level), isTrue);
      if (index < 15) {
        expect(p.unlocked(pack.levels[index + 1]), isFalse);
        expect(p.enterCampaign(pack.levels[index + 1]), isNull);
      }
      var b = BoardController(p, p.enterCampaign(level)!);
      if (index == 8 || index == 15) {
        b.pairMagnet();
        b.categoryPeek();
        if (index == 15) {
          pending(b);
        } else {
          mistake(b, 0);
          submitIds(b, level.categories.first.tiles.map((t) => t.id));
          b.shuffle();
          b.toggle(b.game.order.last);
        }
        await p.flush();
        final snapshot = p.state.toJson();
        final attempt = b.attempt.toJson();
        p = await player(store: store);
        expect(p.recoveryNotice, isNull);
        expect(p.state.toJson(), snapshot);
        b = BoardController(p, p.continueCampaign()!);
        // Re-entry updates only the recency counter.
        final resumed = b.attempt.toJson();
        resumed['entered'] = attempt['entered'];
        expect(resumed, attempt);
        if (index == 15) {
          expect(b.game.status, GameStatus.lostPendingDecision);
          expect(b.game.revealedCategories, isEmpty);
          expect(b.extraLife(), isA<Applied>());
        }
      }
      final balance = p.state.coins;
      win(b);
      final reward = index == 15
          ? 15
          : index == 8
          ? 30
          : 50;
      expect(p.resultFor(level.id)!.reward, reward);
      expect(p.state.coins, balance + reward);
      expect(
        p.state.campaign[level.id]!.bestStars,
        index == 15
            ? 1
            : index == 8
            ? 2
            : 3,
      );
      expect(p.state.campaign.length, index + 1);
    }
    expect(pack.levels.every(p.unlocked), isTrue);
    final finalLevel = pack.levels.last;
    for (final reward in [5, 0]) {
      final replay = BoardController(
        p,
        p.enterCampaign(finalLevel, replay: true)!,
      );
      win(replay);
      expect(p.resultFor(finalLevel.id)!.reward, reward);
      expect(p.state.campaign[finalLevel.id]!.bestStars, 3);
      await p.flush();
      final snapshot = p.state.toJson();
      p = await player(store: store);
      expect(p.state.toJson(), snapshot);
      final balance = p.state.coins;
      expect(p.enterCampaign(finalLevel)!.game.status, GameStatus.won);
      expect(p.state.coins, balance);
    }
    // Pack completion does not skip untouched earlier packs or open a stage 17.
    expect(p.continueCampaign()!.levelId, 'pack1_lvl01');
    await p.flush();
  });
}
