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
  print(banner);
  try {
    await CommandRunnerFactory().create(cliConfiguration).run(arguments);
  } catch (e) {
    reset();
    print(chalk.red.bold('Oops! Something went wrong! 😵‍💫'));
    print(e);
  }
}
