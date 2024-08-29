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
