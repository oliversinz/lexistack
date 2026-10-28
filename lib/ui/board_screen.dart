import 'dart:math' as math;

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../app/board_controller.dart';
import '../core/game.dart';
import 'progress_status.dart';
import 'common.dart';
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
  final boosters = GlobalKey();

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

  Widget actionDock(BuildContext context) {
    final game = controller.game;
    final colors = Theme.of(context).colorScheme;
    return Container(
      key: const Key('action-dock'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: DragTarget<String>(
                  onWillAcceptWithDetails: (details) =>
                      game.order.contains(details.data),
                  onAcceptWithDetails: (details) =>
                      act(() => controller.drag(details.data)),
                  builder: (context, candidates, rejected) => Container(
                    key: const Key('selection-tray'),
                    constraints: const BoxConstraints(minHeight: 56),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: candidates.isEmpty
                          ? colors.surfaceContainerHigh
                          : colors.primaryContainer,
                      border: Border.all(
                        color: candidates.isEmpty
                            ? colors.outlineVariant
                            : colors.primary,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Semantics(
                      label:
                          'Selection tray, ${game.selection.length} of 4: ${game.selection.map((id) => game.tile(id).text).join(', ')}',
                      child: ExcludeSemantics(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Selected ${game.selection.length}/4',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                game.selection.isEmpty
                                    ? 'Drop a word here'
                                    : game.selection
                                          .map((id) => game.tile(id).text)
                                          .join(' · '),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                key: const Key('submit'),
                onPressed: game.canSubmit ? () => act(controller.submit) : null,
                child: const Text('Submit'),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => act(controller.shuffle),
                  child: const Text('Shuffle'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: game.selection.isEmpty
                      ? null
                      : () => act(controller.deselect),
                  child: const Text('Deselect'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    final target = boosters.currentContext;
                    if (target != null) {
                      Scrollable.ensureVisible(
                        target,
                        duration: motionDuration(context, 200),
                        alignment: 0,
                      );
                    }
                  },
                  child: const Text('Boosters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget resultHeader(BuildContext context) {
    final game = controller.game;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return TweenAnimationBuilder<double>(
      key: ValueKey('result-entry-${controller.attempt.id}'),
      tween: Tween(begin: 0, end: 1),
      duration: motionDuration(context, 220),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.primary),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              game.status == GameStatus.won
                  ? 'CONNECTION COMPLETE'
                  : 'THE REVEAL',
              style: text.labelSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (game.status == GameStatus.won) ...[
              Center(child: StarRow(stars: game.stars, size: 46)),
              const SizedBox(height: 8),
            ],
            Text(
              game.status == GameStatus.won
                  ? 'You found every connection!'
                  : 'Loss accepted · Solutions revealed',
              style: text.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (game.status == GameStatus.won)
              Text(
                '${'★' * game.stars}${'☆' * (3 - game.stars)} · ${counted(game.mistakes, 'mistake')}',
                key: const Key('win-stars'),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            Text(
              '+${controller.result?.reward ?? 0} coins awarded for this attempt',
              textAlign: TextAlign.center,
              style: text.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '${counted(controller.progress.state.gamesPlayed, 'game')} played · ${counted(controller.progress.state.wins, 'win')}',
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
            if (controller.result != null) ...[
              const SizedBox(height: 16),
              ShareButton(result: controller.result!),
            ],
            if (controller.date == null && widget.onNext != null)
              TextButton(
                onPressed: widget.onNext,
                child: const Text('Next connection'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final game = controller.game;
      final playing = game.status == GameStatus.playing && controller.active;
      final text = Theme.of(context).textTheme;
      final colors = Theme.of(context).colorScheme;
      final pack = controller.progress.catalog.packs.firstWhere(
        (p) => p.id == game.level.packId,
      );
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '$number · ${game.level.title}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Icon(Icons.toll_rounded, size: 18, color: colors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${controller.coins} coins',
                    key: const Key('wallet'),
                    style: text.labelLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, bounds) {
              final tileHeight = bounds.maxHeight < 650 ? 60.0 : 78.0;
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      key: const Key('board-scroll'),
                      controller: scroll,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ProgressStatus(
                            controller: controller.progress,
                            showWallet: false,
                          ),
                          Text(
                            controller.date != null
                                ? 'Daily ${controller.date}'
                                : pack.title.toUpperCase(),
                            style: text.labelSmall,
                          ),
                          if (controller.expired)
                            const Text(
                              'A new day has begun. Return Home to open today’s Daily.',
                            ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
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
                                          color: colors.error,
                                          size: 21,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  counted(game.mistakes, 'mistake'),
                                  style: text.bodySmall,
                                ),
                              ),
                              Text(
                                '${game.solvedIds.length}/4 found',
                                style: text.labelMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (playing) ...[
                            Row(
                              children: [
                                for (final category in game.level.categories)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Semantics(
                                        label:
                                            'Tier ${category.difficultyTier} group, ${game.solvedIds.contains(category.id)
                                                ? 'solved'
                                                : game.peekedIds.contains(category.id)
                                                ? category.title
                                                : 'hidden'}',
                                        child: ExcludeSemantics(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  tierColors[category
                                                          .difficultyTier -
                                                      1],
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'T${category.difficultyTier} ${game.solvedIds.contains(category.id) ? '✓' : '· · ·'}',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                color: tierInk,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Semantics(
                                liveRegion: true,
                                child: Text(
                                  controller.feedback,
                                  key: const Key('feedback'),
                                  style: text.bodySmall,
                                ),
                              ),
                            ),
                            for (final category in game.remainingCategories)
                              if (game.peekedIds.contains(category.id))
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    'Peek: ${category.title}',
                                    style: text.labelLarge,
                                  ),
                                ),
                          ],
                          if (game.status == GameStatus.lostPendingDecision &&
                              !controller.expired)
                            _PendingDecision(controller: controller, act: act)
                          else if (game.isFinal)
                            resultHeader(context),
                          for (final category in game.revealedCategories) ...[
                            const SizedBox(height: 8),
                            _CategoryCard(
                              key: ValueKey('reveal-${category.id}'),
                              category: category,
                              animate: justSolved == category.id,
                              compact: playing,
                              expanded:
                                  justSolved == category.id ||
                                  game.solvedIds.lastOrNull == category.id,
                            ),
                          ],
                          if (playing) ...[
                            const SizedBox(height: 8),
                            GridView.count(
                              key: const Key('tile-grid'),
                              crossAxisCount: 4,
                              mainAxisSpacing: 7,
                              crossAxisSpacing: 7,
                              childAspectRatio:
                                  (bounds.maxWidth - 32 - 21) / 4 / tileHeight,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                for (final id in game.order)
                                  _BoardTile(
                                    key: ValueKey(id),
                                    tile: game.tile(id),
                                    controller: controller,
                                    act: act,
                                    shake: shake,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Container(
                              key: boosters,
                              padding: const EdgeInsets.only(top: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: colors.outlineVariant),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'BOOSTERS · PAY ONLY ON SUCCESS',
                                    style: text.labelSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: _Booster(
                                          label: 'Pair Magnet · 30',
                                          enabled: controller.canPair,
                                          reason: controller.coins < 30
                                              ? 'Needs 30 coins'
                                              : 'No unmarked group remains',
                                          onPressed: () =>
                                              act(controller.pairMagnet),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: _Booster(
                                          label: 'Category Peek · 40',
                                          enabled: controller.canPeek,
                                          reason: controller.coins < 40
                                              ? 'Needs 40 coins'
                                              : 'No hidden title remains',
                                          onPressed: () =>
                                              act(controller.categoryPeek),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: _Booster(
                                          label: 'Extra Life · 60',
                                          enabled: controller.canExtraLife,
                                          reason: game.lives == 4
                                              ? 'All four lives are full'
                                              : 'Needs 60 coins',
                                          onPressed: () =>
                                              act(controller.extraLife),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to toggle. Hold a word, then drag it onto another word or the selection tray.',
                              style: text.bodySmall,
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
                            if (controller.date == null) ...[
                              const SizedBox(height: 16),
                              OutlinedButton(
                                onPressed: controller.newAttempt,
                                child: const Text('Replay · New attempt'),
                              ),
                            ],
                          ],
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Back to level'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (playing) actionDock(context),
                ],
              );
            },
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
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(
          color: Theme.of(context).colorScheme.secondary,
          width: 5,
        ),
      ),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Icon(Icons.pause_circle_outline, size: 48),
          ),
          Text(
            'Out of lives · Your choice',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your attempt is waiting. Rescue it to continue, or accept the loss to reveal the remaining connections. Revealing is final.',
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

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    super.key,
    required this.category,
    this.animate = false,
    this.compact = false,
    this.expanded = true,
  });
  final Category category;
  final bool animate, compact, expanded;
  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  late bool expanded = widget.expanded;
  @override
  void didUpdateWidget(_CategoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expanded != widget.expanded) expanded = widget.expanded;
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    final showDetails = !widget.compact || expanded;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: widget.animate ? 0 : 1, end: 1),
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
          decoration: BoxDecoration(
            color: tierColors[category.difficultyTier - 1],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tierInk.withValues(alpha: .2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.compact)
                Semantics(
                  button: true,
                  expanded: expanded,
                  child: InkWell(
                    onTap: () => setState(() => expanded = !expanded),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Tier ${category.difficultyTier} · ${category.title}',
                                style: Theme.of(context).textTheme.labelLarge!
                                    .copyWith(color: tierInk),
                              ),
                            ),
                            Icon(
                              expanded ? Icons.expand_less : Icons.expand_more,
                              color: tierInk,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                  child: Text(
                    'Tier ${category.difficultyTier} · ${category.title}',
                    style: Theme.of(context).textTheme.titleMedium!
                        .copyWith(color: tierInk),
                  ),
                ),
              if (showDetails)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    14,
                    widget.compact ? 0 : 6,
                    14,
                    12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.tiles.map((t) => t.text).join(' · '),
                        style: Theme.of(context).textTheme.labelSmall!
                            .copyWith(color: tierInk, letterSpacing: 0),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        category.triviaFact,
                        style: Theme.of(context).textTheme.bodySmall!
                            .copyWith(color: tierInk, height: 1.4),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoardTile extends StatefulWidget {
  const _BoardTile({
    super.key,
    required this.tile,
    required this.controller,
    required this.act,
    required this.shake,
  });
  final Tile tile;
  final BoardController controller;
  final BoardAction act;
  final Animation<double> shake;

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
    Widget face({bool hovering = false}) => AnimatedBuilder(
      animation: widget.shake,
      builder: (context, child) => Transform.translate(
        offset: Offset(
          selected
              ? math.sin(widget.shake.value * math.pi * 6) *
                    4 *
                    (1 - widget.shake.value)
              : 0,
          0,
        ),
        child: child,
      ),
      child: AnimatedScale(
        scale: selected ? .96 : 1,
        duration: motionDuration(context, 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? colors.primary.withValues(alpha: .35)
                    : colors.outlineVariant,
                offset: Offset(0, selected ? 1 : 3),
              ),
            ],
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
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        tile.text.replaceAll(' ', '\n'),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: -.3,
                          color: selected ? colors.onPrimary : colors.onSurface,
                        ),
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
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, 64),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            ),
            onPressed: enabled ? onPressed : null,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
      if (!enabled)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: ExcludeSemantics(
            child: Text(
              reason,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
    ],
  );
}
