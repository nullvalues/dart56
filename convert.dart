import 'lib/bX.dart';

void main() {
   // Basic conversion examples
   print('\nBasic conversions:');
   final bxValue = 'z';
   final b10Value = B10.convertBxToB10(bxValue);
   print('bx: $bxValue -> b10: $b10Value');

   final bxValueBack = B10.convertB10ToBx(b10Value);
   print('b10: $b10Value -> bx: $bxValueBack');

   // Prepend examples
   print('\nPrepend examples:');
   final withCustomPrepend = B10.convertB10ToBx(55, prepend: 'user');
   print('With custom prepend: $withCustomPrepend');

   final withDefaultPrepend = B10.convertB10ToBx(55, useDefaultPrepend: true);
   print('With default prepend: $withDefaultPrepend');

   // Converting prepended values back
   final prependedValue = 'user-z';
   final convertedPrepended = B10.convertBxToB10(prependedValue);
   print('Converting prepended value ($prependedValue) -> $convertedPrepended');

   // Converting prepended values back
   final withDefaultPrependedValue = 'X-z';
   final convertedDefaultPrepended = B10.convertBxToB10(prependedValue);
   print('Converting prepended value ($withDefaultPrependedValue) -> $convertedDefaultPrepended');

   // Base8 conversions with prepend
   print('\nBase8 examples:');
   final b8Value = Base8Int(55);  // 52 in base 8 = 42 in base 10
   final b8ToBx = B8.convertB8ToBx(b8Value, prepend: 'oct');
   print('b8(55) -> bx with prepend: $b8ToBx');

   final bxToB8 = B8.convertBxToB8(b8ToBx);
   print('Converting back to b8: $bxToB8');

   // Fixed-width random values
   print('\nFixed-width random values:');
   for (int i = 1; i <= 4; i++) {
      final bxLength = 3;
      final randomValue = B10.generateRandomBxValue(bxLength);
      print('Random 2-digit value $i: $randomValue');
   }

   print('\nHTML ID-safe random values:');
   for (int i = 1; i <= 4; i++) {
      final randomValue = B10.generateRandomBxValue(2, forceLetterFirst: true);
      print('HTML ID-safe random value $i: $randomValue');
   }

   print('\nJoined bX values:');
   final childValue = B10.convertB10ToBx(42);
   final joinedWithRandom = B10.joinBxValues(childValue);
   print('With random parent: $joinedWithRandom');

   final joinedWithParent = B10.joinBxValues(childValue, parent: 'nullValues');
   print('With specified parent: $joinedWithParent');
   print('You might use this feature for tenant separation.');

   print('\nSequence examples with minimum value:');
   final userSeq = BxSequence('users');
   try {
      print('First value (respects seqStartValue): ${userSeq.nextValue(prepend: "0h10")}');
      print('Second value: ${userSeq.nextValue(prepend: "0h10")}');
      print('Current value: ${userSeq.getCurrentValue()}');

      // You might want to be able to reset the value with each run, but we have that turned off.
      //userSeq.reset();
      //print('After reset (respects seqStartValue): ${userSeq.nextValue(prepend: "user")}');
   } finally {
      userSeq.dispose();
   }
}