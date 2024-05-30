import 'brick_command_definition.dart';

class AddonCommandDefinition extends BrickCommandDefinition {
  AddonCommandDefinition({
    required super.name,
    required super.brick,
    required super.description,
    super.fileConflictResolution,
    super.questions = const [],
    super.aliases = const [],
  });
}
