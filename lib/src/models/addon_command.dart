import 'package:devmy_cli/src/models/brick_command_with_questions.dart';

class AddonCommand extends BrickCommandWithQuestions {
  AddonCommand({
    required super.name,
    required super.brick,
    required super.description,
    super.fileConflictResolution,
    super.questions = const [],
  });
}
