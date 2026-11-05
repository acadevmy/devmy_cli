import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:devmy_cli/devmy_cli.dart';
import 'package:test/test.dart';

void main() {
  late Directory workspace;
  late Directory previousDirectory;
  late CommandRunner<void> runner;

  setUp(() {
    previousDirectory = Directory.current;
    workspace = Directory.systemTemp.createTempSync('devmy_workspace_');
    File('${workspace.path}/pnpm-workspace.yaml').writeAsStringSync('');
    _writePackage(workspace, 'demo');
    _writePackage(Directory('${workspace.path}/applications/web'), 'web');
    Directory('${workspace.path}/libraries').createSync();
    Directory.current = workspace;
    runner = CommandRunnerFactory().create(cliConfiguration);
  });

  tearDown(() {
    Directory.current = previousDirectory;
    workspace.deleteSync(recursive: true);
  });

  Matcher usageError(String message) => throwsA(
        isA<UsageException>()
            .having((e) => e.message, 'message', contains(message)),
      );

  test('a missing --name fails without prompting', () {
    expect(
      runner.run(['generate', 'application', 'nextjs', '--no-interactive']),
      usageError('Missing --name'),
    );
  });

  test('a blank --name is rejected', () {
    expect(
      runner.run(['g', 'a', 'nextjs', '--name', ' ', '--no-interactive']),
      usageError('--name cannot be blank'),
    );
  });

  test('a malformed --var is rejected', () {
    expect(
      runner.run(['g', 'a', 'nextjs', '--name', 'web', '--var', 'port']),
      usageError('expected the form key=value'),
    );
  });

  test('only the addons a command can apply are accepted', () {
    expect(
      runner.run(['g', 'a', 'nextjs', '--addon', 'angular/tailwind']),
      throwsA(isA<UsageException>()),
    );
  });

  test('an addon without --target lists the workspace projects', () {
    expect(
      runner.run(['g', 'addon', 'next/zustand', '--no-interactive']),
      usageError('Missing --target: pass one of demo, web'),
    );
  });

  test('an unknown --target lists the workspace projects', () {
    expect(
      runner.run([
        'g', 'addon', 'next/zustand', '--target', 'api', '--no-interactive', //
      ]),
      usageError('Unknown --target "api". Available: demo, web'),
    );
  });
}

void _writePackage(Directory directory, String name) {
  directory.createSync(recursive: true);
  File('${directory.path}/package.json')
      .writeAsStringSync(jsonEncode({'name': name}));
}
