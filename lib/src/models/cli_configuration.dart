import 'package:devmy_cli/src/models/addon_command.dart';
import 'package:devmy_cli/src/models/application_command.dart';
import 'package:devmy_cli/src/models/library_command.dart';
import 'package:devmy_cli/src/models/new_command.dart';

class CliConfiguration {
  final List<ApplicationCommand> applications;
  final List<LibraryCommand> libraries;
  final List<AddonCommand> addons;
  final NewCommand new$;

  const CliConfiguration({
    this.applications = const [],
    this.libraries = const [],
    this.addons = const [],
    required this.new$,
  });
}
