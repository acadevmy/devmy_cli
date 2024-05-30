import 'brick_command_definition.dart';

class ApplicationCommandDefinition extends BrickCommandDefinition {
  ApplicationCommandDefinition({
    required super.name,
    required super.brick,
    required super.description,
    super.questions = const [],
    super.aliases = const [],
  });
}
