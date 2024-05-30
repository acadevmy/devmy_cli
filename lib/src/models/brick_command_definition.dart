import 'package:mason/mason.dart';
import 'package:devmy_cli/src/models/question.dart';

/// This class is the basic representation of a Mason brick-based command.
abstract class BrickCommandDefinition {
  final String name;
  final String description;
  final GitPath brick;
  final FileConflictResolution fileConflictResolution;
  final List<String> aliases;
  final List<Question> questions;

  BrickCommandDefinition({
    required this.description,
    required this.name,
    required this.brick,
    this.fileConflictResolution = FileConflictResolution.overwrite,
    this.aliases = const [],
    this.questions = const [],
  });
}
