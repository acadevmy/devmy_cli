import 'dart:io';

import 'package:devmy_cli/devmy_cli.dart';

/// Writes the command catalog of the `devmy` skill. Run from the repository
/// root with `make skill_reference`.
void main() {
  File(kCommandsReferencePath)
      .writeAsStringSync(renderCommandsReference(cliConfiguration));
  print('Updated $kCommandsReferencePath');
}
