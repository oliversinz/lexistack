import 'dart:io';

import 'package:lexistack_content_contract/cli.dart';

Future<void> main(List<String> arguments) async {
  exitCode = await runValidatorCli(arguments);
}
