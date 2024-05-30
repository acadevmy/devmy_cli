import 'package:mason/mason.dart';
import 'package:devmy_cli/src/models/workspace_command_definition.dart';

class NewCommandDefinition extends WorkspaceCommandDefinition {
  NewCommandDefinition({
    required String description,
    required GitPath brick,
  }) : super(
          description: description,
          name: 'new',
          brick: brick,
        );
}
