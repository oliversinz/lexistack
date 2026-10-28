import 'package:flutter/material.dart';

import '../app/progress_controller.dart';
import 'common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});
  final ProgressController controller;

  Future<void> reset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text('Reset all progress?'),
        content: const Text(
          'This deletes saved attempts, results and settings, and restores 150 coins. This cannot be undone.',
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
    if (!context.mounted || confirmed != true) return;
    controller.reset(confirmed: true);
    // Remove every stale route as well as invalidating its controller handle.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => CatalogPage(
      title: 'Settings',
      children: [
        Text(
          'Make yourself at home.',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final mode in ['system', 'light', 'dark'])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Semantics(
                    selected: controller.state.theme == mode,
                    child: OutlinedButton(
                      key: ValueKey('theme-$mode'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 2,
                        ),
                        backgroundColor: controller.state.theme == mode
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        side: BorderSide(
                          color: controller.state.theme == mode
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      onPressed: () => controller.setSettings(theme: mode),
                      child: Column(
                        children: [
                          Icon(
                            mode == 'system'
                                ? Icons.brightness_auto_outlined
                                : mode == 'light'
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                          ),
                          const SizedBox(height: 8),
                          Text('${mode[0].toUpperCase()}${mode.substring(1)}'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('System follows your device appearance.'),
        const SizedBox(height: 24),
        InsetCard(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Haptic Feedback'),
            subtitle: const Text('A little feel for each connection.'),
            value: controller.state.haptics,
            onChanged: (value) => controller.setSettings(haptics: value),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 12),
        Text(
          'Saved on this device',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Your progress and settings stay offline in this app’s local storage. There is no account or cloud backup. Clearing app data or uninstalling removes them.',
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => reset(context),
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset progress'),
        ),
      ],
    ),
  );
}
