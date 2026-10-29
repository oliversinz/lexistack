import 'dart:io';

import 'package:lexistack_content_contract/lexistack_content_contract.dart';

String installedManifest() =>
    File('assets/levels/manifest.json').readAsStringSync();

Map<String, String> installedFiles() => {
  for (final name in parseManifest(installedManifest()).value!.files)
    name: File('assets/levels/$name').readAsStringSync(),
};

Catalog installedCatalog() => validateCatalog(
  manifestContents: installedManifest(),
  files: installedFiles(),
).catalog!;
