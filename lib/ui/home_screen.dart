import 'package:flutter/material.dart';

import '../app/catalog_controller.dart';
import '../core/game.dart';
import 'catalog_screens.dart';
import 'common.dart';
import 'progress_status.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});
  final CatalogController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final player = controller.progress;
      final ready = player != null && player.initialized;
      final text = Theme.of(context).textTheme;
      void page(Widget screen) => Navigator.push(
        context,
        MaterialPageRoute<void>(builder: (_) => screen),
      );
      return CatalogPage(
        title: 'LexiStack',
        actions: ready
            ? [
                IconButton(
                  tooltip: 'Statistics',
                  icon: const Icon(Icons.bar_chart_rounded),
                  onPressed: () => page(StatsScreen(controller: player)),
                ),
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: () => page(SettingsScreen(controller: player)),
                ),
              ]
            : null,
        children: [
          Text('A LITTLE CURIOSITY. A NEW CONNECTION.', style: text.labelSmall),
          const SizedBox(height: 12),
          Text(
            'Familiar words.\nUnexpected company.',
            style: text.displaySmall,
          ),
          const SizedBox(height: 20),
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
          ] else if (player != null && !ready)
            ProgressStatus(controller: player)
          else if (ready) ...[
            ProgressStatus(controller: player),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                final attempt = player.continueCampaign();
                if (attempt == null) {
                  page(PacksScreen(controller: controller));
                } else {
                  openAttempt(context, controller, attempt);
                }
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Continue Campaign'),
            ),
            const SizedBox(height: 12),
            Text(
              '${counted(player.state.gamesPlayed, 'game')} played · ${counted(player.state.wins, 'win')}',
              key: const Key('stats-summary'),
              style: text.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (player.dailyLevels.isNotEmpty) ...[
              InsetCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('THE DAILY CONNECTION', style: text.labelSmall),
                    const SizedBox(height: 8),
                    Text(
                      'Daily ${player.today}',
                      key: const Key('daily-date'),
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      player.state.daily.containsKey(player.today)
                          ? player.state.daily[player.today]!.won
                                ? 'Completed · Won today'
                                : 'Completed · Loss accepted'
                          : player.state.dailyAttempt?.date == player.today
                          ? player.state.dailyAttempt!.game.status ==
                                    GameStatus.lostPendingDecision
                                ? 'Unfinished · Decision waiting'
                                : 'Unfinished · Ready to resume'
                          : 'A fresh connection for today.',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Streak ${player.state.currentStreak(player.clock())} · Best ${player.state.bestDailyStreak}',
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => openAttempt(
                        context,
                        controller,
                        player.enterDaily(),
                        result: player.resultFor('', date: player.today),
                      ),
                      child: Text(
                        player.state.daily.containsKey(player.today)
                            ? 'View Daily result'
                            : player.state.dailyAttempt?.date == player.today
                            ? 'Resume Daily'
                            : 'Play Daily',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Eight offline boards, rotating every eight days.',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: Text('Your collections', style: text.titleLarge),
                ),
                TextButton(
                  onPressed: () => page(PacksScreen(controller: controller)),
                  child: const Text('Campaign'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final pack in player.campaignPacks) ...[
              PackCard(pack: pack, controller: controller),
              const SizedBox(height: 16),
            ],
            TextButton.icon(
              onPressed: () => page(StatsScreen(controller: player)),
              icon: const Icon(Icons.bar_chart_rounded),
              label: const Text('Statistics'),
            ),
            TextButton.icon(
              onPressed: () => page(SettingsScreen(controller: player)),
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Settings'),
            ),
          ],
        ],
      );
    },
  );
}
