import 'package:flutter/material.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../app/board_controller.dart';
import '../core/game.dart';

class BoardScreen extends StatelessWidget {
  const BoardScreen({
    super.key,
    required this.controller,
    required this.number,
  });
  final BoardController controller;
  final int number;

  Future<void> _restart(BuildContext context) async {
    if (!controller.game.isFinal) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Start a new attempt?'),
          content: const Text('This replaces your current in-memory attempt.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Keep playing'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Start new attempt'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    controller.newAttempt();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final game = controller.game;
      final playing = game.status == GameStatus.playing;
      final text = Theme.of(context).textTheme;
      return Scaffold(
        appBar: AppBar(title: Text('$number · ${game.level.title}')),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: SingleChildScrollView(
                key: const Key('board-scroll'),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'F2 PREVIEW · IN MEMORY ONLY',
                      style: text.labelMedium,
                    ),
                    const SizedBox(height: 12),
                    Semantics(
                      label: '${game.lives} of 4 lives',
                      child: ExcludeSemantics(
                        child: Row(
                          children: [
                            for (var i = 0; i < 4; i++)
                              Icon(
                                i < game.lives
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: const Color(0xFF9D3344),
                                size: 28,
                              ),
                            const SizedBox(width: 12),
                            Expanded(child: Text('${game.mistakes} mistakes')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Groups found: ${game.solvedIds.length}/4',
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (game.status == GameStatus.lostPendingDecision)
                      _PendingDecision(controller: controller)
                    else if (game.isFinal) ...[
                      Text(
                        game.status == GameStatus.won
                            ? 'You found every connection!'
                            : 'Loss accepted · Solutions revealed',
                        style: text.headlineSmall,
                      ),
                      if (game.status == GameStatus.won)
                        Text(
                          '${'★' * game.stars}${'☆' * (3 - game.stars)} · ${game.mistakes} mistakes',
                          key: const Key('win-stars'),
                          style: text.titleLarge,
                        ),
                      const SizedBox(height: 12),
                    ] else
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          controller.feedback,
                          key: const Key('feedback'),
                          style: text.bodyLarge,
                        ),
                      ),
                    for (final category in game.revealedCategories) ...[
                      const SizedBox(height: 12),
                      _CategoryCard(category: category),
                    ],
                    if (playing) ...[
                      for (final category in game.remainingCategories.where(
                        (c) => game.peekedIds.contains(c.id),
                      ))
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text('Peek: ${category.title}'),
                        ),
                      const SizedBox(height: 16),
                      GridView.count(
                        key: const Key('tile-grid'),
                        crossAxisCount: 4,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                        childAspectRatio: .95,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final id in game.order)
                            _BoardTile(
                              tile: game.tile(id),
                              controller: controller,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DragTarget<String>(
                        onWillAcceptWithDetails: (details) =>
                            game.order.contains(details.data),
                        onAcceptWithDetails: (details) =>
                            controller.drag(details.data),
                        builder: (context, candidates, rejected) => Container(
                          key: const Key('selection-tray'),
                          constraints: const BoxConstraints(minHeight: 64),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: candidates.isEmpty
                                ? const Color(0xFFEAECE1)
                                : const Color(0xFFD2E8DC),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'Selected ${game.selection.length}/4 · Drop a word here'
                            '${game.selection.isEmpty ? '' : '\n${game.selection.map((id) => game.tile(id).text).join(' · ')}'}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: controller.shuffle,
                              child: const Text('Shuffle'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: game.selection.isEmpty
                                  ? null
                                  : controller.deselect,
                              child: const Text('Deselect'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        key: const Key('submit'),
                        onPressed: game.canSubmit ? controller.submit : null,
                        child: const Text('Submit'),
                      ),
                      const SizedBox(height: 20),
                      const Text('Hint effects · F2 preview: no coins'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed:
                                game.remainingCategories.any(
                                  (c) => !game.pairs.containsKey(c.id),
                                )
                                ? controller.pairMagnet
                                : null,
                            child: const Text('Pair Magnet'),
                          ),
                          OutlinedButton(
                            onPressed:
                                game.remainingCategories.any(
                                  (c) => !game.peekedIds.contains(c.id),
                                )
                                ? controller.categoryPeek
                                : null,
                            child: const Text('Category Peek'),
                          ),
                          OutlinedButton(
                            onPressed: game.lives < 4
                                ? controller.extraLife
                                : null,
                            child: const Text('Extra Life'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to toggle. Hold a word, then drag it onto another word or the selection tray.',
                      ),
                    ],
                    if (game.isFinal) ...[
                      const SizedBox(height: 20),
                      Text('The red herrings', style: text.titleLarge),
                      for (final hint in game.revealedRedHerrings)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(hint.note),
                        ),
                    ],
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => _restart(context),
                      child: Text(
                        game.isFinal ? 'Replay · New attempt' : 'New attempt',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back to level'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _PendingDecision extends StatelessWidget {
  const _PendingDecision({required this.controller});
  final BoardController controller;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Out of lives · Your choice',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your attempt is waiting. Rescue it to continue, or accept the loss to reveal the remaining connections.',
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('rescue'),
            onPressed: controller.extraLife,
            child: const Text(
              'Rescue / Extra Life\n(F2 preview: no coins)',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('reveal-loss'),
            onPressed: controller.revealLoss,
            child: const Text('Reveal / Accept Loss'),
          ),
        ],
      ),
    ),
  );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});
  final Category category;
  @override
  Widget build(BuildContext context) => Container(
    key: ValueKey('category-${category.id}'),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const [
        Color(0xFFF1D582),
        Color(0xFFB8D6AA),
        Color(0xFFB9D3EF),
        Color(0xFFD9C4EB),
      ][category.difficultyTier - 1],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tier ${category.difficultyTier} · ${category.title}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(category.tiles.map((t) => t.text).join(' · ')),
        const SizedBox(height: 8),
        Text(category.triviaFact),
      ],
    ),
  );
}

class _BoardTile extends StatelessWidget {
  const _BoardTile({required this.tile, required this.controller});
  final Tile tile;
  final BoardController controller;

  @override
  Widget build(BuildContext context) {
    final game = controller.game;
    final selected = game.selection.contains(tile.id);
    final pairIndex = game.pairs.values.toList().indexWhere(
      (pair) => pair.contains(tile.id),
    );
    Widget face({bool hovering = false}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF315747) : const Color(0xFFE9E6DC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hovering ? const Color(0xFF315747) : Colors.transparent,
          width: 3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              tile.text.replaceAll(' ', '\n'),
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: selected ? Colors.white : const Color(0xFF252C25),
              ),
            ),
          ),
          if (pairIndex >= 0)
            Text(
              'Pair ${pairIndex + 1}',
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white : const Color(0xFF252C25),
              ),
            ),
        ],
      ),
    );
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => game.order.contains(details.data),
      onAcceptWithDetails: (details) =>
          controller.drag(details.data, target: tile.id),
      builder: (context, candidates, rejected) => LongPressDraggable<String>(
        data: tile.id,
        maxSimultaneousDrags: 1,
        hapticFeedbackOnStart: false,
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(width: 100, height: 70, child: face()),
        ),
        childWhenDragging: Opacity(opacity: .4, child: face()),
        child: Semantics(
          button: true,
          selected: selected,
          label:
              '${tile.text}${pairIndex < 0 ? '' : ', Pair ${pairIndex + 1}'}',
          onTap: () => controller.toggle(tile.id),
          child: GestureDetector(
            key: ValueKey('tile-${tile.text}'),
            excludeFromSemantics: true,
            behavior: HitTestBehavior.opaque,
            onTap: () => controller.toggle(tile.id),
            child: ExcludeSemantics(
              child: face(hovering: candidates.isNotEmpty),
            ),
          ),
        ),
      ),
    );
  }
}
