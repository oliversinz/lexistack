import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../app/catalog_controller.dart';
import '../app/storage.dart';
import '../core/daily.dart';
import '../infrastructure/asset_catalog.dart';
import '../infrastructure/preferences_storage.dart';
import 'home_screen.dart';
import 'theme.dart';

class LexiStackApp extends StatefulWidget {
  const LexiStackApp({
    super.key,
    this.bundle,
    this.storage,
    this.clock,
    this.loadCatalog,
  });

  final AssetBundle? bundle;
  final ProgressStorage? storage;
  final LocalClock? clock;
  final Future<ValidationReport> Function()? loadCatalog;

  @override
  State<LexiStackApp> createState() => _LexiStackAppState();
}

class _LexiStackAppState extends State<LexiStackApp>
    with WidgetsBindingObserver {
  late final controller = CatalogController(
    loadCatalog:
        widget.loadCatalog ??
        () => loadAssetCatalog(widget.bundle ?? rootBundle),
    storage: widget.storage ?? PreferencesStorage(),
    clock: widget.clock ?? DateTime.now,
  )..load();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) controller.progress?.refreshDay();
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      controller.progress?.flush();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => MaterialApp(
      title: 'LexiStack',
      debugShowCheckedModeBanner: false,
      theme: lexistackTheme(),
      darkTheme: lexistackTheme(brightness: Brightness.dark),
      themeMode: switch (controller.progress?.state.theme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      builder: (context, child) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainer,
        child: Center(
          child: ConstrainedBox(
            key: const Key('app-frame'),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width > 520
                  ? 460
                  : double.infinity,
            ),
            child: child,
          ),
        ),
      ),
      home: HomeScreen(controller: controller),
    ),
  );
}
