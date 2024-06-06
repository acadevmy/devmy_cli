import 'package:args/command_runner.dart';
import 'package:chalkdart/chalkstrings.dart';
import 'package:devmy_cli/src/commands/brick_command.dart';
import 'package:devmy_cli/src/commands/node_command.dart';
import 'package:devmy_cli/src/models/models.dart';

class CommandRunnerFactory {
  CommandRunner<void> create(CliConfiguration configuration) {
    final commandRunner = CommandRunner<void>(
      "devmy",
      "Devmy project CLI for heroes",
      suggestionDistanceLimit: 3,
    );

    commandRunner.addCommand(
      BrickCommand(
        brickCommand: configuration.new$,
        addons: configuration.addons,
      ),
    );
    commandRunner.addCommand(NodeCommand(
      name: 'utilities',
      description: 'Devmy cli Utilities',
      children: configuration.utilities
          .map((utility) =>
              BrickCommand(brickCommand: utility, addons: configuration.addons))
          .toList(),
    ));

    commandRunner.addCommand(_createGenerateSection(configuration));

    return commandRunner;
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
        name: chalk.bold('generate'),
        aliases: ['g', 'gen', 'generate'],
        description:
            "Generate various components to kickstart your development journey",
        children: [
          NodeCommand(
            name: chalk.bold('application'),
            aliases: ['a', 'app'],
            description: "Create a workspace application",
            children: applicationCommands,
          ),
          NodeCommand(
            name: chalk.bold('library'),
            aliases: ['l', 'lib'],
            description: "Create a workspace shareable library",
            children: libraryCommands,
          ),
          NodeCommand(
            name: chalk.bold('addon'),
            description: "Integrate addons into your projects",
            children: addonCommands,
          ),
        ]);
  }
}
