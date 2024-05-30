import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chalkdart/chalk.dart';
import 'package:devmy_cli/src/constants/constants.dart';
import 'package:interact/interact.dart';
import 'package:mason/mason.dart';

import '../models/models.dart';
import '../utilities/process.dart';
import '../utilities/utilities.dart';
import 'brick_context.dart';

class BrickCommand extends Command<void> {
  static final String _workspaceDescriptor = 'pnpm-workspace.yaml';
  BrickCommandDefinition brickCommand;
  List<AddonCommandDefinition> addons;

  BrickCommand({
    required this.brickCommand,
    required this.addons,
  });

  @override
  String get description => brickCommand.description;

  @override
  String get name => chalk.bold(brickCommand.name);

  @override
  List<String> get aliases => [...brickCommand.aliases, brickCommand.name];

  @override
  Future<void> run() async {
    final brickCommand = this.brickCommand;
    final Directory currentWorkingDirectory = Directory.current;

    if (brickCommand is WorkspaceCommandDefinition) {
      return _runWorkspaceBrick(brickCommand);
    }

    final Directory workspaceDirectory =
        _searchWorkspaceDirectory(currentWorkingDirectory);

    if (brickCommand is ApplicationCommandDefinition) {
      return _runApplicationBrick(workspaceDirectory, brickCommand);
    }

    if (brickCommand is LibraryCommandDefinition) {
      return _runLibraryBrick(workspaceDirectory, brickCommand);
    }

    if (brickCommand is AddonCommandDefinition) {
      return _runAddonBrick(
          brickCommand, workspaceDirectory, currentWorkingDirectory);
    }
  }

  Future<void> _runWorkspaceBrick(
    WorkspaceCommandDefinition brickCommand,
  ) async {
    final workspaceName = Input(
      prompt: 'What is the name of the workspace?',
      validator: InteractValidators.isNotBlank,
    ).interact();

    final Directory workspaceDirectory = Directory.fromUri(
        Directory.current.uri.resolve(workspaceName.paramCase));
    workspaceDirectory.createSync(recursive: true);
    final context = await _loadBrickContext(brickCommand.brick);
    final environment = {
      kBrickWorkspaceNameEnvironmentVariable: workspaceName,
    };

    await _runBrick(
      workspaceDirectory: workspaceDirectory,
      targetDirectory: workspaceDirectory,
      brickContext: context,
      environment: environment,
      brickCommand: brickCommand,
    );

    await pnpmInstall(workspaceDirectory);
    await initializeGit(workspaceDirectory);
    await commitChanges(
      workspaceDirectory,
      'chore(${workspaceName.paramCase}): initial commit',
    );

    await _runAddons(
      workspaceDirectory: workspaceDirectory,
      addonTargetDirectory: workspaceDirectory,
      questions: brickCommand.questions,
      environment: environment,
    );

    print(chalk.green('🏛️ Scaffold initialized successfully! 🚀'));
    print('Next steps:');
    print(chalk.blueBright('  cd ${workspaceName.paramCase}'));
    print(chalk.blueBright('  pnpm run start'));
  }

  Future<void> _runApplicationBrick(
    Directory workspaceDirectory,
    ApplicationCommandDefinition brickCommand,
  ) async {
    final applicationName = Input(
      prompt: 'What is the name of the application?',
      validator: InteractValidators.isNotBlank,
    ).interact();

    final Directory applicationDirectory = Directory.fromUri(workspaceDirectory
        .uri
        .resolve('$kApplicationBasePath/${applicationName.paramCase}'));

    applicationDirectory.createSync(recursive: true);
    final context = await _loadBrickContext(brickCommand.brick);
    final Map<String, dynamic> environment = {
      kBrickApplicationNameEnvironmentVariable: applicationName
    };

    await _runBrick(
      workspaceDirectory: workspaceDirectory,
      targetDirectory: applicationDirectory,
      brickContext: context,
      environment: environment,
      brickCommand: brickCommand,
    );

    await pnpmInstall(workspaceDirectory);
    await commitChanges(
      workspaceDirectory,
      'chore(${applicationName.paramCase}): initial scaffold',
    );

    await _runAddons(
      workspaceDirectory: workspaceDirectory,
      addonTargetDirectory: applicationDirectory,
      questions: brickCommand.questions,
      environment: environment,
    );
  }

  Future<void> _runLibraryBrick(Directory workspaceDirectory,
      LibraryCommandDefinition brickCommand) async {
    final libraryName = Input(
      prompt: 'What is the name of the library?',
      validator: InteractValidators.isNotBlank,
    ).interact();

    final Directory libraryDirectory = Directory.fromUri(workspaceDirectory.uri
        .resolve('$kLibraryBasePath/${libraryName.paramCase}'));

    libraryDirectory.createSync(recursive: true);
    final context = await _loadBrickContext(brickCommand.brick);
    final Map<String, dynamic> environment = {
      kBrickLibraryNameEnvironmentVariable: libraryName
    };

    await _runBrick(
      workspaceDirectory: workspaceDirectory,
      targetDirectory: libraryDirectory,
      brickContext: context,
      environment: environment,
      brickCommand: brickCommand,
    );

    await pnpmInstall(workspaceDirectory);
    await commitChanges(
      workspaceDirectory,
      'chore(${libraryName.paramCase}): initial scaffold',
    );

    await _runAddons(
      workspaceDirectory: workspaceDirectory,
      addonTargetDirectory: libraryDirectory,
      questions: brickCommand.questions,
      environment: environment,
    );
  }

