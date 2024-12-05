# dart56
Dart base 56 library for converting base10 (and base 8) numbers to / from base 56 for use as small, readable and usually HTML-ID safe sequences. 

Base 56 is arbitrary, as the character set can be shrunk or expanded in the library as a configuration setting, but Base56 is handy because it uses just letters and numbers while excluding OILoil from the set which can be mistaken for zeros and ones.

## Installation
```bash
dart pub get
```

## Example Usage (also see convert.dart for more complete usage)
```dart
import 'lib/bX.dart';

void main() {
   final bxValue = "z";
   // the return value is a list with one or more lists that contain 0 or 1 ints
   final b10Value = B10.convertBxToB10(bxValue);
   print(b10Value[0][0]);  // Outputs: 55
   final bxValueBack = B10.convertB10ToBx(b10Value);
   print(bxValue);   // Outputs: z
   
}
```

## Running Tests
Tests are located in the `test` directory and follow the naming convention `*_test.dart`.

Run all tests:
```bash
dart test
```

Run a specific test file:
```bash
dart test test/bx_test.dart
```

Run tests with coverage:
```bash
dart test --coverage=coverage
dart run coverage:format_coverage --lcov --in=coverage --out=coverage.lcov --packages=.packages --report-on=lib
```

## Contributing
1. Fork the repository
2. Create your feature branch
3. Add tests for any new functionality
4. Ensure all tests pass
5. Submit a pull request
