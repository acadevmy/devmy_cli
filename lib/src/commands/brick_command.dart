import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chalkdart/chalk.dart';
import 'package:devmy_cli/src/constants/constants.dart';
import 'package:devmy_cli/src/models/utility_command_definition.dart';
import 'package:interact/interact.dart';
import 'package:mason/mason.dart';

import '../models/models.dart';
import '../utilities/process.dart';
import '../utilities/utilities.dart';
import 'brick_context.dart';

class BrickCommand extends Command<void> {
  static final String _workspaceDescriptor = 'pnpm-workspace.yaml';

  /// Passed to brick hooks so they can skip their own prompts.
  static const String _nonInteractiveVariable = 'devmyNonInteractive';

  BrickCommandDefinition brickCommand;
  List<AddonCommandDefinition> addons;
  final Map<String, BrickContext> _brickContexts = {};
  BrickInputs _inputs = const BrickInputs();

  BrickCommand({
    required this.brickCommand,
    required this.addons,
  }) {
    final nameSubject = _nameSubject;
    if (nameSubject != null) {
      argParser.addOption(
        'name',
        help: 'Name of the $nameSubject.',
      );
    }

    if (brickCommand is AddonCommandDefinition) {
      argParser.addOption(
        'target',
        help: 'package.json name of the workspace project to apply the addon '
            'to.',
      );
    }

    final addonNames = _reachableAddonNames(brickCommand.questions, {});
    if (addonNames.isNotEmpty) {
      argParser.addMultiOption(
        'addon',
        help: 'Addon to apply when its question comes up. Repeatable.',
        allowed: addonNames,
      );
    }

    argParser
      ..addMultiOption(
        'var',
        help: 'Brick variable as key=value. Repeatable. '
            'Run with --describe to list the variables.',
        valueHelp: 'key=value',
        splitCommas: false,
      )
      ..addFlag(
        'interactive',
        defaultsTo: true,
        help: 'Prompt for missing answers. '
            'Turned off automatically when there is no terminal.',
      )
      ..addFlag(
        'describe',
        negatable: false,
        help: 'Print the brick variables and addon questions as JSON, '
            'then exit without generating anything.',
      );
  }

  @override
  String get description => brickCommand.description;

  @override
  String get name => brickCommand.name;

  @override
  List<String> get aliases => brickCommand.aliases;

  @override
  Future<void> run() async {
    try {
      _inputs = BrickInputs.fromArgResults(
        argResults!,
        hasTerminal: hasInteractiveTerminal,
      );
    } on FormatException catch (e) {
      usageException(e.message);
    }

    if (_inputs.describe) {
      return _describe();
    }

    final brickCommand = this.brickCommand;
    final Directory currentWorkingDirectory = Directory.current;

    if (brickCommand is UtilityCommandDefinition) {
      return _runUtilityBrick(brickCommand, currentWorkingDirectory);
    }

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
    final workspaceName = _resolveName();
    final Map<String, dynamic> environment = {
      kBrickWorkspaceNameEnvironmentVariable: workspaceName,
    };
    await _preflight(environment);

    final Directory workspaceDirectory = Directory.fromUri(
        Directory.current.uri.resolve(workspaceName.paramCase));
    workspaceDirectory.createSync(recursive: true);

    await _removeIfLeftEmpty(
        workspaceDirectory,
        () async => _runBrick(
              workspaceDirectory: workspaceDirectory,
              targetDirectory: workspaceDirectory,
              brickContext: await _loadBrickContext(brickCommand.brick),
              environment: environment,
              brickCommand: brickCommand,
            ));

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
    print(chalk.blueBright('  pnpm run dev'));
  }

  Future<void> _runUtilityBrick(UtilityCommandDefinition brickCommand,
      Directory currentWorkingDirectory) async {
    await _preflight({});
    final context = await _loadBrickContext(brickCommand.brick);

    await _runBrick(
      workspaceDirectory: currentWorkingDirectory,
      targetDirectory: currentWorkingDirectory,
      brickContext: context,
      environment: {},
      brickCommand: brickCommand,
    );

    await _runAddons(
      workspaceDirectory: currentWorkingDirectory,
      addonTargetDirectory: currentWorkingDirectory,
      questions: brickCommand.questions,
      environment: {},
    );

    print(chalk.green('Utility initialized successfully! 🚀'));
  }

