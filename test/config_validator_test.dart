import 'package:test/test.dart';
import 'package:dart56/src/config_validator.dart';

void main() {
  group('ConfigValidator', () {
    test('validates valid default configuration', () {
      final validConfig = {
        'bX': {
          'removeChars': 'OILoil',
          'prependSeparator': '-',
          'prependDefaultChar': 'X',
          'subdomainChar': '.',
          'seqStartValue': 'A0',
        }
      };

      expect(() => ConfigValidator.validateConfig(validConfig), returnsNormally);
    });

    test('throws on missing bX section', () {
      final Map<String, dynamic> invalidConfig = {};

      expect(
        () => ConfigValidator.validateConfig(invalidConfig),
        throwsA(predicate((e) =>
            e is ConfigValidationError &&
            e.toString().contains('Missing required "bX" configuration'))),
      );
    });

    test('throws on invalid bX type', () {
      final Map<String, dynamic> invalidConfig = {'bX': 'not a map'};

      expect(
        () => ConfigValidator.validateConfig(invalidConfig),
        throwsA(predicate((e) =>
            e is ConfigValidationError &&
            e.toString().contains('must be a Map'))),
      );
    });

    group('required field validation', () {
      final requiredFields = [
        'removeChars',
        'prependSeparator',
        'prependDefaultChar',
        'subdomainChar',
        'seqStartValue'
      ];

      for (final field in requiredFields) {
        test('throws on missing $field', () {
          final config = {
            'bX': <String, dynamic>{
              'removeChars': 'OILoil',
              'prependSeparator': '-',
              'prependDefaultChar': 'X',
              'subdomainChar': '.',
              'seqStartValue': 'A0',
            }
          };
          (config['bX'] as Map<String, dynamic>).remove(field);

          expect(
            () => ConfigValidator.validateConfig(config),
            throwsA(predicate((e) =>
                e is ConfigValidationError &&
                e.toString().contains('Missing required configuration key: $field'))),
          );
        });

        test('throws on non-string $field', () {
          final config = {
            'bX': <String, dynamic>{
              'removeChars': 'OILoil',
              'prependSeparator': '-',
              'prependDefaultChar': 'X',
              'subdomainChar': '.',
              'seqStartValue': 'A0',
            }
          };
          (config['bX'] as Map<String, dynamic>)[field] = 123;

          expect(
            () => ConfigValidator.validateConfig(config),
            throwsA(predicate((e) =>
                e is ConfigValidationError &&
                e.toString().contains('must be a string'))),
          );
        });
      }
    });

    group('special character validation', () {
      test('throws on multi-character prependSeparator', () {
        final config = {
          'bX': {
            'removeChars': 'OILoil',
            'prependSeparator': '--',
            'prependDefaultChar': 'X',
            'subdomainChar': '.',
            'seqStartValue': 'A0',
          }
        };

        expect(
          () => ConfigValidator.validateConfig(config),
          throwsA(predicate((e) =>
              e is ConfigValidationError &&
              e.toString().contains('prependSeparator must be exactly one character'))),
        );
      });

      test('throws on multi-character prependDefaultChar', () {
        final config = {
          'bX': {
            'removeChars': 'OILoil',
            'prependSeparator': '-',
            'prependDefaultChar': 'XX',
            'subdomainChar': '.',
            'seqStartValue': 'A0',
          }
        };

        expect(
          () => ConfigValidator.validateConfig(config),
          throwsA(predicate((e) =>
              e is ConfigValidationError &&
              e.toString().contains('prependDefaultChar must be exactly one character'))),
        );
      });

      test('throws on multi-character subdomainChar', () {
        final config = {
          'bX': {
            'removeChars': 'OILoil',
            'prependSeparator': '-',
            'prependDefaultChar': 'X',
            'subdomainChar': '..',
            'seqStartValue': 'A0',
          }
        };

        expect(
          () => ConfigValidator.validateConfig(config),
          throwsA(predicate((e) =>
              e is ConfigValidationError &&
              e.toString().contains('subdomainChar must be exactly one character'))),
        );
      });

      test('throws on duplicate special characters', () {
        final config = {
          'bX': {
            'removeChars': 'OILoil',
            'prependSeparator': '-',
            'prependDefaultChar': 'X',
            'subdomainChar': '-',
            'seqStartValue': 'A0',
          }
        };

        expect(
          () => ConfigValidator.validateConfig(config),
          throwsA(predicate((e) =>
              e is ConfigValidationError &&
              e.toString().contains('must be different characters'))),
        );
      });

      test('throws when special character is in removeChars', () {
        final config = {
          'bX': {
            'removeChars': 'OILoil-',
            'prependSeparator': '-',
            'prependDefaultChar': 'X',
            'subdomainChar': '.',
            'seqStartValue': 'A0',
          }
        };

        expect(
          () => ConfigValidator.validateConfig(config),
          throwsA(predicate((e) =>
              e is ConfigValidationError &&
              e.toString().contains('Special characters cannot be in removeChars'))),
        );
      });
    });

    test('throws on empty seqStartValue', () {
      final config = {
        'bX': {
          'removeChars': 'OILoil',
          'prependSeparator': '-',
          'prependDefaultChar': 'X',
          'subdomainChar': '.',
          'seqStartValue': '',
        }
      };

      expect(
        () => ConfigValidator.validateConfig(config),
        throwsA(predicate((e) =>
            e is ConfigValidationError &&
            e.toString().contains('seqStartValue cannot be empty'))),
      );
    });
  });
}
