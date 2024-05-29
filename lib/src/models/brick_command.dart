import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chalkdart/chalk.dart';
import 'package:devmy_cli/devmy_cli.dart';
import 'package:devmy_cli/src/models/brick_context.dart';
import 'package:devmy_cli/src/utilities/utilities.dart';
import 'package:interact/interact.dart';
import 'package:mason/mason.dart';

/// This class is the basic representation of a Mason brick-based command.
/// It provides the basic functionality to load a brick,
/// retrieve the environment variables it needs and, finally, execute it.
abstract class BrickCommand extends Command<void> {
  @override
  final String name;
  @override
  final String description;
  final GitPath brick;
  final FileConflictResolution fileConflictResolution;
  @override
  final List<String> aliases;

  BrickCommand({
    required this.description,
    required this.name,
    required this.brick,
    this.fileConflictResolution = FileConflictResolution.overwrite,
    this.aliases = const [],
  });

  FutureOr<Directory> getWorkingDirectory({
    required Map<String, dynamic> environment,
  }) {
    return Directory.current;
  }

  Future<Map<String, dynamic>> loadEnvironment() async {
    return {};
  }

  FutureOr<void> promptCommandVariables(
      {required Map<String, dynamic> environment}) {}

  FutureOr<void> runBrick({
    required Directory workingDirectory,
    required BrickContext brickContext,
    required Map<String, dynamic> environment,
    required BrickCommand brickCommand,
  }) async {
    final target = DirectoryGeneratorTarget(workingDirectory);

    print('Running pre generation scripts...');
    await brickContext.generator.hooks.preGen(
      vars: environment,
      workingDirectory: workingDirectory.path,
      onVarsChanged: (nextVars) => updateEnvironment(environment, nextVars),
    );

    final generated = await brickContext.generator.generate(
      target,
      fileConflictResolution: brickCommand.fileConflictResolution,
      vars: environment,
    );

    for (final gen in generated) {
      print('${chalk.green.bold(gen.status.name.toUpperCase())} ${gen.path}');
    }

    print('Running post generation scripts...');
    await brickContext.generator.hooks.postGen(
      vars: environment,
      workingDirectory: workingDirectory.path,
    );

    await runPnpmInstall();

    await _commitChanges(
      brickCommand: brickCommand,
      environment: environment,
    );
  }

  FutureOr<BrickContext> loadBrickContext(GitPath brickPath) async {
    final spinner = Spinner(
      icon: '🧱',
      leftPrompt: (done) => '', // prompts are optional
      rightPrompt: (done) => done ? 'Assets loaded 🚀' : 'Loading assets',
    ).interact();

    try {
      final brick = await BricksJson.temp().add(
        Brick.git(brickPath),
      );

      final path = brick.path;
      final bundle = createBundle(Directory(path));

      MasonGenerator generator = await MasonGenerator.fromBundle(bundle);
      spinner.done();

      return BrickContext(bundle: bundle, generator: generator);
    } catch (e) {
      reset();
      rethrow;
    }
  }

  FutureOr<void> promptBundleVariables({
    required Map<String, dynamic> environment,
    required MasonBundle bundle,
  }) async {
    final bundleEntries = bundle.vars.entries;

    // Excluding already acquired environment variables
    final questions = bundleEntries
        .where((entry) => !environment.containsKey(entry.key))
        .toList(growable: false);

    for (final question in questions) {
      environment[question.key] = question.value.input();
    }
  }

  void updateEnvironment(
    Map<String, dynamic> environment,
    Map<String, dynamic> updates,
  ) {
    for (final entry in updates.entries) {
      environment.update(entry.key, (_) => entry.value);
    }
  }

  String getCommitMessage({
    required Map<String, dynamic> environment,
    required BrickCommand brickCommand,
  });

  Future<void> runPnpmInstall() async {
    print('📦 Running pnpm i');
    try {
      await Process.run('pnpm', ['i']);
      print(chalk.green('📦 pnpm configured successfully 🚀'));
    } catch (_) {
      print(chalk.yellowBright('⚠️ failed pnpm i'));
    }
  }

  Future<void> _commitChanges({
    required Map<String, dynamic> environment,
    required BrickCommand brickCommand,
  }) async {
    print('📚 Staging initial files...');
    Directory cwd = Directory.current;
    String? workspaceName = environment[kBrickWorkspaceNameEnvironmentVariable];
    
    if (workspaceName != null) {
      cwd = Directory.fromUri(cwd.uri.resolve(workspaceName.paramCase));
    }

    await Process.run(
      'git',
      ['add', '.'],
      workingDirectory: cwd.path,
    );

    final commitMessage = brickCommand.getCommitMessage(
      environment: environment,
      brickCommand: brickCommand,
    );

    print(
      '📚 Committing "$commitMessage"...',
    );

    await Process.run(
      'git',
      ['commit', '-m', '"$commitMessage"'],
    );

    print(chalk.green('📚 Git commited successfully! 🚀'));
  }
}
