import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:devmy_cli/devmy_cli.dart';
import 'package:devmy_cli/src/version.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  // Other test files change Directory.current, which is shared by the whole
  // process: resolve files from the package root instead.
  late Directory root;
  File file(String path) => File.fromUri(root.uri.resolve(path));
  late File skillFile;

  setUpAll(() async {
    final lib =
        await Isolate.resolvePackageUri(Uri.parse('package:devmy_cli/'));
    root = Directory.fromUri(lib!.resolve('..'));
    skillFile = file('skills/devmy/SKILL.md');
  });

  YamlMap frontmatter() {
    final match = RegExp(r'^---\n([\s\S]*?)\n---\n')
        .firstMatch(skillFile.readAsStringSync());
    expect(match, isNotNull, reason: 'SKILL.md needs a YAML frontmatter');
    return loadYaml(match!.group(1)!) as YamlMap;
  }

  test('the command catalog is up to date (run make skill_reference)', () {
    expect(
      file(kCommandsReferencePath).readAsStringSync(),
      renderCommandsReference(cliConfiguration),
    );
  });

  test('the frontmatter follows the Agent Skills specification', () {
    final metadata = frontmatter();
    final name = metadata['name'] as String;
    final description = metadata['description'] as String;

    expect(name, skillFile.parent.uri.pathSegments.lastWhere((s) => s != ''));
    expect(name, matches(RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$')));
    expect(name.length, lessThanOrEqualTo(64));
    expect(description, isNotEmpty);
    expect(description.length, lessThanOrEqualTo(1024));
    expect(description, isNot(contains('<')));
    expect((metadata['compatibility'] as String).length, lessThan(500));
  });

  test('the skill states the CLI version it documents', () {
    expect(frontmatter()['metadata']['cli-version'], packageVersion);
  });

  test('the embedded version matches pubspec.yaml', () {
    final pubspec = loadYaml(file('pubspec.yaml').readAsStringSync());
    expect(packageVersion, pubspec['version']);
  });

  test('every file the skill links to exists', () {
    final links = RegExp(r'\]\(([^)#:]+)\)')
        .allMatches(skillFile.readAsStringSync())
        .map((match) => match.group(1)!);

    expect(links, isNotEmpty);
    for (final link in links) {
      expect(file('skills/devmy/$link').existsSync(), isTrue, reason: link);
    }
  });

  test('the marketplace lists this repository as the devmy plugin', () {
    final marketplace =
        jsonDecode(file('.claude-plugin/marketplace.json').readAsStringSync());
    final plugin =
        jsonDecode(file('.claude-plugin/plugin.json').readAsStringSync());

    expect(marketplace['plugins'], hasLength(1));
    expect(marketplace['plugins'][0]['name'], plugin['name']);
    expect(marketplace['plugins'][0]['source'], './');
    expect(plugin['version'], isNull,
        reason: 'without a version Claude Code updates on every commit');
  });
}
