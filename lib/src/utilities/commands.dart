import 'package:args/command_runner.dart';

extension CommandExtension<T> on Command<T> {
  void addSubcommands(List<Command<T>> commands) {
    for (final command in commands) {
      addSubcommand(command);
    }
  }
}
