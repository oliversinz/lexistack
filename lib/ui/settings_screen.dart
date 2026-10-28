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
        for (final mode in ['system', 'light', 'dark'])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              selected: controller.state.theme == mode,
              child: OutlinedButton.icon(
                key: ValueKey('theme-$mode'),
                onPressed: () => controller.setSettings(theme: mode),
                icon: Icon(
                  controller.state.theme == mode
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                label: Text('${mode[0].toUpperCase()}${mode.substring(1)}'),
              ),
            ),
          ),
        const Text('System follows your device appearance.'),
        const SizedBox(height: 24),
        Card(
          child: SwitchListTile(
            title: const Text('Haptic Feedback'),
            subtitle: const Text('A little feel for each connection.'),
            value: controller.state.haptics,
            onChanged: (value) => controller.setSettings(haptics: value),
          ),
        ),
        const SizedBox(height: 28),
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