  Future<void> _runAddonBrick(
    AddonCommandDefinition brickCommand,
    Directory workspaceDirectory,
    Directory currentWorkingDirectory,
  ) async {
    final context = await _loadBrickContext(brickCommand.brick);
    final Map<String, dynamic> environment = {};
    final addonTarget = _askAddonTarget(workspaceDirectory);
    String targetName = getPackageName(addonTarget);

    await _runBrick(
      workspaceDirectory: workspaceDirectory,
      targetDirectory: addonTarget,
      brickContext: context,
      environment: environment,
      brickCommand: brickCommand,
    );

    await pnpmInstall(workspaceDirectory);
    await commitChanges(
      workspaceDirectory,
      'chore($targetName): applied ${brickCommand.name}',
    );

    await _runAddons(
      workspaceDirectory: workspaceDirectory,
      addonTargetDirectory: currentWorkingDirectory,
      questions: brickCommand.questions,
      environment: environment,
    );
  }

  Future<void> _runBrick({
    required Directory workspaceDirectory,
    required Directory targetDirectory,
    required BrickContext brickContext,
    required Map<String, dynamic> environment,
    required BrickCommandDefinition brickCommand,
  }) async {
    final target = DirectoryGeneratorTarget(targetDirectory);

    _promptBundleVariables(
      bundle: brickContext.bundle,
      environment: environment,
    );

    print('Running pre generation scripts...\n');
    await brickContext.generator.hooks.preGen(
      vars: environment,
      workingDirectory: targetDirectory.path,
      onVarsChanged: (nextVars) => _updateEnvironment(environment, nextVars),
    );

    final generated = await brickContext.generator.generate(
      target,
      fileConflictResolution: brickCommand.fileConflictResolution,
      vars: environment,
    );

    for (final gen in generated) {
      print('${chalk.green.bold(gen.status.name.toUpperCase())} ${gen.path}');
    }

    print('\nRunning post generation scripts...\n');
    await brickContext.generator.hooks.postGen(
      vars: environment,
      workingDirectory: targetDirectory.path,
    );
  }

  FutureOr<void> _promptBundleVariables({
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

  void _updateEnvironment(
    Map<String, dynamic> environment,
    Map<String, dynamic> updates,
  ) {
    for (final entry in updates.entries) {
      environment.update(entry.key, (_) => entry.value);
    }
  }

  Future<BrickContext> _loadBrickContext(GitPath brickPath) async {
    final spinner = Spinner(
      icon: '🧱',
      leftPrompt: (done) => '',
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

  Future<void> _runAddons({
    required Directory workspaceDirectory,
    required Directory addonTargetDirectory,
    required List<Question> questions,
    required Map<String, dynamic> environment,
  }) async {
    for (final question in questions) {
      final commands = _inputConfigurationsFromDependencies(question);
      for (final command in commands) {
        final commandEnvironment = {...environment};

        await _runBrick(
          workspaceDirectory: workspaceDirectory,
          targetDirectory: addonTargetDirectory,
          brickContext: await _loadBrickContext(command.brick),
          environment: commandEnvironment,
          brickCommand: command,
        );

        await pnpmInstall(workspaceDirectory);
        await commitChanges(
          workspaceDirectory,
          'chore: applied ${command.name}',
        );

        _runAddons(
          workspaceDirectory: workspaceDirectory,
          addonTargetDirectory: addonTargetDirectory,
          questions: command.questions,
          environment: commandEnvironment,
        );
      }
    }
  }

  List<AddonCommandDefinition> _inputConfigurationsFromDependencies(
      Question question) {
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

  Directory _searchWorkspaceDirectory(Directory workingDirectory) {
    Directory cursor = workingDirectory;

    while (
        !File.fromUri(cursor.uri.resolve(_workspaceDescriptor)).existsSync()) {
      if (cursor.path == cursor.parent.path) {
        throw Exception(
          'the command is not executed within a devmy project. Maybe you should get a coffee break ☕️',
        );
      }
      cursor = cursor.parent;
    }

    return cursor;
  }

  List<Directory> _getProjectDirectories(Directory workspaceDirectory) {
    final applications =
        Directory.fromUri(workspaceDirectory.uri.resolve(kApplicationBasePath))
            .listSync()
            .whereType<Directory>()
            .toList();

    final libraries =
        Directory.fromUri(workspaceDirectory.uri.resolve(kLibraryBasePath))
            .listSync()
            .whereType<Directory>()
            .toList();

    return [workspaceDirectory, ...libraries, ...applications];
  }

  Directory _askAddonTarget(Directory workspaceDirectory) {
    final targets = _getProjectDirectories(workspaceDirectory);
    final options = targets.map((t) => getPackageName(t)).toList();

    final selected = Select(
      prompt: 'where do you want to apply this addon?',
      options: options,
    ).interact();

    return targets[selected];
  }

  String getPackageName(Directory directory) {
    final packagePath = directory.uri.resolve('package.json').path;
    final rawPackage = File(packagePath).readAsStringSync();
    final package = jsonDecode(rawPackage);
    final String name = package['name'];

    if (name.isEmpty) {
      throw Exception('Package name not provided in $packagePath');
    }

    return package['name'];
  }
}
