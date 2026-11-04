import 'package:devmy_cli/devmy_cli.dart';
import 'package:test/test.dart';

void main() {
  test('Empty test', () {
    expect(4, equals(4));
  });

  test('every addon referenced by a question is configured', () {
    final addonNames = cliConfiguration.addons.map((addon) => addon.name);
    final questions = [
      ...cliConfiguration.new$.questions,
      ...cliConfiguration.applications.expand((app) => app.questions),
      ...cliConfiguration.libraries.expand((lib) => lib.questions),
    ];

    for (final question in questions) {
      expect(addonNames, containsAll(question.addonNames));
    }
  });

  test('angular/tailwind addon is no longer exposed', () {
    final angular = cliConfiguration.applications
        .singleWhere((app) => app.name == 'angular');

    expect(
      cliConfiguration.addons.map((addon) => addon.name),
      isNot(contains('angular/tailwind')),
    );
    expect(
      angular.questions.expand((question) => question.addonNames),
      equals(['vercel']),
    );
  });
}
