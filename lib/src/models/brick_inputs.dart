import 'package:args/args.dart';

/// Answers given on the command line, so a brick command can run without
/// prompts (AI agents, CI). Every field is optional: what is missing is
/// prompted when [interactive] is true.
class BrickInputs {
  final String? name;
  final List<String> addons;
  final Map<String, String> vars;
  final String? target;
  final bool interactive;
  final bool describe;

  const BrickInputs({
    this.name,
    this.addons = const [],
    this.vars = const {},
    this.target,
    this.interactive = true,
    this.describe = false,
  });

  factory BrickInputs.fromArgResults(
    ArgResults results, {
    required bool hasTerminal,
  }) {
    String? option(String name) =>
        results.options.contains(name) ? results[name] as String? : null;
    List<String> multiOption(String name) =>
        results.options.contains(name) ? results[name] as List<String> : [];

    return BrickInputs(
      name: option('name'),
      addons: multiOption('addon'),
      vars: parseVars(multiOption('var')),
      target: option('target'),
      interactive: hasTerminal && results['interactive'] == true,
      describe: results['describe'] == true,
    );
  }

  /// Parses `key=value` pairs. The value may contain `=`.
  static Map<String, String> parseVars(List<String> rawVars) {
    final vars = <String, String>{};

    for (final rawVar in rawVars) {
      final separatorIndex = rawVar.indexOf('=');
      if (separatorIndex <= 0) {
        throw FormatException(
          'invalid --var "$rawVar", expected the form key=value',
        );
      }

      vars[rawVar.substring(0, separatorIndex)] =
          rawVar.substring(separatorIndex + 1);
    }

    return vars;
  }
}
