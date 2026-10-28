import 'dart:math' as math;

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../app/board_controller.dart';
import '../core/game.dart';
import 'progress_status.dart';
import 'share_button.dart';
import 'theme.dart';

typedef BoardAction = void Function(GameOutcome Function() action);

class BoardScreen extends StatefulWidget {
  const BoardScreen({
    super.key,
    required this.controller,
    required this.number,
    this.onNext,
  });
  final BoardController controller;
  final int number;
  final VoidCallback? onNext;

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen>
    with SingleTickerProviderStateMixin {
  BoardController get controller => widget.controller;
  int get number => widget.number;
  late final shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  final scroll = ScrollController();
  String? justSolved;

  Future<void> haptic(Future<void> Function() feedback) async {
    try {
      await feedback();
    } catch (error) {
      debugPrint('Haptic feedback unavailable: $error');
    }
  }

  void act(GameOutcome Function() action) {
    final before = List<String>.of(controller.game.selection);
    final coins = controller.coins;
    final outcome = action();
    if (outcome is Rejected || outcome is AlreadyGuessed) return;
    if (controller.progress.state.haptics) {
      if (outcome is Solved) {
        haptic(HapticFeedback.mediumImpact);
      } else if (outcome is Mismatch) {
        haptic(HapticFeedback.heavyImpact);
      } else if (controller.coins < coins) {
        haptic(HapticFeedback.lightImpact);
      } else if (!listEquals(before, controller.game.selection)) {
        haptic(HapticFeedback.selectionClick);
      }
    }
    if (outcome is Solved) setState(() => justSolved = outcome.category.id);
    if (outcome is Mismatch && !MediaQuery.disableAnimationsOf(context)) {
      shake.forward(from: 0);
    }
    if (controller.game.status != GameStatus.playing || outcome is Solved) {
      // Decisions and newly revealed groups should be immediately discoverable.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && scroll.hasClients) scroll.jumpTo(0);
      });
    }
  }

  @override
  void dispose() {
    shake.dispose();
    scroll.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final game = controller.game;
      final playing = game.status == GameStatus.playing && controller.active;
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
                controller: scroll,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProgressStatus(controller: controller.progress),
                    if (controller.date != null)
                      Text('Daily ${controller.date}'),
                    if (controller.expired)
                      const Text(
                        'A new day has begun. Return Home to open today’s Daily.',
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
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFFFFAEB9)
                                    : const Color(0xFF9D3344),
                                size: 28,
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(counted(game.mistakes, 'mistake')),
                            ),
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
                    if (game.status == GameStatus.lostPendingDecision &&
                        !controller.expired)
                      _PendingDecision(controller: controller, act: act)
                    else if (game.isFinal) ...[
                      TweenAnimationBuilder<double>(
                        key: ValueKey('result-entry-${controller.attempt.id}'),
                        tween: Tween(begin: 0, end: 1),
                        duration: motionDuration(context, 220),
                        builder: (context, value, child) =>
                            Opacity(opacity: value, child: child),
                        child: Text(
                          game.status == GameStatus.won
                              ? 'You found every connection!'
                              : 'Loss accepted · Solutions revealed',
                          style: text.headlineSmall,
                        ),
                      ),
                      if (game.status == GameStatus.won)
                        Text(
                          '${'★' * game.stars}${'☆' * (3 - game.stars)} · ${counted(game.mistakes, 'mistake')}',
                          key: const Key('win-stars'),
                          style: text.titleLarge,
                        ),
                      Text(
                        '+${controller.result?.reward ?? 0} coins awarded for this attempt',
                      ),
                      Text(
                        '${counted(controller.progress.state.gamesPlayed, 'game')} played · ${counted(controller.progress.state.wins, 'win')}',
                      ),
                      if (controller.result != null) ...[
                        const SizedBox(height: 16),
                        ShareButton(result: controller.result!),
                      ],
                      if (controller.date == null && widget.onNext != null) ...[
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: widget.onNext,
                          child: const Text('Next connection'),
                        ),
                      ],
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
                      _CategoryCard(
                        key: ValueKey('reveal-${category.id}'),
                        category: category,
                        animate: justSolved == category.id,
                      ),
                    ],
                    if (playing) ...[
                      for (final category in game.remainingCategories)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Semantics(
                            label:
                                'Tier ${category.difficultyTier} group, ${game.peekedIds.contains(category.id) ? category.title : 'hidden'}',
                            child: ExcludeSemantics(
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color:
                                          tierColors[category.difficultyTier -
                                              1],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      game.peekedIds.contains(category.id)
                                          ? 'Peek: ${category.title}'
                                          : 'Tier ${category.difficultyTier} · Hidden connection',
                                      style: text.labelMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      AnimatedBuilder(
                        animation: shake,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(
                            math.sin(shake.value * math.pi * 6) *
                                4 *
                                (1 - shake.value),
                            0,
                          ),
                          child: child,
                        ),
                        child: GridView.count(
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
                                act: act,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      DragTarget<String>(
                        onWillAcceptWithDetails: (details) =>
                            game.order.contains(details.data),
                        onAcceptWithDetails: (details) =>
                            act(() => controller.drag(details.data)),
                        builder: (context, candidates, rejected) => Container(
                          key: const Key('selection-tray'),
                          constraints: const BoxConstraints(minHeight: 64),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: candidates.isEmpty
                                ? Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHigh
                                : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
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
                              onPressed: () => act(controller.shuffle),
                              child: const Text('Shuffle'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: game.selection.isEmpty
                                  ? null
                                  : () => act(controller.deselect),
                              child: const Text('Deselect'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      FilledButton(
                        key: const Key('submit'),
                        onPressed: game.canSubmit
                            ? () => act(controller.submit)
                            : null,
                        child: const Text('Submit'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Boosters · Coins are charged only on success',
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Booster(
                            label: 'Pair Magnet · 30',
                            enabled: controller.canPair,
                            reason: controller.coins < 30
                                ? 'Needs 30 coins'
                                : 'No unmarked group remains',
                            onPressed: () => act(controller.pairMagnet),
                          ),
                          _Booster(
                            label: 'Category Peek · 40',
                            enabled: controller.canPeek,
                            reason: controller.coins < 40
                                ? 'Needs 40 coins'
                                : 'No hidden title remains',
                            onPressed: () => act(controller.categoryPeek),
                          ),
                          _Booster(
                            label: 'Extra Life · 60',
                            enabled: controller.canExtraLife,
                            reason: game.lives == 4
                                ? 'All four lives are full'
                                : 'Needs 60 coins',
                            onPressed: () => act(controller.extraLife),
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
                      if (controller.result != null) ...[
                        const SizedBox(height: 16),
                        SelectableText(
                          controller.result!.shareText,
                          key: const Key('share-data'),
                        ),
                      ],
                    ],
                    const SizedBox(height: 20),
                    if (game.isFinal && controller.date == null)
                      OutlinedButton(
                        onPressed: controller.newAttempt,
                        child: const Text('Replay · New attempt'),
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
  const _PendingDecision({required this.controller, required this.act});
  final BoardController controller;
  final BoardAction act;
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
            onPressed: controller.canExtraLife
                ? () => act(controller.extraLife)
                : null,
            child: const Text(
              'Rescue / Extra Life · 60 coins',
              textAlign: TextAlign.center,
            ),
          ),
          if (!controller.canExtraLife)
            const Text(
              'Not enough coins to rescue. You can still accept the loss.',
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('reveal-loss'),
            onPressed: () => act(controller.revealLoss),
            child: const Text('Reveal / Accept Loss'),
          ),
        ],
      ),
    ),
  );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    super.key,
    required this.category,
    this.animate = false,
  });
  final Category category;
  final bool animate;
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: animate ? 0 : 1, end: 1),
    duration: motionDuration(context, 350),
    builder: (context, value, child) => ClipRect(
      child: Align(
        heightFactor: value,
        child: Opacity(opacity: value, child: child),
      ),
    ),
    child: DefaultTextStyle.merge(
      style: const TextStyle(color: tierInk),
      child: Container(
        key: ValueKey('category-${category.id}'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tierColors[category.difficultyTier - 1],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tier ${category.difficultyTier} · ${category.title}',
              style: Theme.of(context).textTheme.titleMedium!
                  .copyWith(color: tierInk),
            ),
            const SizedBox(height: 6),
            Text(category.tiles.map((t) => t.text).join(' · ')),
            const SizedBox(height: 8),
            Text(category.triviaFact),
          ],
        ),
      ),
    ),
  );
}

