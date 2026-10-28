import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:lexistack_content_contract/lexistack_content_contract.dart';

/// Adapts bundled text to the shared contract; all content rules stay there.
Future<ValidationReport> loadAssetCatalog(AssetBundle bundle) async {
  const directory = 'assets/levels';
  Future<String> read(String path) async {
    try {
      return await bundle.loadString(path, cache: false);
    } on FlutterError catch (error) {
      throw FormatException('Cannot read bundled asset $path: $error');
    } on FormatException catch (error) {
      throw FormatException('Cannot decode bundled asset $path: $error');
    }
  }

  final manifest = await read('$directory/manifest.json');
  final parsed = parseManifest(manifest, source: '$directory/manifest.json');
  final files = <String, String>{};
  for (final filename in parsed.value?.files ?? <String>[]) {
    files[filename] = await read('$directory/$filename');
  }
  return validateCatalog(
    manifestContents: manifest,
    manifestSource: '$directory/manifest.json',
    files: files,
    mode: ValidationMode.partial,
  );
}
