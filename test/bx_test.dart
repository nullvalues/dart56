import 'package:test/test.dart';
import 'package:dart56/bX.dart';
import 'dart:io';

void main() {
  group('B10 Tests', () {
    test('converts base 10 to bX correctly', () {
      expect(B10.convertB10ToBx(0), equals('0'));
      expect(B10.convertB10ToBx(55), equals('z'));
      expect(B10.convertB10ToBx(56), equals('10'));
    });

    test('converts bX to base 10 correctly for valid input', () {
      expect(B10.convertBxToB10('0'), equals([[0]]));
      expect(B10.convertBxToB10('z'), equals([[55]]));
      expect(B10.convertBxToB10('10'), equals([[56]]));
    });

    test('handles invalid characters in bX conversion', () {
      expect(B10.convertBxToB10('O'), equals([[]]));  // O is removed char
      expect(B10.convertBxToB10('!'), equals([[]]));  // Invalid char
      expect(B10.convertBxToB10('I'), equals([[]]));  // I is removed char
    });

    test('handles subdomain characters in bX conversion', () {
      expect(B10.convertBxToB10('a.b'), equals([[33], [34]]));
      expect(B10.convertBxToB10('z.y.x'), equals([[55], [54], [53]]));
      expect(B10.convertBxToB10('a.O.c'), equals([[33], [], [35]]));  // Invalid middle part
    });

    test('handles prepends with subdomain characters', () {
      final value = B10.convertBxToB10('test-a.b');
      expect(value, equals([[33], [34]]));
    });

    test('handles prepends correctly', () {
      final value = B10.convertB10ToBx(42, prepend: 'test');
      expect(value.startsWith('test-'), isTrue);
      expect(B10.convertBxToB10(value), equals([[42]]));
    });

    test('handles default prepend', () {
      final value = B10.convertB10ToBx(42, useDefaultPrepend: true);
      expect(value.startsWith('X-'), isTrue);
      expect(B10.convertBxToB10(value), equals([[42]]));
    });

    test('generates fixed width values', () {
      final value = B10.generateRandomBxValue(2);
      expect(value.length, equals(2));
    });

    test('generates HTML-safe IDs', () {
      final value = B10.generateRandomBxValue(2, forceLetterFirst: true);
      expect(value[0].toLowerCase() != value[0].toUpperCase(), isTrue);
    });

    test('joins bX values correctly', () {
      final parent = B10.convertB10ToBx(33);  // 'a'
      final child = B10.convertB10ToBx(34);   // 'b'
      final joined = B10.joinBxValues(child, parent: parent);
      expect(joined, equals('$parent.$child'));
    });

    test('generates random parent for joining when not provided', () {
      final child = B10.convertB10ToBx(34);   // 'b'
      final joined = B10.joinBxValues(child);
      expect(joined.contains('.'), isTrue);
      expect(joined.split('.')[1], equals(child));
    });

    test('incrementBxValue handles valid input correctly', () {
      expect(B10.incrementBxValue('z'), equals('10')); // z (55) + 1 = 56 = '10' in bx
      expect(B10.incrementBxValue('y'), equals('z'));  // y (54) + 1 = 55 = 'z' in bx
    });

    test('incrementBxValue handles invalid input gracefully', () {
      expect(B10.incrementBxValue('O'), isNull);
      expect(B10.incrementBxValue('test-O'), isNull);
      expect(B10.incrementBxValue('!'), isNull);
    });
  });

  group('B8 Tests', () {
    test('b8 to bX: 0', () {
      expect(B8.convertB8ToBx(Base8Int(0)), equals("0"));
    });

    test('b8 to bX: 8^1', () {
      final b8Value = Base8Int(10);
      expect(B8.convertB8ToBx(b8Value), equals("8"));
    });

    test('b8 to bX: 12', () {
      final b8Value = Base8Int(12);
      expect(B8.convertB8ToBx(b8Value), equals("A"));
    });

    test('bX to b8: 1', () {
      final Base8Int b8value = Base8Int(1);
      expect(B8.convertBxToB8("1")[0][0], equals(b8value));
    });

    test('bX to b8: A', () {
      final Base8Int b8value = Base8Int(12);
      expect(B8.convertBxToB8("A")[0][0], equals(b8value));
    });

    test('handles invalid characters in bX to base 8 conversion', () {
      final result = B8.convertBxToB8('O');  // O is removed char
      expect(result.length, equals(1));
      expect(result[0].isEmpty, isTrue);
    });

    test('handles subdomain characters in bX to base 8 conversion', () {
      final result = B8.convertBxToB8('8.A');
      expect(result[0][0], equals(Base8Int(10)));
      expect(result[1][0], equals(Base8Int(12)));
    });

    test('handles mixed valid and invalid parts with subdomains', () {
      final result = B8.convertBxToB8('8.O.A');
      expect(result.length, equals(3));
      expect(result[0][0], equals(Base8Int(10)));
      expect(result[1].isEmpty, isTrue);
      expect(result[2][0], equals(Base8Int(12)));
    });

    test('handles invalid base 8 values', () {
      expect(() => Base8Int(8), throwsFormatException);
      expect(() => Base8Int(19), throwsFormatException);
    });
  });

  group('BxSequence Tests', () {
    late BxSequence sequence;

    setUp(() {
      sequence = BxSequence('test_sequence');
    });

    tearDown(() {
      sequence.dispose();
      try {
        final file = File('sequences.db');
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        print('Error cleaning up test database: $e');
      }
    });

    test('creates valid sequence', () {
      expect(sequence.isValidSequence(), isTrue);
    });

    test('handles invalid sequence values correctly', () {
      expect(BxSequence.isValidSequenceValue('O'), isFalse);
      expect(BxSequence.isValidSequenceValue('a'), isTrue);
    });

    test('next value returns valid sequence', () {
      final value = sequence.nextValue();
      expect(value, isNotNull);
      expect(BxSequence.isValidSequenceValue(value!), isTrue);
    });

    test('getCurrentValue returns valid value', () {
      final value = sequence.getCurrentValue();
      expect(value, isNotNull);
    });

    test('reset returns true for successful reset', () {
      expect(sequence.reset(), isTrue);
    });

    test('maintains sequence across instances with error handling', () {
      final firstSequence = BxSequence('persistent');
      final firstValue = firstSequence.nextValue();
      expect(firstValue, isNotNull);

      if (firstValue != null) {
        final firstValueConverted = B10.convertBxToB10(firstValue);
        expect(firstValueConverted[0], isNotEmpty);
        final firstB10 = firstValueConverted[0][0];
        firstSequence.dispose();

        final secondSequence = BxSequence('persistent');
        final nextValue = secondSequence.nextValue();
        expect(nextValue, isNotNull);

        if (nextValue != null) {
          final nextValueConverted = B10.convertBxToB10(nextValue);
          expect(nextValueConverted[0], isNotEmpty);
          final nextB10 = nextValueConverted[0][0];

          expect(nextB10, equals(firstB10 + 1));
        }
        secondSequence.dispose();
      }
    });

    test('handles prepended values correctly', () {
      final value = sequence.nextValue(prepend: 'test');
      expect(value, isNotNull);
      expect(value!.startsWith('test-'), isTrue);

      final converted = B10.convertBxToB10(value);
      expect(converted[0], isNotEmpty);
    });

    test('handles subdomain characters in sequence values', () {
      final value = sequence.nextValue();
      expect(value, isNotNull);

      if (value != null) {
        final withSubdomain = 'parent.$value';
        final converted = B10.convertBxToB10(withSubdomain);
        expect(converted.length, equals(2));
        expect(converted[1], isNotEmpty);
      }
    });

    test('respects minimum sequence value', () {
      final value = sequence.nextValue();
      expect(value, isNotNull);

      if (value != null) {
        final converted = B10.convertBxToB10(value);
        expect(converted[0], isNotEmpty);
        final b10Value = converted[0][0];
        expect(b10Value, greaterThanOrEqualTo(B10.convertBxToB10('A0')[0][0]));
      }
    });

    test('increments sequence correctly', () {
      final first = sequence.nextValue();
      expect(first, isNotNull);

      if (first != null) {
        final firstConverted = B10.convertBxToB10(first)[0][0];

        final second = sequence.nextValue();
        expect(second, isNotNull);

        if (second != null) {
          final secondConverted = B10.convertBxToB10(second)[0][0];
          expect(secondConverted, equals(firstConverted + 1));
        }
      }
    });

    test('resets sequence to minimum value', () {
      sequence.nextValue();
      sequence.nextValue();
      expect(sequence.reset(), isTrue);

      final afterReset = sequence.nextValue();
      expect(afterReset, isNotNull);

      if (afterReset != null) {
        final converted = B10.convertBxToB10(afterReset);
        expect(converted[0], isNotEmpty);
        expect(converted[0][0], equals(B10.convertBxToB10('A0')[0][0]));
      }
    });
  });
}