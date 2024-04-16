import 'package:args/command_runner.dart';
import 'package:devmy_cli/src/commands/node_command.dart';
import 'package:devmy_cli/src/models/models.dart';

class CommandRunnerFactory {
  CommandRunner<void> create(CliConfiguration configuration) {
    final commandRunner = CommandRunner<void>(
      "devmy",
      "Devmy project CLI for heroes",
      suggestionDistanceLimit: 3,
    );

    commandRunner.addCommand(configuration.new$);
    commandRunner.addCommand(_createGenerateSection(configuration));

    return commandRunner;
  }

  Command<void> _createGenerateSection(CliConfiguration configuration) {
    for (final addon in configuration.addons) {
      addon.addons = configuration.addons;
    }
    for (final application in configuration.applications) {
      application.addons = configuration.addons;
    }

    return NodeCommand(
        name: 'generate',
        description:
            "Unlock the power to create! Generate various components of your project with ease using this versatile command. Explore options like applications, addons, presets and libraries to kickstart your development journey.",
        children: [
          NodeCommand(
            name: 'application',
            description:
                "Craft your Devmy project's foundation! Use this command to generate different types of applications, whether it's Angular, Next.js, or beyond. Seamlessly set up the backbone of your project with just a few simple commands.",
            children: configuration.applications,
          ),
          NodeCommand(
            name: 'library',
            description:
                "Empower your project with reusable components! With this command, generate libraries tailored to your project's needs. Streamline development by creating shareable components that enhance collaboration and maintainability.",
            children: configuration.libraries,
          ),
          NodeCommand(
            name: 'addon',
            description:
                "Enhance your project's capabilities! Utilize this command to seamlessly integrate addons like Themes or State Manager Scaffolds into your applications. Elevate your project with advanced functionalities without breaking a sweat.",
            children: configuration.addons,
          ),
        ]);
  }
}
