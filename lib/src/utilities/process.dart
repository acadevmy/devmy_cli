import 'dart:io';

import 'package:chalkdart/chalk.dart';

Future<void> pnpmInstall(Directory workspaceDirectory) async {
  print('📦 run pnpm install');
  try {
    await Process.run(
      'corepack',
      ['pnpm', 'i'],
      workingDirectory: workspaceDirectory.path,
    );
  } catch (_) {
    print(chalk.yellowBright('⚠️ failed pnpm i'));
  }
}

Future<void> initializeGit(Directory workspaceDirectory) async {
  try {
    await Process.run(
      'git',
      ['init', '--initial-branch=main'],
      workingDirectory: workspaceDirectory.path,
    );

    print(
      '📚 initialize Git',
    );
  } catch (_) {
    print(chalk.yellowBright('⚠️ failed git initialization'));
  }
}

Future<void> commitChanges(
  Directory workspaceDirectory,
  String message,
) async {
  try {
    await Process.run(
      'git',
      ['add', '.'],
      workingDirectory: workspaceDirectory.path,
    );

    print(
      '📚 Commit "$message"',
    );

    await Process.run(
      'git',
      [
        'commit',
        '-m',
        '"$message"',
      ],
      workingDirectory: workspaceDirectory.path,
    );
  } catch (_) {
    print(chalk.yellowBright('⚠️ failed git commit'));
  }
}

Future<bool> isExecutableAvailable(String executable) async {
  try {
    final result = await Process.run('which', [executable]);
    return result.exitCode == 0;
  } catch (_) {
    return false;
  }
}

/// Runs [executable] attached to this terminal, so its own prompts work,
/// and returns its exit code.
Future<int> runInheritingStdio(
    String executable, List<String> arguments) async {
  final process = await Process.start(
    executable,
    arguments,
    mode: ProcessStartMode.inheritStdio,
  );
  return process.exitCode;
}

/// The installed Node.js version as `[major, minor]`, or null without Node.
Future<List<int>?> nodeVersion() async {
  try {
    final result = await Process.run('node', ['--version']);
    final match = RegExp(r'v(\d+)\.(\d+)').firstMatch(result.stdout.toString());
    if (result.exitCode != 0 || match == null) {
      return null;
    }
    return [int.parse(match.group(1)!), int.parse(match.group(2)!)];
  } catch (_) {
    return null;
  }
}
