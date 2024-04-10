import 'dart:io';

import 'package:devmy_cli/src/models/brick_command.dart';

import 'package:devmy_cli/src/constants/constants.dart';
import 'package:mason/mason.dart';

class LibraryCommand extends BrickCommand {
  LibraryCommand({
    required super.description,
    required super.name,
    required super.brick,
  });

  @override
  Directory getWorkingDirectory({
    required Map<String, dynamic> environment,
  }) {
    if (!environment.containsKey(kBrickLibraryNameEnvironmentVariable)) {
      usageException(
        'Missing $kBrickLibraryNameEnvironmentVariable environment. Please, open an issue to support.',
      );
    }

    final String libraryName =
        environment[kBrickLibraryNameEnvironmentVariable];

    final libraryUri = Directory.current.uri.resolve(
      '$kLibraryBasePath/${libraryName.paramCase}',
    );

    final directory = Directory.fromUri(libraryUri);
    directory.createSync(
      recursive: true,
    );

    return directory;
  }
}
