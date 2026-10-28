import 'package:flutter/material.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../app/catalog_controller.dart';
import '../app/progress.dart';
import '../core/game.dart';
import 'board_screen.dart';
import 'common.dart';
import 'progress_status.dart';
import 'share_button.dart';
import 'theme.dart';

void openAttempt(
  BuildContext context,
  CatalogController catalog,
  Attempt? attempt, {
  FinalizedResult? result,
  bool replace = false,
}) {
  Widget createScreen() {
    if (attempt != null) {
      final pack = catalog.report!.catalog!.packs.firstWhere(
        (p) => p.id == attempt.game.level.packId,
      );
      return BoardScreen(
        controller: catalog.boardFor(attempt),
        number: pack.levels.indexWhere((l) => l.id == attempt.levelId) + 1,
        onNext: () {
          final next = catalog.progress!.continueCampaign();
          if (next != null) {
            openAttempt(context, catalog, next, replace: true);
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => PacksScreen(controller: catalog),
              ),
            );
          }
        },
      );
    }
    return CatalogPage(
      title: 'Saved result',
      children: [
        if (result != null) ...[
          const Text('Saved result retained. Board details are unavailable.'),
          Text('+${result.reward} coins awarded for this attempt'),
          SelectableText(result.shareText),
          const SizedBox(height: 16),
          ShareButton(result: result),
        ] else
          const Text(
            'This date or result is closed. Its board could not be recovered.',
          ),
      ],
    );
  }

  // A route owns one board handle. Theme and wallet rebuilds must not replace it.
  final screen = createScreen();
  final route = MaterialPageRoute<void>(builder: (_) => screen);
  if (replace) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).push(route);
  }
}

