import 'package:interact/interact.dart';

class InteractValidators {
  static bool isNumber(String value) {
    try {
      num.parse(value);
      return true;
    } catch(_) {
      throw ValidationError('Input is not a number');
    }
  }

  static bool isNotBlank(String value) {
    if (value.trim().isEmpty) {
      throw ValidationError('Input cannot be blank');
    }
    return true;
  }
}

