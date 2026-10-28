import 'package:flutter/material.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../app/catalog_controller.dart';
import 'board_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final CatalogController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final text = Theme.of(context).textTheme;
      final report = controller.report;
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
          Text(
            'Explore the first collection of word connections.',
            style: text.bodyLarge,
          ),
          const SizedBox(height: 28),
          if (controller.loading) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 12),
            const Text('Loading bundled collection…'),
          ] else if (controller.error != null) ...[
            Text('Collection could not load', style: text.titleLarge),
            const SizedBox(height: 12),
            SelectableText(controller.error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: controller.load,
              child: const Text('Retry'),
            ),
          ] else if (report != null) ...[
            for (final pack in report.catalog!.packs) ...[
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
                        onPressed: () => Navigator.of(context).push(
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
            if (report.warnings.isNotEmpty)
              SelectableText(report.warnings.join('\n')),
          ],
          const SizedBox(height: 12),
          Text('F2 PLAYABLE PREVIEW', style: text.labelLarge),
          const SizedBox(height: 8),
          const Text(
            'Play all eight preview levels. Attempts stay in memory only; '
            'closing the process loses them. Progression and Daily come later.',
          ),
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
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return CatalogPage(
      title: pack.title,
      children: [
        Text(pack.description, style: text.headlineSmall),
        const SizedBox(height: 12),
        Text('${pack.levels.length} level entries · F2 free preview play'),
        const SizedBox(height: 24),
        for (final (index, level) in pack.levels.indexed) ...[
          Card(
            child: ListTile(
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
                '${level.tiles.length} words · ${level.categories.length} groups',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
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
  }
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
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return CatalogPage(
      title: 'Level details',
      children: [
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
                Text('${level.tiles.length} words', style: text.headlineMedium),
                const SizedBox(height: 8),
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
        const Text(
          'F2 preview: all levels are available. Attempts are kept only '
          'while this app process is open. No saved progress or coin charges.',
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BoardScreen(
                controller: controller.boardFor(level),
                number: number,
              ),
            ),
          ),
          child: const Text('Play / Resume preview'),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to collection'),
        ),
      ],
    );
  }
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
