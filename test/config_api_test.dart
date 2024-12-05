import 'package:test/test.dart';
import 'package:dart56/config_api.dart';
import 'package:dart56/src/config_validator.dart';

void main() {
  group('Bootstrap', () {
    setUp(() {
      Bootstrap.reset();
    });

    test('provides default configuration', () {
      final config = Bootstrap.apiConfig;
      
      expect(config['bX'], isNotNull);
      expect(config['bX']['removeChars'], equals('OILoil'));
      expect(config['bX']['prependSeparator'], equals('-'));
      expect(config['bX']['prependDefaultChar'], equals('X'));
      expect(config['bX']['subdomainChar'], equals('.'));
      expect(config['bX']['seqStartValue'], equals('A0'));
    });

    test('configuration is deeply immutable', () {
      final config = Bootstrap.apiConfig;
      final bxConfig = config['bX'] as Map<String, dynamic>;
      
      // Test top-level immutability
      expect(
        () => config['newKey'] = 'value',
        throwsUnsupportedError,
      );

      // Test nested map immutability
      expect(
        () => bxConfig['newKey'] = 'value',
        throwsUnsupportedError,
      );
    });

    test('allows configuration update before first use', () {
      final newConfig = {
        "bX": {
          "removeChars": "ABC",
          "prependSeparator": "_",
          "prependDefaultChar": "Y",
          "subdomainChar": ":",
          "seqStartValue": "B0"
        }
      };

      // Update should work since we haven't accessed apiConfig yet
      Bootstrap.updateConfig(newConfig);
      final config = Bootstrap.apiConfig;

      expect(config['bX']['removeChars'], equals('ABC'));
      expect(config['bX']['prependSeparator'], equals('_'));
      expect(config['bX']['prependDefaultChar'], equals('Y'));
      expect(config['bX']['subdomainChar'], equals(':'));
      expect(config['bX']['seqStartValue'], equals('B0'));
    });

    test('prevents configuration update after initialization', () {
      // First access initializes the configuration
      Bootstrap.apiConfig;

      final newConfig = {
        "bX": {
          "removeChars": "ABC",
          "prependSeparator": "_",
          "prependDefaultChar": "Y",
          "subdomainChar": ":",
          "seqStartValue": "B0"
        }
      };

      expect(
        () => Bootstrap.updateConfig(newConfig),
        throwsA(isA<StateError>()),
      );
    });

    test('validates configuration before initialization', () {
      final invalidConfig = {
        "bX": {
          "removeChars": "ABC",
          "prependSeparator": "__", // Invalid: more than one character
          "prependDefaultChar": "Y",
          "subdomainChar": ":",
          "seqStartValue": "B0"
        }
      };

      expect(
        () => Bootstrap.updateConfig(invalidConfig),
        throwsA(isA<ConfigValidationError>()),
      );
    });
  });
}
