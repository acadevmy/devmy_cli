import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:devmy_cli/src/commands/brick_command.dart';
import 'package:devmy_cli/src/commands/docs_command.dart';
import 'package:devmy_cli/src/commands/node_command.dart';
import 'package:devmy_cli/src/commands/skills_install_command.dart';
import 'package:devmy_cli/src/models/models.dart';
import 'package:devmy_cli/src/version.dart';

class DevmyCommandRunner extends CommandRunner<void> {
  DevmyCommandRunner()
      : super(
          "devmy",
          "Devmy project CLI for heroes",
          suggestionDistanceLimit: 3,
        ) {
    argParser.addFlag(
      'version',
      negatable: false,
      help: 'Print the installed devmy version.',
    );
  }

  @override
  Future<void> runCommand(ArgResults topLevelResults) async {
    if (topLevelResults['version'] == true) {
      print(packageVersion);
      return;
    }

    return super.runCommand(topLevelResults);
  }
}

class CommandRunnerFactory {
  CommandRunner<void> create(CliConfiguration configuration) {
    final commandRunner = DevmyCommandRunner();

    return commandRunner
      ..addCommand(DocsCommand())
      ..addCommand(
        BrickCommand(
          brickCommand: configuration.new$,
          addons: configuration.addons,
        ),
      )
      ..addCommand(NodeCommand(
        name: 'utilities',
        description: 'Devmy cli Utilities',
        children: configuration.utilities
            .map(
              (utility) => BrickCommand(
                brickCommand: utility,
                addons: configuration.addons,
              ),
            )
            .toList(),
      ))
      ..addCommand(_createGenerateSection(configuration))
      ..addCommand(NodeCommand(
        name: 'skills',
        description: 'Skills that teach AI coding agents to use devmy',
        children: [SkillsInstallCommand()],
      ));
  }

  Command<void> _createGenerateSection(CliConfiguration configuration) {
    final addons = configuration.addons;

    final applicationCommands = configuration.applications
        .map((brickCommandDefinition) =>
            BrickCommand(brickCommand: brickCommandDefinition, addons: addons))
        .toList();

    final libraryCommands = configuration.libraries
        .map((brickCommandDefinition) =>
            BrickCommand(brickCommand: brickCommandDefinition, addons: addons))
        .toList();

    final addonCommands = configuration.addons
        .map((brickCommandDefinition) =>
            BrickCommand(brickCommand: brickCommandDefinition, addons: addons))
        .toList();

    return NodeCommand(
        name: 'generate',
        aliases: ['g', 'gen'],
        description:
            "Generate various components to kickstart your development journey",
        children: [
          NodeCommand(
            name: 'application',
            aliases: ['a', 'app'],
            description: "Create a workspace application",
            children: applicationCommands,
          ),
          NodeCommand(
            name: 'library',
            aliases: ['l', 'lib'],
            description: "Create a workspace shareable library",
            children: libraryCommands,
          ),
          NodeCommand(
            name: 'addon',
            description: "Integrate addons into your projects",
            children: addonCommands,
          ),
        ]);
  }
}
