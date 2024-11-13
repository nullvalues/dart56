import 'dart:math';
import '../config_api.dart';

class B10 {

  static final List<(String, int)> _baseChars = B10()._buildBase();

  List<(String, int)> _buildBase() {
    final removeChars = Bootstrap.apiConfig['bX']['removeChars'] ?? "OILoil";
    final charSet = [
      ...List.generate(10, (i) => String.fromCharCode(i + 48)),  // 0-9
      ...List.generate(26, (i) => String.fromCharCode(i + 65)),  // A-Z
      ...List.generate(26, (i) => String.fromCharCode(i + 97)),  // a-z
    ].where((char) => !removeChars.contains(char)).toList();

    return List.generate(charSet.length, (i) => (charSet[i], i));
  }

  static String convertB10ToBx(int b10Value) {
    if (b10Value == 0) return _baseChars[0].$1;

    final baseSize = _baseChars.length;
    var result = '';
    while (b10Value > 0) {
      final remainder = b10Value % baseSize;
      result = _baseChars[remainder].$1 + result;
      b10Value ~/= baseSize;
    }
    return result;
  }

  static int convertBxToB10(String bxValue) {
    final baseSize = _baseChars.length;
    final baseMap = Map.fromEntries(_baseChars.map((e) => MapEntry(e.$1, e.$2)));

    var result = 0;
    for (var i = 0; i < bxValue.length; i++) {
      final char = bxValue[bxValue.length - 1 - i];
      if (!baseMap.containsKey(char)) {
        throw FormatException('Invalid character in input: $char');
      }
      result += baseMap[char]! * pow(baseSize, i).toInt();
    }
    return result;
  }
}