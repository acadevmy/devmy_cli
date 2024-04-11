import 'dart:async';
import 'dart:io';

import 'package:mason/mason.dart';

import 'package:devmy_cli/src/models/brick_command.dart';

import 'package:devmy_cli/src/constants/constants.dart';

class NewCommand extends BrickCommand {
  NewCommand({
    required String description,
    required GitPath brick,
  }) : super(
          description: description,
          name: 'new',
          brick: brick,
        );

  @override
  FutureOr<Directory> getWorkingDirectory({
    required Map<String, dynamic> environment,
  }) {
    if (!environment.containsKey(kBrickWorkspaceNameEnvironmentVariable)) {
      usageException(
        'Missing $kBrickWorkspaceNameEnvironmentVariable environment. Please, open an issue to support.',
      );
    }

    final String workspaceName =
        environment[kBrickWorkspaceNameEnvironmentVariable];

    final workspaceUri = Directory.current.uri.resolve(workspaceName.paramCase);

    final directory = Directory.fromUri(workspaceUri);
    directory.createSync(
      recursive: true,
    );

    return directory;
  }
}