class PacksScreen extends StatelessWidget {
  const PacksScreen({super.key, required this.controller});
  final CatalogController controller;
  @override
  Widget build(BuildContext context) => CatalogPage(
    title: 'Campaign',
    children: [
      Text(
        'Follow your curiosity.',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      const Text(
        'Each collection is a fresh trail. Start with its first puzzle.',
      ),
      const SizedBox(height: 20),
      for (final pack in controller.progress!.campaignPacks) ...[
        PackCard(pack: pack, controller: controller),
        const SizedBox(height: 16),
      ],
    ],
  );
}

class PackCard extends StatelessWidget {
  const PackCard({super.key, required this.pack, required this.controller});
  final Pack pack;
  final CatalogController controller;
  @override
  Widget build(BuildContext context) {
    final player = controller.progress!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final number =
        player.campaignPacks.toList().indexWhere((p) => p.id == pack.id) + 1;
    final won = pack.levels
        .where((l) => (player.state.campaign[l.id]?.bestStars ?? 0) > 0)
        .length;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: colors.outlineVariant, offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '$number'.padLeft(2, '0'),
                    style: text.headlineSmall!.copyWith(
                      color: colors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('COLLECTION $number', style: text.labelSmall),
                      const SizedBox(height: 4),
                      Text(pack.title, style: text.titleLarge),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(pack.description),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final level in pack.levels)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Container(
                        height: 6,
                        color:
                            (player.state.campaign[level.id]?.bestStars ?? 0) >
                                0
                            ? colors.primary
                            : colors.outlineVariant,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$won / ${pack.levels.length} solved · Available offline',
              style: text.bodySmall,
            ),
            TextButton(
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) =>
                      PackScreen(pack: pack, controller: controller),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text('Explore collection')),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PackScreen extends StatelessWidget {
  const PackScreen({super.key, required this.pack, required this.controller});
  final Pack pack;
  final CatalogController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final text = Theme.of(context).textTheme;
      final colors = Theme.of(context).colorScheme;
      final player = controller.progress!;
      return CatalogPage(
        title: pack.title,
        children: [
          ProgressStatus(controller: player),
          const SizedBox(height: 12),
          Text('One connection at a time.', style: text.headlineSmall),
          const SizedBox(height: 8),
          Text('${pack.levels.length} levels · Win a stage to unlock the next'),
          const SizedBox(height: 20),
          for (final (index, level) in pack.levels.indexed)
            Padding(
              padding: EdgeInsets.only(
                left: index.isOdd ? 18 : 0,
                right: index.isEven ? 18 : 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (index > 0)
                    Container(
                      margin: const EdgeInsets.only(left: 26),
                      width: 2,
                      height: 14,
                      color: colors.outlineVariant,
                    ),
                  Material(
                    color: player.unlocked(level)
                        ? colors.surfaceContainerLow
                        : colors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: player.unlocked(level)
                            ? colors.primary
                            : colors.outlineVariant,
                      ),
                    ),
                    child: InkWell(
                      key: ValueKey('level-${level.id}'),
                      borderRadius: BorderRadius.circular(10),
                      onTap: !player.unlocked(level)
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => LevelEntryScreen(
                                  pack: pack,
                                  level: level,
                                  number: index + 1,
                                  controller: controller,
                                ),
                              ),
                            ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 40,
                              child: Text(
                                '${index + 1}'.padLeft(2, '0'),
                                style: text.headlineSmall,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(level.title, style: text.titleMedium),
                                  const SizedBox(height: 3),
                                  Text(
                                    !player.unlocked(level)
                                        ? 'Locked · Win stage $index'
                                        : player
                                                  .state
                                                  .attempts[level.id]
                                                  ?.game
                                                  .status ==
                                              GameStatus.lostPendingDecision
                                        ? 'Decision waiting'
                                        : player.state.attempts.containsKey(
                                            level.id,
                                          )
                                        ? 'In progress'
                                        : player.resultFor(level.id) != null
                                        ? (player
                                                          .state
                                                          .campaign[level.id]
                                                          ?.bestStars ??
                                                      0) >
                                                  0
                                              ? 'Won · View or replay'
                                              : 'Finished · View or replay'
                                        : 'Ready to play',
                                    style: text.bodySmall,
                                  ),
                                  if (player.unlocked(level))
                                    StarRow(
                                      stars:
                                          player
                                              .state
                                              .campaign[level.id]
                                              ?.bestStars ??
                                          0,
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              !player.unlocked(level)
                                  ? Icons.lock_outline
                                  : player
                                            .state
                                            .attempts[level.id]
                                            ?.game
                                            .status ==
                                        GameStatus.lostPendingDecision
                                  ? Icons.pause_circle_outline
                                  : (player
                                                .state
                                                .campaign[level.id]
                                                ?.bestStars ??
                                            0) >
                                        0
                                  ? Icons.check_circle_outline
                                  : Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

class LevelEntryScreen extends StatelessWidget {
  const LevelEntryScreen({
    super.key,
    required this.pack,
    required this.level,
    required this.number,
    required this.controller,
  });
  final Pack pack;
  final Level level;
  final int number;
  final CatalogController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final text = Theme.of(context).textTheme;
      final player = controller.progress!;
      final result = player.resultFor(level.id);
      final active = player.state.attempts.containsKey(level.id);
      return CatalogPage(
        title: 'Level details',
        children: [
          ProgressStatus(controller: player),
          Text('${pack.title} · Level $number', style: text.labelLarge),
          const SizedBox(height: 16),
          Text(level.title, style: text.headlineMedium),
          const SizedBox(height: 16),
          InsetCard(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PuzzleMark(),
                  const SizedBox(height: 16),
                  Text(
                    '${level.tiles.length} words',
                    style: text.headlineMedium,
                  ),
                  Text(
                    '${level.categories.length} hidden connections',
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  const Text('Find the four groups that belong together.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Best ${counted(player.state.campaign[level.id]?.bestStars ?? 0, 'star')}',
          ),
          FilledButton(
            onPressed: !player.unlocked(level)
                ? null
                : () => openAttempt(
                    context,
                    controller,
                    player.enterCampaign(level),
                    result: result,
                  ),
            child: Text(
              active
                  ? 'Resume'
                  : result != null
                  ? 'View saved result'
                  : 'Play',
            ),
          ),
          if (!active &&
              (result != null || player.state.campaign.containsKey(level.id)))
            OutlinedButton(
              onPressed: () => openAttempt(
                context,
                controller,
                player.enterCampaign(level, replay: true),
              ),
              child: const Text('Replay · New attempt'),
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to collection'),
          ),
        ],
      );
    },
  );
}
