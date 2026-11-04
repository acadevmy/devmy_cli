import 'package:devmy_cli/devmy_cli.dart';
import 'package:mason/mason.dart';
import 'package:test/test.dart';

void main() {
  group('BrickVariableProperties.parse', () {
    test('keeps strings as they are', () {
      expect(BrickVariableProperties.string().parse('web'), 'web');
    });

    test('parses numbers and rejects anything else', () {
      expect(BrickVariableProperties.number().parse('4000'), 4000);
      expect(
        () => BrickVariableProperties.number().parse('four'),
        throwsFormatException,
      );
    });

    test('parses booleans strictly', () {
      expect(BrickVariableProperties.boolean().parse('true'), isTrue);
      expect(BrickVariableProperties.boolean().parse('false'), isFalse);
      expect(
        () => BrickVariableProperties.boolean().parse('yes'),
        throwsFormatException,
      );
    });

    test('accepts only declared enum values', () {
      final properties = BrickVariableProperties.enumeration(
        values: ['npm', 'pnpm'],
      );

      expect(properties.parse('pnpm'), 'pnpm');
      expect(() => properties.parse('yarn'), throwsFormatException);
    });

    test('turns comma separated array values into a mustache array', () {
      final properties = BrickVariableProperties.array(
        values: ['a', 'b', 'c'],
      );

      final parsed = properties.parse('a, c') as Map;
      expect(
        (parsed['items'] as List).map((item) => item['value']),
        ['a', 'c'],
      );
      expect(() => properties.parse('a,z'), throwsFormatException);
    });

    test('splits lists on their separator', () {
      final properties = BrickVariableProperties.list(separator: ';');

      final parsed = properties.parse('pnpm dev; pnpm api ;') as Map;
      expect(
        (parsed['items'] as List).map((item) => item['value']),
        ['pnpm dev', 'pnpm api'],
      );
    });
  });

  group('BrickVariableProperties defaults', () {
    test('a string without default is required', () {
      expect(BrickVariableProperties.string().hasDefault, isFalse);
    });

    test('a declared default is used', () {
      final properties = BrickVariableProperties.number(defaultValue: 4000);

      expect(properties.hasDefault, isTrue);
      expect(properties.defaultInput(), 4000);
    });

    test('a list with an empty default becomes an empty list', () {
      final properties = BrickVariableProperties.list();

      expect(properties.hasDefault, isTrue);
      expect((properties.defaultInput() as Map)['isEmpty'], isTrue);
    });
  });
}
