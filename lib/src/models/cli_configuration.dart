import 'package:devmy_cli/src/models/addon_command_definition.dart';
import 'package:devmy_cli/src/models/application_command_definition.dart';
import 'package:devmy_cli/src/models/library_command_definition.dart';
import 'package:devmy_cli/src/models/new_definition.dart';
import 'package:devmy_cli/src/models/utility_command_definition.dart';

class CliConfiguration {
  final List<ApplicationCommandDefinition> applications;
  final List<LibraryCommandDefinition> libraries;
  final List<AddonCommandDefinition> addons;
  final List<UtilityCommandDefinition> utilities;
  final NewCommandDefinition new$;

  const CliConfiguration({
    this.applications = const [],
    this.libraries = const [],
    this.addons = const [],
    this.utilities = const [],
    required this.new$,
  });
}
