import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:devmy_cli/src/utilities/utilities.dart';

class NodeCommand extends Command<void> {
  @override
  final String name;

  @override
  final String description;

  @override
  final List<String> aliases;

  NodeCommand({
    required this.name,
    required this.description,
    this.aliases = const [],
    List<Command<void>> children = const [],
  }) {
    addSubcommands(children);
  }

  @override
  FutureOr<void> run() {
    if (subcommands.isEmpty) {
      usageException(
        "It looks like there are no $name commands available at the moment, but don't worry! We're working on adding new features. Stay tuned for the latest news and updates!",
      );
    }

    usageException(
      "It looks like you've stumbled upon an intermediate command! Don't worry, just use the --help command to explore the available subcommands and continue your journey.",
    );
  }
}
