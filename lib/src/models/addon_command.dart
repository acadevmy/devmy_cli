import 'package:devmy_cli/src/models/brick_command.dart';
import 'package:devmy_cli/src/models/brick_command_with_questions.dart';
import 'package:mason/mason.dart';

import '../constants/brick_variables.dart';

class AddonCommand extends BrickCommandWithQuestions {
  AddonCommand({
    required super.name,
    required super.brick,
    required super.description,
    super.fileConflictResolution,
    super.questions = const [],
    super.aliases = const [],
  });

  @override
  String getCommitMessage({
    required Map<String, dynamic> environment,
    required BrickCommand brickCommand,
  }) {
    String name = '';
    if (environment.containsKey(kBrickApplicationNameEnvironmentVariable)) {
      name = (environment[kBrickApplicationNameEnvironmentVariable] as String)
          .paramCase;
    }

    if (environment.containsKey(kBrickWorkspaceNameEnvironmentVariable)) {
      name = (environment[kBrickWorkspaceNameEnvironmentVariable] as String)
          .paramCase;
    }

    if (environment.containsKey(kBrickLibraryNameEnvironmentVariable)) {
      name = (environment[kBrickLibraryNameEnvironmentVariable] as String)
          .paramCase;
    }

    if (name.isEmpty) {
      throw UnimplementedError(
        'invalid command to run an addon: missing brick environment name',
      );
    }

    return 'chore($name): added ${brickCommand.name}';
  }
}
