# dart56
Dart base 56 library for converting base10 (and base 8) numbers to / from base 56 for use as small, readable and usually HTML-ID safe sequences.  Base 56 is arbitary, as the character set can be shrunk or expanded in the library as a configuration setting.  Base56 is handy because it ecludes OILoil from the set which can be mistaken for zeros and ones.

IDs can be made HTML safe through the addition of prepended strings, which also serves expanding or classifying IDs that might need to be found and operated on by functions where type matters but checking type is slower than you'd like.

Just drop into src in your dart project and reference.  It should work in most dart and flutter projects.
