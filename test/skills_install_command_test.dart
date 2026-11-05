import 'package:devmy_cli/src/commands/skills_install_command.dart';
import 'package:test/test.dart';

void main() {
  group('buildNpxSkillsArgs', () {
    test('pins the skill to the given ref', () {
      expect(buildNpxSkillsArgs(ref: 'v1.34.0'), [
        '-y',
        'skills',
        'add',
        'https://github.com/acadevmy/devmy_cli/tree/v1.34.0/skills/devmy',
        '--skill',
        'devmy',
      ]);
    });

    test('forwards scope, agents and confirmation', () {
      expect(
        buildNpxSkillsArgs(
          ref: 'main',
          global: true,
          agents: ['claude-code', 'codex'],
          assumeYes: true,
        ).skip(6),
        ['--global', '--agent', 'claude-code', 'codex', '--yes'],
      );
    });
  });

  group('buildClaudePluginCommands', () {
    test('installs for the project by default', () {
      expect(buildClaudePluginCommands(global: false), [
        [
          'plugin', 'marketplace', 'add', 'acadevmy/devmy_cli', //
          '--scope', 'project',
        ],
        ['plugin', 'install', 'devmy@devmy', '--scope', 'project'],
      ]);
    });

    test('installs for the user with --global', () {
      expect(
        buildClaudePluginCommands(global: true).map((command) => command.last),
        ['user', 'user'],
      );
    });
  });

  group('resolveSkillsInstallMethod', () {
    test('asks when both tools are available', () {
      expect(
        resolveSkillsInstallMethod(
          npxAvailable: true,
          claudeAvailable: true,
          ask: () => SkillsInstallMethod.both,
        ),
        SkillsInstallMethod.both,
      );
    });

    test('prefers npx when it cannot ask', () {
      expect(
        resolveSkillsInstallMethod(npxAvailable: true, claudeAvailable: true),
        SkillsInstallMethod.npx,
      );
    });

    test('falls back to the available tool', () {
      expect(
        resolveSkillsInstallMethod(npxAvailable: false, claudeAvailable: true),
        SkillsInstallMethod.claude,
      );
      expect(
        resolveSkillsInstallMethod(npxAvailable: false, claudeAvailable: false),
        isNull,
      );
    });
  });
}
