import 'package:devmy_cli/src/utilities/create_mustache_array.dart';
import 'package:devmy_cli/src/utilities/interact_validators.dart';
import 'package:interact/interact.dart';
import 'package:mason/mason.dart';

extension BrickVariablePropertiesPrompt on BrickVariableProperties {
  dynamic input() {
    final prompt = this.prompt ?? '';
    final options = values ?? [];
    final defaultValue = this.defaultValue as dynamic;

    if (type == BrickVariableType.array) {
      List<bool>? defaults;
      if (defaultValues != null) {
        final selectedByDefault = _stringList(defaultValues);
        defaults = options.map(selectedByDefault.contains).toList();
      }

      final selections = MultiSelect(
        prompt: prompt,
        options: options,
        defaults: defaults,
      ).interact();

      return selections
          .map((index) => options[index])
          .whereType<String>()
          .toMustacheArray();
    }

    if (type == BrickVariableType.number) {
      final input = Input(
        prompt: prompt,
        defaultValue: defaultValue != null ? '$defaultValue' : null,
        validator: InteractValidators.isNumber,
      ).interact();

      return num.parse(input);
    }

    if (type == BrickVariableType.string) {
      return Input(
        prompt: prompt,
        defaultValue: defaultValue,
        validator: InteractValidators.isNotBlank,
      ).interact();
    }

    if (type == BrickVariableType.boolean) {
      return Confirm(
        prompt: prompt,
        defaultValue: defaultValue,
        waitForNewLine: true,
      ).interact();
    }

    if (type == BrickVariableType.enumeration) {
      final index = Select(
        prompt: prompt,
        options: options,
      ).interact();

      return options[index];
    }

    if (type == BrickVariableType.list) {
      final separator = _listSeparator;

      return _splitList(
        Input(
          prompt: '$prompt (concatenate with $separator)',
          defaultValue: _stringList(defaultValue).join(separator),
        ).interact(),
      );
    }
  }

  /// Converts a raw command line value (`--var key=value`) into the value the
  /// brick expects for this variable type.
  dynamic parse(String raw) {
    final options = values ?? [];

    switch (type) {
      case BrickVariableType.array:
        final selections = raw
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList();
        final invalid = selections.where((value) => !options.contains(value));
        if (invalid.isNotEmpty) {
          throw FormatException(
            'invalid values ${invalid.join(', ')}, allowed: ${options.join(', ')}',
          );
        }
        return selections.toMustacheArray();
      case BrickVariableType.number:
        final number = num.tryParse(raw);
        if (number == null) {
          throw FormatException('"$raw" is not a number');
        }
        return number;
      case BrickVariableType.string:
        return raw;
      case BrickVariableType.boolean:
        if (raw != 'true' && raw != 'false') {
          throw FormatException('"$raw" is not true or false');
        }
        return raw == 'true';
      case BrickVariableType.enumeration:
        if (!options.contains(raw)) {
          throw FormatException(
            '"$raw" is not allowed, allowed: ${options.join(', ')}',
          );
        }
        return raw;
      case BrickVariableType.list:
        return _splitList(raw);
    }
  }

  /// Whether a value can be used without asking: an explicit default, or an
  /// empty selection for array and list variables.
  bool get hasDefault {
    if (type == BrickVariableType.array || type == BrickVariableType.list) {
      return true;
    }

    return defaultValue != null;
  }

  /// The value used when the variable is neither passed nor prompted.
  dynamic defaultInput() {
    if (type == BrickVariableType.array) {
      return _stringList(defaultValues).toMustacheArray();
    }

    if (type == BrickVariableType.list) {
      return _stringList(defaultValue).toMustacheArray();
    }

    return defaultValue;
  }

  String get _listSeparator => separator ?? ',';

  dynamic _splitList(String raw) {
    return raw
        .split(_listSeparator)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toMustacheArray();
  }

  /// Normalizes defaults that YAML may give as null, a string or a list.
  List<String> _stringList(Object? value) {
    if (value == null) {
      return [];
    }

    if (value is String) {
      return value
          .split(_listSeparator)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (value is Iterable) {
      return value.map((e) => '$e').toList();
    }

    return ['$value'];
  }
}
