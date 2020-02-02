part of PetiteParserDart.Matcher;

/// Creates a range matcher.
class Range implements Matcher {

  /// The lowest character value included in this range.
  final int low;

  /// The highest character value included in this range.
  final int high;

  /// Creates a new range matcher.
  Range._(this.low, this.high);

  /// Creates a new range matcher for the given inclusive range.
  /// The given strings may only contain one character.
  factory Range(String lowChar, String highChar) {
    if ((lowChar.length != 1) || (highChar.length != 1))
      throw new Exception("The given low and high character strings for a Range must have one and only one characters.");
    int low  = lowChar.codeUnitAt(0);
    int high = highChar.codeUnitAt(0);
    return new Range.fromCodeUnits(low, high);
  }

  /// Creates a new range matcher for the given inclusive range.
  /// The given values are the code units for the characters.
  factory Range.fromCodeUnits(int low, int high) {
    if (low > high) {
      int temp = low;
      low = high;
      high = temp;
    }
    return new Range._(low, high);
  }

  /// Determines if this matcher matches the given character, [c].
  /// Returns true if the caracter is inclusively in the given range, false otherwise.
  bool match(int c) => (this.low <= c) && (this.high >= c);

  /// Returns the string for this matcher.
  String toString() {
    String low = new String.fromCharCode(this.low);
    String high = new String.fromCharCode(this.high);
    return "$low..$high";
  }
}
