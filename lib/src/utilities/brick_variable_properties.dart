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
        defaults = (defaultValues as List<String>)
            .map((value) => options.contains(value))
            .toList();
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
      return Select(
        prompt: prompt,
        options: options,
      ).interact();
    }

    if (type == BrickVariableType.list) {
      final separator = this.separator ?? ',';

      return Input(
        prompt: '$prompt (concatenate with $separator)',
        defaultValue: defaultValue,
      )
          .interact()
          .split(separator)
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toMustacheArray();
    }
  }
}
