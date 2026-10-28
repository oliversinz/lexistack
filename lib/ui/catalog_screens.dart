import 'package:flutter/material.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../app/catalog_controller.dart';
import '../app/progress.dart';
import 'board_screen.dart';
import 'progress_status.dart';

void openAttempt(
  BuildContext context,
  CatalogController catalog,
  Attempt? attempt, {
  FinalizedResult? result,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) {
        if (attempt != null) {
          final pack = catalog.report!.catalog!.packs.firstWhere(
            (p) => p.id == attempt.game.level.packId,
          );
          return BoardScreen(
            controller: catalog.boardFor(attempt),
            number: pack.levels.indexWhere((l) => l.id == attempt.levelId) + 1,
          );
        }
        return CatalogPage(
          title: 'Saved result',
          children: [
            if (result != null) ...[
              const Text(
                'Saved result retained. Board details are unavailable.',
              ),
              Text('+${result.reward} coins awarded for this attempt'),
              SelectableText(result.shareText),
            ] else
              const Text(
                'This date or result is closed. Its board could not be recovered.',
              ),
          ],
        );
      },
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});
  final CatalogController controller;

  Future<void> _reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all progress?'),
        content: const Text(
          'This deletes saved attempts, results and settings, and restores 150 coins.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset progress'),
          ),
        ],
      ),
    );
    controller.progress!.reset(confirmed: confirmed == true);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final text = Theme.of(context).textTheme;
      final player = controller.progress;
      return CatalogPage(
        title: 'LexiStack',
        children: [
          Text('A LITTLE CURIOSITY. A NEW CONNECTION.', style: text.labelLarge),
          const SizedBox(height: 16),
          Text(
            'Familiar words.\nUnexpected company.',
            style: text.displaySmall,
          ),
          const SizedBox(height: 16),
          if (controller.loading) ...[
            const Center(child: CircularProgressIndicator()),
            const Text('Loading bundled collection…'),
          ] else if (controller.error != null) ...[
            Text('Collection could not load', style: text.titleLarge),
            SelectableText(controller.error!),
            FilledButton(
              onPressed: controller.load,
              child: const Text('Retry'),
            ),
          ] else if (player != null && !player.initialized)
            ProgressStatus(controller: player)
          else if (player != null) ...[
            ProgressStatus(controller: player),
            const SizedBox(height: 8),
            Text(
              '${player.state.gamesPlayed} games played · ${player.state.wins} wins · '
              '${(player.state.winRate * 100).toStringAsFixed(0)}% win rate · ${player.state.perfectWins} perfect wins',
              key: const Key('stats-summary'),
            ),
            Text(
              'Win mistakes 0 / 1 / 2 / 3 / 4+: ${player.state.winMistakeBuckets.join(' / ')}',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                final attempt = player.continueCampaign();
                if (attempt == null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PackScreen(
                        pack: player.campaignPacks.first,
                        controller: controller,
                      ),
                    ),
                  );
                } else {
                  openAttempt(context, controller, attempt);
                }
              },
              child: const Text('Continue Campaign'),
            ),
            if (player.dailyLevels.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Daily ${player.today}',
                key: const Key('daily-date'),
                style: text.titleLarge,
              ),
              Text(
                'Eight offline boards, rotating every eight days.\n'
                'Streak ${player.state.currentStreak(player.clock())} · Best ${player.state.bestDailyStreak}',
              ),
              OutlinedButton(
                onPressed: () {
                  final attempt = player.enterDaily();
                  openAttempt(
                    context,
                    controller,
                    attempt,
                    result: player.resultFor('', date: player.today),
                  );
                },
                child: Text(
                  player.state.daily.containsKey(player.today)
                      ? 'View Daily result'
                      : 'Play Daily',
                ),
              ),
            ],
            const SizedBox(height: 16),
            for (final pack in player.campaignPacks) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BUNDLED COLLECTION', style: text.labelLarge),
                      const SizedBox(height: 12),
                      Text(pack.title, style: text.headlineSmall),
                      const SizedBox(height: 8),
                      Text(pack.description, style: text.bodyLarge),
                      const SizedBox(height: 16),
                      Text(
                        '${pack.levels.length} level entries · Available offline',
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                PackScreen(pack: pack, controller: controller),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Explore collection'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextButton(
              onPressed: () => _reset(context),
              child: const Text('Reset progress'),
            ),
          ],
        ],
      );
    },
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
                      ? '${level.tiles.length} words · ${level.categories.length} groups · Best ${player.state.campaign[level.id]?.bestStars ?? 0} stars'
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
              !active && result != null ? 'View saved result' : 'Play / Resume',
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

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: children,
          ),
        ),
      ),
    ),
  );
}
