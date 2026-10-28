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
      final colors = Theme.of(context).colorScheme;
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
          const Divider(),
          Row(
            children: [
              Expanded(
                child: Text('THE WORD CONNECTION GAME', style: text.labelSmall),
              ),
              if (ready)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.toll_rounded, size: 18, color: colors.primary),
                    const SizedBox(width: 5),
                    Text(
                      '${player.state.coins} coins',
                      key: const Key('wallet'),
                      style: text.labelLarge,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Good words.\nGreat company.', style: homeHeroStyle),
          const SizedBox(height: 8),
          const Text('Sixteen words. Four connections. Your move.'),
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
            ProgressStatus(controller: player, showWallet: false),
            FilledButton(
              onPressed: () {
                final attempt = player.continueCampaign();
                if (attempt == null) {
                  page(PacksScreen(controller: controller));
                } else {
                  openAttempt(context, controller, attempt);
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text('Continue Campaign')),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Campaign · ${player.campaignPacks.expand((p) => p.levels).where((l) => (player.state.campaign[l.id]?.bestStars ?? 0) > 0).length} / ${player.campaignPacks.expand((p) => p.levels).length} stages solved',
              style: text.labelLarge,
            ),
            const SizedBox(height: 3),
            Text(
              '${counted(player.state.gamesPlayed, 'game')} played · ${counted(player.state.wins, 'win')}',
              key: const Key('stats-summary'),
              style: text.bodySmall,
            ),
            const SizedBox(height: 22),
            if (player.dailyLevels.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  border: Border(
                    left: BorderSide(color: colors.secondary, width: 5),
                    top: BorderSide(color: colors.outlineVariant),
                    right: BorderSide(color: colors.outlineVariant),
                    bottom: BorderSide(color: colors.outlineVariant),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'THE DAILY EDITION',
                            style: text.labelSmall,
                          ),
                        ),
                        Icon(
                          Icons.wb_sunny_outlined,
                          color: colors.primary,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Daily ${player.today}',
                      key: const Key('daily-date'),
                      style: text.titleLarge,
                    ),
                    const SizedBox(height: 6),
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
                      style: text.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => openAttempt(
                        context,
                        controller,
                        player.enterDaily(),
                        result: player.resultFor('', date: player.today),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              player.state.daily.containsKey(player.today)
                                  ? 'View Daily result'
                                  : player.state.dailyAttempt?.date ==
                                        player.today
                                  ? 'Resume Daily'
                                  : 'Play Daily',
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                    Text(
                      'Eight offline boards, rotating every eight days.',
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],
            Row(
              children: [
                Expanded(
                  child: Text('The puzzle shelf', style: text.titleLarge),
                ),
                TextButton(
                  onPressed: () => page(PacksScreen(controller: controller)),
                  child: const Text('Campaign'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final pack in player.campaignPacks) ...[
              PackCard(pack: pack, controller: controller),
              const SizedBox(height: 16),
            ],
          ],
        ],
      );
    },
  );
}