  Future<void> _runApplicationBrick(
    Directory workspaceDirectory,
    ApplicationCommandDefinition brickCommand,
  ) async {
    final applicationName = _resolveName();
    final Map<String, dynamic> environment = {
      kBrickApplicationNameEnvironmentVariable: applicationName
    };
    await _preflight(environment);

    final Directory applicationDirectory = Directory.fromUri(workspaceDirectory
        .uri
        .resolve('$kApplicationBasePath/${applicationName.paramCase}'));

    applicationDirectory.createSync(recursive: true);

    await _removeIfLeftEmpty(
        applicationDirectory,
        () async => _runBrick(
              workspaceDirectory: workspaceDirectory,
              targetDirectory: applicationDirectory,
              brickContext: await _loadBrickContext(brickCommand.brick),
              environment: environment,
              brickCommand: brickCommand,
            ));

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
    final libraryName = _resolveName();
    final Map<String, dynamic> environment = {
      kBrickLibraryNameEnvironmentVariable: libraryName
    };
    await _preflight(environment);

    final Directory libraryDirectory = Directory.fromUri(workspaceDirectory.uri
        .resolve('$kLibraryBasePath/${libraryName.paramCase}'));

    libraryDirectory.createSync(recursive: true);

    await _removeIfLeftEmpty(
        libraryDirectory,
        () async => _runBrick(
              workspaceDirectory: workspaceDirectory,
              targetDirectory: libraryDirectory,
              brickContext: await _loadBrickContext(brickCommand.brick),
              environment: environment,
              brickCommand: brickCommand,
            ));

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
    final addonTarget = _resolveTarget(workspaceDirectory);
    final Map<String, dynamic> environment = {};
    await _preflight(environment);

    final context = await _loadBrickContext(brickCommand.brick);
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

  /// Runs [generate] into the [directory] just created for it, and removes
  /// the directory again if the run fails before writing anything, so a
  /// failed hook does not leave an empty project behind.
  Future<void> _removeIfLeftEmpty(
    Directory directory,
    Future<void> Function() generate,
  ) async {
    try {
      await generate();
    } catch (_) {
      if (directory.existsSync() && directory.listSync().isEmpty) {
        directory.deleteSync();
      }
      rethrow;
    }
  }

  Future<void> _runBrick({
    required Directory workspaceDirectory,
    required Directory targetDirectory,
    required BrickContext brickContext,
    required Map<String, dynamic> environment,
    required BrickCommandDefinition brickCommand,
  }) async {
    final target = DirectoryGeneratorTarget(targetDirectory);

    _resolveBundleVariables(
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

  /// Fills [environment] from `--var`, then from prompts or defaults.
  /// Every `--var` is passed on, declared by the brick or not, so brick hooks
  /// can read their own extra inputs.
  void _resolveBundleVariables({
    required Map<String, dynamic> environment,
    required MasonBundle bundle,
  }) {
    for (final entry in _inputs.vars.entries) {
      final properties = bundle.vars[entry.key];
      environment[entry.key] = properties == null
          ? entry.value
          : _parseVar(entry.key, entry.value, properties);
    }

    if (!_inputs.interactive) {
      environment[_nonInteractiveVariable] = true;
    }

    final missing = <String>[];
    final questions = bundle.vars.entries
        .where((entry) => !environment.containsKey(entry.key))
        .toList(growable: false);

    for (final question in questions) {
      if (_inputs.interactive) {
        environment[question.key] = question.value.input();
      } else if (question.value.hasDefault) {
        environment[question.key] = question.value.defaultInput();
      } else {
        missing.add(_describeMissingVar(bundle, question.key, question.value));
      }
    }

    if (missing.isNotEmpty) {
      _throwMissingVars(missing);
    }
  }

  dynamic _parseVar(
    String key,
    String raw,
    BrickVariableProperties properties,
  ) {
    try {
      return properties.parse(raw);
    } on FormatException catch (e) {
      usageException('--var $key: ${e.message}');
    }
  }

  /// Without a terminal, checks every input the run will need before
  /// anything is written, so a missing answer never leaves half a scaffold.
  Future<void> _preflight(Map<String, dynamic> environment) async {
    if (_inputs.interactive) {
      return;
    }

    final bricks = [
      brickCommand,
      ..._plannedAddons(brickCommand.questions),
    ];
    final providedKeys = {...environment.keys, ..._inputs.vars.keys};
    final missing = <String>[];

    for (final brick in bricks) {
      final bundle = (await _loadBrickContext(brick.brick)).bundle;

      for (final entry in bundle.vars.entries) {
        final raw = _inputs.vars[entry.key];
        if (raw != null) {
          _parseVar(entry.key, raw, entry.value);
          continue;
        }

        if (!providedKeys.contains(entry.key) && !entry.value.hasDefault) {
          missing.add(_describeMissingVar(bundle, entry.key, entry.value));
        }
      }
    }

    if (missing.isNotEmpty) {
      _throwMissingVars(missing);
    }
  }

  List<AddonCommandDefinition> _plannedAddons(List<Question> questions) {
    return [
      for (final question in questions)
        for (final addon in _resolveAddons(question)) ...[
          addon,
          ..._plannedAddons(addon.questions),
        ],
    ];
  }

  String _describeMissingVar(
    MasonBundle bundle,
    String key,
    BrickVariableProperties properties,
  ) {
    final prompt = properties.prompt ?? properties.description ?? '';
    return '  --var $key=<${properties.type.name}>  $prompt (${bundle.name})';
  }

  Never _throwMissingVars(List<String> missing) {
    usageException(
      'Missing brick variables. Pass them with --var:\n${missing.join('\n')}',
    );
  }

  Future<void> _describe() async {
    final context = await _loadBrickContext(brickCommand.brick);
    final nameVariable = _nameVariable;

    final description = {
      'command': name,
      'description': brickCommand.description,
      'brick': brickCommand.brick.url,
      if (nameVariable != null) 'nameFlagSets': nameVariable,
      'variables': [
        for (final entry in context.bundle.vars.entries)
          {
            'name': entry.key,
            'type': entry.value.type.name,
            'prompt': entry.value.prompt,
            'description': entry.value.description,
            'default': entry.value.defaultValue,
            'defaults': entry.value.defaultValues,
            'values': entry.value.values,
            'separator': entry.value.separator,
            'required': !entry.value.hasDefault && entry.key != nameVariable,
          }..removeWhere((_, value) => value == null),
      ],
      'addonQuestions': [
        for (final question in brickCommand.questions)
          {
            'prompt': question.prompt,
            'addons': question.addonNames,
            'multiple': question.isMultiple,
            'optional': question.isOptional,
          },
      ],
    };

    print(
      JsonEncoder.withIndent('  ', (value) => '$value').convert(description),
    );
  }

  void _updateEnvironment(
    Map<String, dynamic> environment,
    Map<String, dynamic> updates,
  ) {
    for (final entry in updates.entries) {
      environment[entry.key] = entry.value;
    }
  }

  String _brickKey(GitPath brickPath) =>
      '${brickPath.url}#${brickPath.ref ?? ''}:${brickPath.path}';

  Future<BrickContext> _loadBrickContext(GitPath brickPath) async {
    final cached = _brickContexts[_brickKey(brickPath)];
    if (cached != null) {
      return cached;
    }

    final spinner = _inputs.interactive
        ? Spinner(
            icon: '🧱',
            leftPrompt: (done) => '',
            rightPrompt: (done) => done ? 'Assets loaded 🚀' : 'Loading assets',
          ).interact()
        : null;
    if (spinner == null && !_inputs.describe) {
      print('🧱 Loading ${brickPath.url}');
    }

    try {
      final brick = await BricksJson.temp().add(
        Brick.git(brickPath),
      );

      final path = brick.path;
      final bundle = createBundle(Directory(path));

      MasonGenerator generator = await MasonGenerator.fromBundle(bundle);
      spinner?.done();

      final context = BrickContext(bundle: bundle, generator: generator);
      _brickContexts[_brickKey(brickPath)] = context;
      return context;
    } catch (e) {
      if (spinner != null) {
        reset();
      }
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
      final commands = _resolveAddons(question);
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

        await _runAddons(
          workspaceDirectory: workspaceDirectory,
          addonTargetDirectory: addonTargetDirectory,
          questions: command.questions,
          environment: commandEnvironment,
        );
      }
    }
  }

  /// Answers [question] with the `--addon` values it offers; prompts only
  /// when none were passed and a terminal is available.
  List<AddonCommandDefinition> _resolveAddons(Question question) {
    final selected =
        question.addonNames.where(_inputs.addons.contains).toList();

    if (selected.isEmpty && _inputs.interactive) {
      return _inputConfigurationsFromDependencies(question);
    }

    if (!question.isMultiple && selected.length > 1) {
      usageException(
        'Only one of ${selected.join(', ')} can be chosen for '
        '"${question.prompt}"',
      );
    }

    if (selected.isEmpty && !question.isOptional) {
      usageException(
        '"${question.prompt}" needs an answer: '
        'pass --addon with one of ${question.addonNames.join(', ')}',
      );
    }

    return selected.map(_findAddon).toList(growable: false);
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
          .map(_findAddon)
          .toList(growable: false);
    }

    if (question.isOptional) {
      optionLabels.add('none');
    }

    int index = Select(
      prompt: question.prompt,
      options: optionLabels,
    ).interact();

    if (index == question.addonNames.length) {
      return [];
    }

    return [_findAddon(question.addonNames[index])];
  }

  AddonCommandDefinition _findAddon(String name) {
    return addons.singleWhere((addon) => addon.name == name);
  }

  /// Every addon this command can apply, its own questions included.
  List<String> _reachableAddonNames(
    List<Question> questions,
    Set<String> visited,
  ) {
    for (final question in questions) {
      for (final addonName in question.addonNames) {
        if (visited.add(addonName)) {
          _reachableAddonNames(_findAddon(addonName).questions, visited);
        }
      }
    }

    return visited.toList();
  }

  String? get _nameSubject {
    final brickCommand = this.brickCommand;
    if (brickCommand is WorkspaceCommandDefinition) return 'workspace';
    if (brickCommand is ApplicationCommandDefinition) return 'application';
    if (brickCommand is LibraryCommandDefinition) return 'library';
    return null;
  }

  String? get _nameVariable {
    final brickCommand = this.brickCommand;
    if (brickCommand is WorkspaceCommandDefinition) {
      return kBrickWorkspaceNameEnvironmentVariable;
    }
    if (brickCommand is ApplicationCommandDefinition) {
      return kBrickApplicationNameEnvironmentVariable;
    }
    if (brickCommand is LibraryCommandDefinition) {
      return kBrickLibraryNameEnvironmentVariable;
    }
    return null;
  }

  String _resolveName() {
    final subject = _nameSubject!;
    final name = _inputs.name;

    if (name != null) {
      if (name.trim().isEmpty) {
        usageException('--name cannot be blank');
      }
      return name;
    }

    if (!_inputs.interactive) {
      usageException('Missing --name: pass the name of the $subject.');
    }

    return Input(
      prompt: 'What is the name of the $subject?',
      validator: InteractValidators.isNotBlank,
    ).interact();
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

    return [workspaceDirectory, ...libraries, ...applications]
        .where((directory) =>
            File.fromUri(directory.uri.resolve('package.json')).existsSync())
        .toList();
  }

  Directory _resolveTarget(Directory workspaceDirectory) {
    final targets = _getProjectDirectories(workspaceDirectory);
    final options = targets.map((t) => getPackageName(t)).toList();
    final target = _inputs.target;

    if (target != null) {
      final index = options.indexOf(target);
      if (index == -1) {
        usageException(
          'Unknown --target "$target". Available: ${options.join(', ')}',
        );
      }
      return targets[index];
    }

    if (!_inputs.interactive) {
      usageException(
        'Missing --target: pass one of ${options.join(', ')}',
      );
    }

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
