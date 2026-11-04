import 'dart:io';

import 'package:chalkdart/chalk.dart';

/// True when both stdin and stdout are attached to a terminal, so prompts
/// can be shown and answered. AI agents and CI run without one.
bool get hasInteractiveTerminal => stdin.hasTerminal && stdout.hasTerminal;

/// Disables ANSI colors when the output is not a terminal or `NO_COLOR` is
/// set. Must run before the first `chalk` usage: chalk instances read the
/// color level when they are created.
void configureTerminalOutput() {
  if (!stdout.hasTerminal || Platform.environment.containsKey('NO_COLOR')) {
    Chalk.ansiColorLevelForNewInstances = 0;
  }
}
