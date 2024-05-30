import 'package:devmy_cli/src/models/brick_command_definition.dart';

class LibraryCommandDefinition extends BrickCommandDefinition {
  LibraryCommandDefinition({
    required super.name,
    required super.brick,
    required super.description,
    super.fileConflictResolution,
    super.questions = const [],
    super.aliases = const [],
  });
}
