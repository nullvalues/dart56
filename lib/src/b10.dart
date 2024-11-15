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
    if (b10Value < 0) {
      throw ArgumentError('Cannot convert negative values');
    }

    if (b10Value == 0) {
      final baseValue = _baseChars[0].$1;
      return _addPrepend(baseValue, prepend, useDefaultPrepend);
    }

    final baseSize = _baseChars.length;
    var result = '';
    var value = b10Value;

    while (value > 0) {
      final remainder = value % baseSize;
      result = _baseChars[remainder].$1 + result;
      value ~/= baseSize;
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

  static List<List<int>> convertBxToB10(String bxValue) {
    if (bxValue.isEmpty) {
      return [[]];
    }

    final separator = Bootstrap.apiConfig['bX']['prependSeparator'];
    final subdomainChar = Bootstrap.apiConfig['bX']['subdomainChar'];
    var valueToConvert = bxValue;

    // Strip prepend if present
    if (bxValue.contains(separator)) {
      final parts = bxValue.split(separator);
      if (parts.length != 2) {
        return [[]];  // Invalid prepend format
      }
      valueToConvert = parts[1];
    }

    // Handle subdomain recursion
    if (valueToConvert.contains(subdomainChar)) {
      final parts = valueToConvert.split(subdomainChar);
      if (parts.any((part) => part.isEmpty)) {
        return List.generate(parts.length, (_) => []);  // Invalid empty parts
      }
      return parts.map((part) => _convertSingleBxToB10(part)).toList();
    }

    return [_convertSingleBxToB10(valueToConvert)];
  }

  static List<int> _convertSingleBxToB10(String bxValue) {
    if (bxValue.isEmpty) {
      return [];
    }

    final baseSize = _baseChars.length;
    final baseMap = Map.fromEntries(_baseChars.map((e) => MapEntry(e.$1, e.$2)));

    var result = 0;
    try {
      for (var i = 0; i < bxValue.length; i++) {
        final char = bxValue[bxValue.length - 1 - i];
        if (!baseMap.containsKey(char)) {
          return [];  // Invalid character
        }
        result += baseMap[char]! * pow(baseSize, i).toInt();
      }
      return [result];
    } catch (e) {
      return [];  // Handle any other errors
    }
  }

  static String? incrementBxValue(String bxValue) {
    final separator = Bootstrap.apiConfig['bX']['prependSeparator'];
    var prepend = '';
    var valueToIncrement = bxValue;

    // Handle prepend
    if (bxValue.contains(separator)) {
      final parts = bxValue.split(separator);
      if (parts.length != 2) {
        return null;  // Invalid prepend format
      }
      prepend = parts[0];
      valueToIncrement = parts[1];
    }

    // Convert and increment
    final converted = convertBxToB10(valueToIncrement);
    if (converted.isEmpty || converted[0].isEmpty) {
      return null;  // Invalid conversion
    }

    try {
      final incremented = convertB10ToBx(converted[0][0] + 1);
      return prepend.isEmpty ? incremented : '$prepend$separator$incremented';
    } catch (e) {
      return null;  // Handle any conversion errors
    }
  }

  static String joinBxValues(String value, {String? parent}) {
    final separator = Bootstrap.apiConfig['bX']['subdomainChar'];
    final actualParent = parent ?? generateRandomBxValue(2, forceLetterFirst: true);

    // Validate both parts
    final parentConverted = convertBxToB10(actualParent);
    final valueConverted = convertBxToB10(value);

    if (parentConverted.isEmpty || parentConverted[0].isEmpty ||
        valueConverted.isEmpty || valueConverted[0].isEmpty) {
      throw ArgumentError('Invalid bX values for joining');
    }

    return '$actualParent$separator$value';
  }

  static String generateRandomBxValue(int width,
      {String? prepend,
        bool useDefaultPrepend = false,
        bool forceLetterFirst = false}) {
    if (width <= 0) {
      throw ArgumentError('Width must be greater than 0');
    }

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
      result.contains(Bootstrap.apiConfig['bX']['prependSeparator'])
          ? result.split(Bootstrap.apiConfig['bX']['prependSeparator']).last
          : result;

      if (_isLetter(valueToCheck[0])) break;
    } while (true);

    return result;
  }

  static bool _isLetter(String char) {
    return char.toLowerCase() != char.toUpperCase();
  }

  // Utility methods for validation
  static bool isValidBxChar(String char) {
    return _baseChars.any((tuple) => tuple.$1 == char);
  }

  static bool isValidBxValue(String value) {
    final converted = convertBxToB10(value);
    return converted.isNotEmpty && converted[0].isNotEmpty;
  }
}