class _BoardTile extends StatefulWidget {
  const _BoardTile({
    required this.tile,
    required this.controller,
    required this.act,
  });
  final Tile tile;
  final BoardController controller;
  final BoardAction act;

  @override
  State<_BoardTile> createState() => _BoardTileState();
}

class _BoardTileState extends State<_BoardTile> {
  bool focused = false;
  Tile get tile => widget.tile;
  BoardController get controller => widget.controller;
  BoardAction get act => widget.act;

  @override
  Widget build(BuildContext context) {
    final game = controller.game;
    final selected = game.selection.contains(tile.id);
    final pairIndex = game.pairs.values.toList().indexWhere(
      (pair) => pair.contains(tile.id),
    );
    final colors = Theme.of(context).colorScheme;
    Widget face({bool hovering = false}) => AnimatedScale(
      scale: selected ? .96 : 1,
      duration: motionDuration(context, 120),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: focused
                ? colors.onSurface
                : hovering || selected
                ? colors.primary
                : colors.outlineVariant,
            width: focused || selected ? 3 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
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
                      color: selected ? colors.onPrimary : colors.onSurface,
                    ),
                  ),
                ),
                if (pairIndex >= 0)
                  Text(
                    'Pair ${pairIndex + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: selected ? colors.onPrimary : colors.onSurface,
                    ),
                  ),
              ],
            ),
            if (selected)
              Positioned(
                right: 0,
                top: 0,
                child: Icon(Icons.check, size: 12, color: colors.onPrimary),
              ),
          ],
        ),
      ),
    );
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => game.order.contains(details.data),
      onAcceptWithDetails: (details) =>
          act(() => controller.drag(details.data, target: tile.id)),
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
          onTap: () => act(() => controller.toggle(tile.id)),
          child: InkWell(
            key: ValueKey('tile-${tile.text}'),
            excludeFromSemantics: true,
            enableFeedback: false,
            onFocusChange: (value) => setState(() => focused = value),
            borderRadius: BorderRadius.circular(12),
            onTap: () => act(() => controller.toggle(tile.id)),
            child: ExcludeSemantics(
              child: face(hovering: candidates.isNotEmpty),
            ),
          ),
        ),
      ),
    );
  }
}

class _Booster extends StatelessWidget {
  const _Booster({
    required this.label,
    required this.enabled,
    required this.reason,
    required this.onPressed,
  });
  final String label, reason;
  final bool enabled;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      MergeSemantics(
        child: Semantics(
          hint: enabled ? 'Available' : reason,
          child: OutlinedButton(
            onPressed: enabled ? onPressed : null,
            child: Text(label),
          ),
        ),
      ),
      if (!enabled)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: ExcludeSemantics(
            child: Text(reason, style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
    ],
  );
}
