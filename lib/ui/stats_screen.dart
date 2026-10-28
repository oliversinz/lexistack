import 'package:flutter/material.dart';

import '../app/progress_controller.dart';
import 'common.dart';
import 'theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key, required this.controller});
  final ProgressController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final state = controller.state;
      final text = Theme.of(context).textTheme;
      return CatalogPage(
        title: 'Statistics',
        children: [
          Text('Every connection counts.', style: text.headlineSmall),
          const SizedBox(height: 20),
          if (state.gamesPlayed == 0) ...[
            const Text(
              'Your story starts with a puzzle. Finish a game to see your statistics here. Unfinished games do not count.',
            ),
            const SizedBox(height: 20),
          ],
          InsetCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${counted(state.gamesPlayed, 'game')} played',
                  style: text.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  '${counted(state.wins, 'win')} · ${(state.winRate * 100).toStringAsFixed(0)}% win rate',
                ),
                const SizedBox(height: 8),
                Text(
                  '${counted(state.perfectWins, 'perfect win')} · zero mistakes',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Mistakes in your wins', style: text.titleLarge),
          const SizedBox(height: 12),
          for (final (index, count) in state.winMistakeBuckets.indexed)
            Semantics(
              label:
                  '${index == 4 ? '4 or more mistakes' : counted(index, 'mistake')}: ${counted(count, 'win')}',
              child: ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(index == 4 ? '4+' : '$index'),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            minHeight: 16,
                            value: state.wins == 0 ? 0 : count / state.wins,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text('$count', textAlign: TextAlign.end),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          InsetCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily rhythm', style: text.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Current streak: ${counted(state.currentStreak(controller.clock()), 'day')}',
                ),
                Text('Best streak: ${counted(state.bestDailyStreak, 'day')}'),
              ],
            ),
          ),
        ],
      );
    },
  );
}
