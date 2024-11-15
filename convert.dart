import 'lib/bX.dart';

void main() {
   // Basic conversion examples
   print('\nBasic conversions:');
   final bxValue = 'a0';
   final b10Value = B10.convertBxToB10(bxValue);
   print('bx: $bxValue -> b10: ${b10Value.isEmpty ? "invalid" : b10Value[0][0]}');

   final bxValueBack = B10.convertB10ToBx(b10Value[0][0]);
   print('b10: ${b10Value[0][0]} -> bx: $bxValueBack');

   // Error handling examples
   print('\nError handling examples:');
   final invalidChar = 'O';  // 'O' is in removeChars
   final invalidResult = B10.convertBxToB10(invalidChar);
   print('Invalid char "$invalidChar" conversion result: $invalidResult');
   print('Notice how it returns [[]], allowing graceful handling');

   // Subdomain examples
   print('\nSubdomain handling:');
   final subdomainValue = 'a.0.c';
   final subdomainResult = B10.convertBxToB10(subdomainValue);
   print('Subdomain value "$subdomainValue" converts to: $subdomainResult');

   final mixedValue = 'a.O.c';  // Middle part is invalid
   final mixedResult = B10.convertBxToB10(mixedValue);
   print('Mixed valid/invalid "$mixedValue" converts to: $mixedResult');

   // Prepend examples with new error handling
   print('\nPrepend examples with error handling:');
   final withCustomPrepend = B10.convertB10ToBx(522230630, prepend: 'nullValues');
   print('With custom prepend: $withCustomPrepend');

   final invalidPrependedValue = 'user-O';
   final convertedInvalidPrepended = B10.convertBxToB10(invalidPrependedValue);
   print('Converting invalid prepended value ($invalidPrependedValue) -> $convertedInvalidPrepended');

   final validPrependedValue = 'user-k';
   final convertedValidPrepended = B10.convertBxToB10(validPrependedValue);
   print('Converting valid prepended value ($validPrependedValue) -> $convertedValidPrepended');

   // Base8 conversions with new error handling
   print('\nBase8 examples with error handling:');
   final b8Value = Base8Int(52);  // 52 in base 8 = 42 in base 10
   final b8ToBx = B8.convertB8ToBx(b8Value, prepend: 'oct');
   print('b8(52) -> bx with prepend: $b8ToBx');

   final validBxToB8 = B8.convertBxToB8(b8ToBx);
   print('Converting back to b8: ${validBxToB8[0][0]}');

   final invalidB8Conversion = B8.convertBxToB8('O');
   print('Invalid bx to b8 conversion: $invalidB8Conversion');

   final mixedB8Conversion = B8.convertBxToB8('g.O.h');
   print('Mixed valid/invalid bx to b8 conversion: $mixedB8Conversion');

   // Incrementing bX values with error handling
   print('\nIncrementing bX values with error handling:');
   final baseValue = '0h10';
   print('Base value: $baseValue');

   final nextValue = B10.incrementBxValue(baseValue);
   if (nextValue != null) {
      print('Next value: $nextValue');
      final nextValueAgain = B10.incrementBxValue(nextValue);
      print('Next value again: $nextValueAgain');
   } else {
      print('Invalid base value, increment failed');
   }

   final invalidTry = 'o';
   final invalidIncrement = B10.incrementBxValue(invalidTry);
   print('Trying to increment invalid value ($invalidTry): ${invalidIncrement ?? "increment failed"}');

   // Sequence examples with error handling
   print('\nSequence examples with error handling:');
   final userSeq = BxSequence('users');
   try {
      final firstValue = userSeq.nextValue(prepend: "user");
      if (firstValue != null) {
         print('First value: $firstValue');
         final firstValueConverted = B10.convertBxToB10(firstValue);
         print('First value converted: $firstValueConverted');

         final secondValue = userSeq.nextValue(prepend: "user");
         if (secondValue != null) {
            print('Second value: $secondValue');
         }
      }

      final currentValue = userSeq.getCurrentValue();
      if (currentValue != null) {
         print('Current value: $currentValue');
      }

      // Demonstrating sequence with subdomains
      final subdomainSeq = userSeq.nextValue();
      if (subdomainSeq != null) {
         final withSubdomain = "a0.$subdomainSeq";
         final subdomainConverted = B10.convertBxToB10(withSubdomain);
         print('Subdomain sequence conversion: $subdomainConverted');
      }

   } finally {
      userSeq.dispose();
   }

   // Safety handling examples
   print('\nSafety handling examples:');
   void handleBxConversion(String value) {
      final result = B10.convertBxToB10(value);
      if (result.isEmpty) {
         print('Conversion failed completely');
         return;
      }

      for (var i = 0; i < result.length; i++) {
         if (result[i].isEmpty) {
            print('Part $i is invalid');
         } else {
            print('Part $i converts to: ${result[i][0]}');
         }
      }
   }

   print('\nHandling various cases:');
   handleBxConversion('a.b.c');        // All valid
   handleBxConversion('a.O.c');        // Mixed valid/invalid
   handleBxConversion('O');            // Invalid
   handleBxConversion('user-k.a0');   // Prepended with subdomain
}