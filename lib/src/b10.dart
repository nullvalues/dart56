import 'dart:math';
import '../config_api.dart';

class B10 {
  static final List<(String, int)> _baseChars = B10()._buildBase();
  static final Random _random = Random();

  List<(String, int)> _buildBase() {
    final removeChars = Bootstrap.apiConfig['bX']['removeChars'] ?? "OILoil";
    final charSet = [
      ...List.generate(10, (i) => String.fromCharCode(i + 48)), // 0-9
      ...List.generate(26, (i) => String.fromCharCode(i + 65)), // A-Z
      ...List.generate(26, (i) => String.fromCharCode(i + 97)), // a-z
    ].where((char) => !removeChars.contains(char)).toList();

    return List.generate(charSet.length, (i) => (charSet[i], i));
  }

  static String convertB10ToBx(int b10Value,
      {String? prepend, bool useDefaultPrepend = false}) {
    if (b10Value == 0) {
      final baseValue = _baseChars[0].$1;
      return _addPrepend(baseValue, prepend, useDefaultPrepend);
    }

    final baseSize = _baseChars.length;
    var result = '';
    while (b10Value > 0) {
      final remainder = b10Value % baseSize;
      result = _baseChars[remainder].$1 + result;
      b10Value ~/= baseSize;
    }

    return _addPrepend(result, prepend, useDefaultPrepend);
  }

  static String _addPrepend(
      String value, String? prepend, bool useDefaultPrepend) {
    if (prepend != null) {
      return '${prepend}${Bootstrap.apiConfig['bX']['prependSeparator']}$value';
    }
    if (useDefaultPrepend) {
      final defaultChar = Bootstrap.apiConfig['bX']['prependDefaultChar'];
      return '${defaultChar}${Bootstrap.apiConfig['bX']['prependSeparator']}$value';
    }
    return value;
  }

  static String incrementBxValue(String bxValue) {
    // Extract prepend if it exists
    final separator = Bootstrap.apiConfig['bX']['prependSeparator'];
    var prepend = '';
    var valueToIncrement = bxValue;

    if (bxValue.contains(separator)) {
      final parts = bxValue.split(separator);
      prepend = parts[0];
      valueToIncrement = parts[1];
    }

    final b10Value = convertBxToB10(valueToIncrement);
    final incremented = convertB10ToBx(b10Value + 1);

    return prepend.isEmpty ? incremented : '$prepend$separator$incremented';
  }

  static int convertBxToB10(String bxValue) {
    final separator = Bootstrap.apiConfig['bX']['prependSeparator'];
    var valueToConvert = bxValue;

    // Strip prepend if present
    if (bxValue.contains(separator)) {
      valueToConvert = bxValue.split(separator).last;
    }

    final baseSize = _baseChars.length;
    final baseMap =
        Map.fromEntries(_baseChars.map((e) => MapEntry(e.$1, e.$2)));

    var result = 0;
    for (var i = 0; i < valueToConvert.length; i++) {
      final char = valueToConvert[valueToConvert.length - 1 - i];
      if (!baseMap.containsKey(char)) {
        throw FormatException('Invalid character in input: $char');
      }
      result += baseMap[char]! * pow(baseSize, i).toInt();
    }
    return result;
  }

  static String joinBxValues(String value, {String? parent}) {
    final separator = Bootstrap.apiConfig['bX']['subdomainChar'];
    final actualParent = parent ?? generateRandomBxValue(2, forceLetterFirst: true);
    return '$actualParent$separator$value';
  }

  static String generateRandomBxValue(int width,
      {String? prepend,
      bool useDefaultPrepend = false,
      bool forceLetterFirst = false}) {
    if (width <= 0) throw ArgumentError('Width must be greater than 0');

    final baseSize = _baseChars.length;
    final maxValue = pow(baseSize, width).toInt() - 1;
    final minValue = pow(baseSize, width - 1).toInt();

    String result;
    do {
      final randomValue = minValue + _random.nextInt(maxValue - minValue + 1);
      result = convertB10ToBx(randomValue,
          prepend: prepend, useDefaultPrepend: useDefaultPrepend);

      if (!forceLetterFirst) break;

      final valueToCheck =
          result.contains('-') ? result.split('-').last : result;
      if (valueToCheck[0].toLowerCase() != valueToCheck[0].toUpperCase()) break;
    } while (true);

    return result;
  }
}
