import 'b10.dart';

class B8 {
  static String convertB8ToBx(Base8Int b8Value, {String? prepend, bool useDefaultPrepend = false}) {
    final int b10value = b8Value.toDecimal();
    return B10.convertB10ToBx(b10value, prepend: prepend, useDefaultPrepend: useDefaultPrepend);
  }

  static Base8Int convertBxToB8(String bxValue) {
    final int b10Value = B10.convertBxToB10(bxValue);
    return Base8Int.fromInt(b10Value);
  }
}

class Base8Int {
  final int value;

  Base8Int(this.value) {
    if (value < 0 || _containsInvalidDigit(value)) {
      throw FormatException('Invalid Base8 integer: $value');
    }
  }

  static bool _containsInvalidDigit(int number) {
    return number.toString().split('').any((digit) => int.parse(digit) > 7);
  }

  factory Base8Int.fromInt(int decimalValue) {
    return Base8Int(int.parse(decimalValue.toRadixString(8)));
  }

  @override
  String toString() => value.toString();

  int toDecimal() => int.parse(value.toString(), radix: 8);

  static Base8Int? tryParse(String input) {
    try {
      return Base8Int(int.parse(input));
    } on FormatException {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Base8Int &&
              runtimeType == other.runtimeType &&
              value == other.value;

  // Override hashCode
  @override
  int get hashCode => value.hashCode;
}
