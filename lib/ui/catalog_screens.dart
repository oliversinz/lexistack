import 'package:flutter/material.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../app/catalog_controller.dart';
import '../app/progress.dart';
import '../core/game.dart';
import 'board_screen.dart';
import 'common.dart';
import 'progress_status.dart';
import 'share_button.dart';

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
  Widget build(BuildContext context) => InsetCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(pack.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(pack.description),
        const SizedBox(height: 12),
        Text('${pack.levels.length} level entries · Available offline'),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => PackScreen(pack: pack, controller: controller),
            ),
          ),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('Explore collection'),
        ),
      ],
    ),
  );
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
      final player = controller.progress!;
      return CatalogPage(
        title: pack.title,
        children: [
          ProgressStatus(controller: player),
          Text(pack.description, style: text.headlineSmall),
          const SizedBox(height: 12),
          Text('${pack.levels.length} levels · Win a stage to unlock the next'),
          const SizedBox(height: 24),
          for (final (index, level) in pack.levels.indexed) ...[
            Card(
              child: ListTile(
                key: ValueKey('level-${level.id}'),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Text(
                  '${index + 1}'.padLeft(2, '0'),
                  style: text.titleLarge,
                ),
                title: Text(level.title),
                subtitle: Text(
                  player.unlocked(level)
                      ? '${player.state.attempts[level.id]?.game.status == GameStatus.lostPendingDecision
                            ? 'Decision waiting'
                            : player.state.attempts.containsKey(level.id)
                            ? 'In progress'
                            : player.resultFor(level.id) != null
                            ? 'Finished'
                            : 'Ready to play'} · Best ${player.state.campaign[level.id]?.bestStars ?? 0} stars'
                      : 'Locked · Win stage $index',
                ),
                trailing: Icon(
                  player.unlocked(level)
                      ? Icons.chevron_right
                      : Icons.lock_outline,
                ),
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
              ),
            ),
            const SizedBox(height: 12),
          ],
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
          Text(level.title, style: text.displaySmall),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
          const SizedBox(height: 24),
          Text('Best ${player.state.campaign[level.id]?.bestStars ?? 0} stars'),
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
          const SizedBox(height: 24),
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
