import 'lib/bX.dart';

void main() {

   final bxValue = 'z';
   final b10Value = B10.convertBxToB10(bxValue);
   print(b10Value);
   final bxValueBack = B10.convertB10ToBx(b10Value);
   print(bxValue);
}
