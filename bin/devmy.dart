import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chalkdart/chalk.dart';
import 'package:devmy_cli/devmy_cli.dart';
import 'package:interact/interact.dart';

final banner = r'''
     ____
    |  _ \   ___ __   __ _ __ ___   _   _
    | | | | / _ \\ \ / /| '_ ` _ \ | | | |
  _ | |_| ||  __/ \ V / | | | | | || |_| |
 (_)|____/  \___|  \_/  |_| |_| |_| \__, |
                                    |___/
''';

void main(List<String> arguments) async {
  configureTerminalOutput();

  if (stdout.hasTerminal && !arguments.contains('--describe')) {
    print(banner);
  }

  try {
    await CommandRunnerFactory().create(cliConfiguration).run(arguments);
  } on UsageException catch (e) {
    _resetTerminal();
    stderr.writeln(chalk.red.bold(e.message));
    stderr.writeln();
    stderr.writeln(e.usage);
    exitCode = 64;
  } catch (e) {
    _resetTerminal();
    stderr.writeln(chalk.red.bold('Oops! Something went wrong! 😵‍💫'));
    stderr.writeln(e);
    exitCode = 1;
  }
}

void _resetTerminal() {
  if (hasInteractiveTerminal) {
    reset();
  }
}
