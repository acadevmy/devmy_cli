import 'package:devmy_cli/devmy_cli.dart';

class UtilityCommandDefinition extends BrickCommandDefinition {
  UtilityCommandDefinition({
    required super.description,
    required super.name,
    required super.brick,
    super.questions = const [],
    super.aliases = const [],
  });
}
