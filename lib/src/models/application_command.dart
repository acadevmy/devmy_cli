import 'dart:io';
import 'package:devmy_cli/src/models/brick_command_with_questions.dart';
import 'package:mason/mason.dart';

import 'package:devmy_cli/src/constants/constants.dart';

class ApplicationCommand extends BrickCommandWithQuestions {
  ApplicationCommand(
      {required super.name,
      required super.brick,
      required super.description,
      super.questions = const [],
      super.aliases = const []});

  @override
  Directory getWorkingDirectory({
    required Map<String, dynamic> environment,
  }) {
    if (!environment.containsKey(kBrickApplicationNameEnvironmentVariable)) {
      usageException(
        'Missing $kBrickApplicationNameEnvironmentVariable environment. Please, open an issue to support.',
      );
    }

    final String applicationName =
        environment[kBrickApplicationNameEnvironmentVariable];

    final applicationUri = Directory.current.uri.resolve(
      '$kApplicationBasePath/${applicationName.paramCase}',
    );

    final directory = Directory.fromUri(applicationUri);
    directory.createSync(
      recursive: true,
    );

    return directory;
  }
}
