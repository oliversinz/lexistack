import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/catalog_controller.dart';
import '../app/storage.dart';
import '../core/daily.dart';
import '../infrastructure/asset_catalog.dart';
import '../infrastructure/preferences_storage.dart';
import 'catalog_screens.dart';
import 'theme.dart';

class LexiStackApp extends StatefulWidget {
  const LexiStackApp({super.key, this.bundle, this.storage, this.clock});

  final AssetBundle? bundle;
  final ProgressStorage? storage;
  final LocalClock? clock;

  @override
  State<LexiStackApp> createState() => _LexiStackAppState();
}

class _LexiStackAppState extends State<LexiStackApp>
    with WidgetsBindingObserver {
  late final controller = CatalogController(
    loadCatalog: () => loadAssetCatalog(widget.bundle ?? rootBundle),
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
  Widget build(BuildContext context) => MaterialApp(
    title: 'LexiStack',
    debugShowCheckedModeBanner: false,
    theme: lexistackTheme(),
    home: HomeScreen(controller: controller),
  );
}
