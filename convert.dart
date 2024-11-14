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
   final withCustomPrepend = B10.convertB10ToBx(522230638, prepend: 'nullValues');
   print('With custom prepend: $withCustomPrepend');
   print('You might use this feature for tenant separation.  Note that the prepended string is not a valid bX value.');

   final withDefaultPrepend = B10.convertB10ToBx(42, useDefaultPrepend: true);
   print('With default prepend: $withDefaultPrepend');

   // Converting prepended values back
   final prependedValue = 'user-k';
   final convertedPrepended = B10.convertBxToB10(prependedValue);
   print('Converting prepended value ($prependedValue) -> $convertedPrepended');

   // Base8 conversions with prepend
   print('\nBase8 examples:');
   final b8Value = Base8Int(52);  // 52 in base 8 = 42 in base 10
   final b8ToBx = B8.convertB8ToBx(b8Value, prepend: 'oct');
   print('b8(52) -> bx with prepend: $b8ToBx');

   final bxToB8 = B8.convertBxToB8(b8ToBx);
   print('Converting back to b8: $bxToB8');

   // Incrementing bX values
   print('\nIncrementing bX values:');
   final baseValue = '0h10';
   print('Base value: $baseValue');
   print('This is intentional, showing drop of placeholder 0.');
   final nextValue = B10.incrementBxValue(baseValue);
   print('Next value: $nextValue');
   final nextValueAgain = B10.incrementBxValue(nextValue);
   print('Next value again: $nextValueAgain');
   final prependValueIncrement = "nullValues-x5fz";
   final nextPrependValue = B10.incrementBxValue(prependValueIncrement);
   print('Base value $prependValueIncrement becomes: $nextPrependValue');

   // Sequence examples
   print('\nSequence examples with minimum value:');
   final userSeq = BxSequence('users');
   try {
      print('First value (respects seqStartValue on first run (or after tests are run): ${userSeq.nextValue(prepend: "user")}');
      print('Second value: ${userSeq.nextValue(prepend: "user")}');
      print('Current value: ${userSeq.getCurrentValue()}');

      // you might want to turn this on, but in this example we're letting the autoinc values persist between runs
      //userSeq.reset();
      //print('After reset (respects seqStartValue): ${userSeq.nextValue(prepend: "user")}');
   } finally {
      userSeq.dispose();
   }
}