// File: test/bx_test.dart
import 'dart:io';

import 'package:test/test.dart';
import 'package:dart56/bX.dart';

void main() {
  group('B10 Tests', () {
    test('converts base 10 to bX correctly', () {
      expect(B10.convertB10ToBx(0), equals('0'));
      expect(B10.convertB10ToBx(55), equals('z'));
      expect(B10.convertB10ToBx(56), equals('10'));
    });

    test('converts bX to base 10 correctly', () {
      expect(B10.convertBxToB10('0'), equals(0));
      expect(B10.convertBxToB10('z'), equals(55));
      expect(B10.convertBxToB10('10'), equals(56));
    });

    test('handles prepends correctly', () {
      final value = B10.convertB10ToBx(42, prepend: 'test');
      expect(value.startsWith('test-'), isTrue);
      expect(B10.convertBxToB10(value), equals(42));
    });

    test('handles default prepend', () {
      final value = B10.convertB10ToBx(42, useDefaultPrepend: true);
      expect(value.startsWith('X-'), isTrue);
      expect(B10.convertBxToB10(value), equals(42));
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
      final joined = B10.joinBxValues('child', parent: 'parent');
      expect(joined, equals('parent.child'));
    });

    test('generates random parent for joining when not provided', () {
      final joined = B10.joinBxValues('child');
      expect(joined.contains('.'), isTrue);
      expect(joined.split('.')[1], equals('child'));
    });
  });

  group('B8 Tests', () {
    test('converts base 8 to bX correctly', () {
      final b8 = Base8Int(52);  // 52 in base 8 = 42 in base 10
      final bx = B8.convertB8ToBx(b8);
      expect(B10.convertBxToB10(bx), equals(42));
    });

    test('converts bX to base 8 correctly', () {
      final bx = B10.convertB10ToBx(42);
      final b8 = B8.convertBxToB8(bx);
      expect(b8.toDecimal(), equals(42));
    });

    test('handles invalid base 8 values', () {
      expect(() => Base8Int(8), throwsFormatException);
      expect(() => Base8Int(19), throwsFormatException);
    });
  });

  group('BxSequence Tests', () {
    late BxSequence sequence;
    late String dbPath;

    setUp(() {
      sequence = BxSequence('test_sequence');
      dbPath = 'sequences.db';
    });

    tearDown(() {
      sequence.dispose();
      try {
        final file = File(dbPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        print('Error cleaning up test database: $e');
      }
    });

    test('maintains sequence across instances', () {
      final firstSequence = BxSequence('persistent');
      final firstValue = B10.convertBxToB10(firstSequence.nextValue());
      firstSequence.dispose();

      final secondSequence = BxSequence('persistent');
      final nextValue = B10.convertBxToB10(secondSequence.nextValue());
      expect(nextValue, equals(firstValue + 1));
      secondSequence.dispose();
    });

    test('respects minimum sequence value', () {
      final firstValue = sequence.nextValue();
      expect(B10.convertBxToB10(firstValue),
          greaterThanOrEqualTo(B10.convertBxToB10('A0')));
    });

    test('increments sequence correctly', () {
      final first = B10.convertBxToB10(sequence.nextValue());
      final second = B10.convertBxToB10(sequence.nextValue());
      expect(second, equals(first + 1));
    });

    test('resets sequence to minimum value', () {
      sequence.nextValue();
      sequence.nextValue();
      sequence.reset();
      final afterReset = sequence.nextValue();
      expect(B10.convertBxToB10(afterReset),
          equals(B10.convertBxToB10('A0')));
    });

    test('handles prepends in sequences', () {
      final value = sequence.nextValue(prepend: 'seq');
      expect(value.startsWith('seq-'), isTrue);
    });
  });
}