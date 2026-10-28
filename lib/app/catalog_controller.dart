import 'package:flutter/foundation.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

import '../core/daily.dart';
import 'board_controller.dart';
import 'progress.dart';
import 'progress_controller.dart';
import 'storage.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({
    required this.loadCatalog,
    required this.storage,
    required this.clock,
  });

  final Future<ValidationReport> Function() loadCatalog;
  final ProgressStorage storage;
  final LocalClock clock;
  ProgressController? progress;
  ValidationReport? report;
  String? error;
  bool loading = false;
  bool _disposed = false;
  BoardController boardFor(Attempt attempt) =>
      BoardController(progress!, attempt);

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
      if (loaded.isValid && progress == null) {
        final player = ProgressController(
          catalog: loaded.catalog!,
          storage: storage,
          clock: clock,
        );
        await player.load();
        if (_disposed) {
          player.dispose();
          return;
        }
        progress = player;
        player.addListener(notifyListeners);
      }
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
    progress?.removeListener(notifyListeners);
    progress?.dispose();
    super.dispose();
  }
}
