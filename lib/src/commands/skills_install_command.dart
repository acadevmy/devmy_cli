import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:chalkdart/chalk.dart';
import 'package:devmy_cli/src/utilities/process.dart';
import 'package:devmy_cli/src/utilities/terminal.dart';
import 'package:devmy_cli/src/version.dart';
import 'package:interact/interact.dart';

const kSkillsRepository = 'acadevmy/devmy_cli';
const kSkillName = 'devmy';
const kClaudePlugin = 'devmy@devmy';

/// `npx skills` needs at least this Node.js version.
const kSkillsCliMinimumNode = [22, 20];

enum SkillsInstallMethod {
  npx('npx skills (Claude Code, Codex, Cursor and other agents)'),
  claude('Claude Code plugin'),
  both('both');

  final String label;
  const SkillsInstallMethod(this.label);

  bool get usesNpx => this != SkillsInstallMethod.claude;
  bool get usesClaude => this != SkillsInstallMethod.npx;
}

class SkillsInstallCommand extends Command<void> {
  SkillsInstallCommand() {
    argParser
      ..addFlag(
        'global',
        abbr: 'g',
        negatable: false,
        help: 'Install for your user instead of the current project.',
      )
      ..addMultiOption(
        'agent',
        abbr: 'a',
        help: 'Agent for npx skills, e.g. claude-code, codex, cursor. '
            'Repeatable. When omitted npx skills asks, or uses the detected '
            'agents with --yes.',
      )
      ..addOption(
        'method',
        allowed: SkillsInstallMethod.values.map((method) => method.name),
        help: 'How to install. Asked when both npx and claude are available; '
            'without a terminal npx is preferred.',
      )
      ..addOption(
        'ref',
        defaultsTo: 'v$packageVersion',
        help: 'Tag or branch (without "/") of the skill installed with npx '
            'skills. Defaults to the tag of this CLI version.',
      )
      ..addFlag(
        'yes',
        abbr: 'y',
        negatable: false,
        help: 'Skip the confirmations of npx skills and claude.',
      );
  }

  @override
  String get name => 'install';

  @override
  String get description =>
      'Install the devmy skill for AI coding agents (npx skills, Claude Code '
      'plugin or both)';

  @override
  Future<void> run() async {
    final results = argResults!;
    final global = results['global'] as bool;
    final agents = results['agent'] as List<String>;
    final ref = results['ref'] as String;
    final interactive = hasInteractiveTerminal && !(results['yes'] as bool);
    final requested = results['method'] == null
        ? null
        : SkillsInstallMethod.values.byName(results['method'] as String);

    final npxAvailable = await isExecutableAvailable('npx');
    final claudeAvailable = await isExecutableAvailable('claude');

    if (requested != null) {
      if (requested.usesNpx && !npxAvailable) {
        usageException('npx is not installed: install Node.js '
            '${kSkillsCliMinimumNode.join('.')} or later, or use '
            '--method claude.');
      }
      if (requested.usesClaude && !claudeAvailable) {
        usageException('claude is not installed: install Claude Code, or use '
            '--method npx.');
      }
    }

    final method = requested ??
        resolveSkillsInstallMethod(
          npxAvailable: npxAvailable,
          claudeAvailable: claudeAvailable,
          ask: interactive ? _askMethod : null,
        );

    if (method == null) {
      _printManualInstructions(ref: ref, global: global);
      throw Exception('Neither npx nor claude was found on PATH.');
    }

    if (method.usesNpx && !await _nodeSupportsSkillsCli()) {
      _printManualInstructions(ref: ref, global: global);
      throw Exception('npx skills needs Node.js '
          '${kSkillsCliMinimumNode.join('.')} or later.');
    }

    if (method == SkillsInstallMethod.both &&
        (agents.isEmpty || agents.contains('claude-code'))) {
      print(chalk.yellowBright('⚠️ The Claude Code plugin is installed too: '
          'pick other agents than Claude Code in npx skills, or the skill '
          'will be loaded twice.'));
    }

    if (method.usesNpx) {
      print('📦 npx skills add');
      final exitCode = await runInheritingStdio(
        'npx',
        buildNpxSkillsArgs(
          ref: ref,
          global: global,
          agents: agents,
          assumeYes: !interactive,
        ),
      );
      if (exitCode != 0) {
        _printManualInstructions(ref: ref, global: global);
        throw Exception('npx skills failed with exit code $exitCode.');
      }
    }

    if (method.usesClaude) {
      for (final arguments in buildClaudePluginCommands(global: global)) {
        print('🤖 claude ${arguments.join(' ')}');
        final exitCode = await runInheritingStdio('claude', arguments);
        if (exitCode != 0) {
          _printManualInstructions(ref: ref, global: global);
          throw Exception('claude failed with exit code $exitCode.');
        }
      }
    }

    print(chalk.green('✅ devmy skill installed. Restart your agent session '
        'to load it.'));
  }

  SkillsInstallMethod _askMethod() {
    final index = Select(
      prompt: 'How do you want to install the devmy skill?',
      options: SkillsInstallMethod.values.map((m) => m.label).toList(),
    ).interact();

    return SkillsInstallMethod.values[index];
  }

  Future<bool> _nodeSupportsSkillsCli() async {
    final version = await nodeVersion();
    if (version == null) {
      return false;
    }

    final [major, minor] = version;
    final [minimumMajor, minimumMinor] = kSkillsCliMinimumNode;
    return major > minimumMajor ||
        (major == minimumMajor && minor >= minimumMinor);
  }

  void _printManualInstructions({required String ref, required bool global}) {
    final npx = ['npx', ...buildNpxSkillsArgs(ref: ref, global: global)];
    print('');
    print('Install the skill by hand with one of:');
    print(chalk.blueBright('  ${npx.join(' ')}'));
    for (final arguments in buildClaudePluginCommands(global: global)) {
      print(chalk.blueBright('  claude ${arguments.join(' ')}'));
    }
    print('or, inside Claude Code:');
    print(chalk.blueBright('  /plugin marketplace add $kSkillsRepository'));
    print(chalk.blueBright('  /plugin install $kClaudePlugin'));
  }
}

/// Picks the install method when `--method` is not given: [ask] decides
/// when both tools are available, otherwise npx, which covers more agents.
SkillsInstallMethod? resolveSkillsInstallMethod({
  required bool npxAvailable,
  required bool claudeAvailable,
  SkillsInstallMethod Function()? ask,
}) {
  if (npxAvailable && claudeAvailable && ask != null) {
    return ask();
  }
  if (npxAvailable) {
    return SkillsInstallMethod.npx;
  }
  if (claudeAvailable) {
    return SkillsInstallMethod.claude;
  }
  return null;
}

/// Arguments for `npx`, pinned to [ref] so the skill matches this CLI.
List<String> buildNpxSkillsArgs({
  required String ref,
  bool global = false,
  List<String> agents = const [],
  bool assumeYes = false,
}) {
  return [
    '-y',
    'skills',
    'add',
    'https://github.com/$kSkillsRepository/tree/$ref/skills/$kSkillName',
    '--skill',
    kSkillName,
    if (global) '--global',
    if (agents.isNotEmpty) ...['--agent', ...agents],
    if (assumeYes) '--yes',
  ];
}

/// The `claude` invocations that register this repository as a marketplace
/// and install the plugin, for the user or for the current project.
List<List<String>> buildClaudePluginCommands({required bool global}) {
  final scope = global ? 'user' : 'project';

  return [
    ['plugin', 'marketplace', 'add', kSkillsRepository, '--scope', scope],
    ['plugin', 'install', kClaudePlugin, '--scope', scope],
  ];
}
