import 'dart:async';
import 'dart:io';

import 'package:devmy_cli/src/models/question.dart';
import 'package:interact/interact.dart';

import 'package:devmy_cli/src/models/addon_command.dart';
import 'package:devmy_cli/src/models/brick_command.dart';

import 'brick_context.dart';

abstract class BrickCommandWithQuestions extends BrickCommand {
  final List<Question> questions;
  late List<AddonCommand> addons;

  BrickCommandWithQuestions({
    required super.brick,
    required super.description,
    required super.name,
    super.fileConflictResolution,
    required this.questions,
  });

  @override
  FutureOr<void> runBrick({
    required Directory workingDirectory,
    required BrickContext brickContext,
    required Map<String, dynamic> environment,
    required BrickCommand brickCommand,
  }) async {
    await super.runBrick(
      workingDirectory: workingDirectory,
      brickContext: brickContext,
      environment: environment,
      brickCommand: brickCommand,
    );

    await runQuestions(
      workingDirectory: workingDirectory,
      brickContext: brickContext,
      environment: environment,
      brickCommand: brickCommand,
    );
  }

  Future<void> runQuestions({
    required Directory workingDirectory,
    required BrickContext brickContext,
    required Map<String, dynamic> environment,
    required BrickCommand brickCommand,
  }) async {
    if (brickCommand is! BrickCommandWithQuestions) {
      return;
    }

    for (final question in brickCommand.questions) {
      final commands = _inputConfigurationsFromDependencies(question);
      for (final command in commands) {
        await runBrick(
          workingDirectory: workingDirectory,
          brickContext: await loadBrickContext(command.brick),
          environment: environment,
          brickCommand: command,
        );
      }
    }
  }

  List<AddonCommand> _inputConfigurationsFromDependencies(Question question) {
    final optionLabels = [...question.addonNames];
    if (question.isMultiple) {
      final selections = MultiSelect(
        prompt: question.prompt,
        options: optionLabels,
      ).interact();
      return selections
          .map((index) => optionLabels[index])
          .map((name) => addons.singleWhere((addon) => addon.name == name))
          .toList(growable: false);
    }

    if (question.isOptional) {
      optionLabels.insert(0, 'none');
    }

    int index = Select(
      prompt: question.prompt,
      options: optionLabels,
    ).interact();

    if (question.isOptional) {
      index--;
    }

    if (index == -1) {
      return [];
    }

    return addons
        .where((addon) => addon.name == question.addonNames[index])
        .toList();
  }

  List<AddonCommand> askMultiSelect(Question question) {
    final selections = MultiSelect(
      prompt: question.prompt,
      options: question.addonNames,
    ).interact();
    return selections
        .map((index) => question.addonNames[index])
        .map((name) => addons.singleWhere((addon) => addon.name == name))
        .toList(growable: false);
  }

  List<AddonCommand> askRequiredSelect(Question question) {
    int index = Select(
      prompt: question.prompt,
      options: question.addonNames,
    ).interact();
    final addonName = question.addonNames[index];

    return addons.where((addon) => addon.name == addonName).toList();
  }

  List<AddonCommand> askOptionalSelect(Question question) {
    int index = Select(
      prompt: question.prompt,
      options: ['none', ...question.addonNames],
    ).interact();

    if (index == 0) {
      return [];
    }

    final addonName = question.addonNames[index - 1];

    return addons.where((addon) => addon.name == addonName).toList();
  }
}
