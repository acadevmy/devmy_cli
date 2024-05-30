import 'package:devmy_cli/src/models/addon_command_definition.dart';
import 'package:devmy_cli/src/models/application_command_definition.dart';
import 'package:devmy_cli/src/models/library_command_definition.dart';
import 'package:devmy_cli/src/models/new_definition.dart';

class CliConfiguration {
  final List<ApplicationCommandDefinition> applications;
  final List<LibraryCommandDefinition> libraries;
  final List<AddonCommandDefinition> addons;
  final NewCommandDefinition new$;

  const CliConfiguration({
    this.applications = const [],
    this.libraries = const [],
    this.addons = const [],
    required this.new$,
  });
}
