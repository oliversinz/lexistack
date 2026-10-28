import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/catalog_controller.dart';
import '../infrastructure/asset_catalog.dart';
import 'catalog_screens.dart';
import 'theme.dart';

class LexiStackApp extends StatefulWidget {
  const LexiStackApp({super.key, this.bundle});

  final AssetBundle? bundle;

  @override
  State<LexiStackApp> createState() => _LexiStackAppState();
}

class _LexiStackAppState extends State<LexiStackApp> {
  late final controller = CatalogController(
    loadCatalog: () => loadAssetCatalog(widget.bundle ?? rootBundle),
  )..load();

  @override
  void dispose() {
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
