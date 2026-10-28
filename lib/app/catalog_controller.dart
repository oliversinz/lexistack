import 'package:flutter/foundation.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../core/game.dart';
import 'board_controller.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({required this.loadCatalog});

  final Future<ValidationReport> Function() loadCatalog;
  ValidationReport? report;
  String? error;
  bool loading = false;
  bool _disposed = false;
  final Map<String, BoardController> _attempts = {};

  BoardController boardFor(Level level) => _attempts.putIfAbsent(
    level.id,
    () => BoardController(Game(level, seed: 20261028)),
  );

  Future<void> load() async {
    if (loading) return;
    loading = true;
    error = null;
    report = null;
    notifyListeners();
    try {
      final loaded = await loadCatalog();
      if (_disposed) return;
      report = loaded;
      if (!loaded.isValid) error = formatReport(loaded);
    } on FormatException catch (failure) {
      if (_disposed) return;
      error = failure.message;
    }
    if (_disposed) return;
    loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final board in _attempts.values) {
      board.dispose();
    }
    super.dispose();
  }
}
