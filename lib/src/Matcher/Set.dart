part of PetiteParserDart.Matcher;

/// A matcher which matchs a set of characters.
class Set implements Matcher {
  List<int> _set;

  /// Creates a set matcher for all the characters in the given string.
  /// The set must contain at least one character.
  factory Set(String charSet) {
    return new Set.fromCodeUnits(charSet.codeUnits);
  }

  /// Creates a set matcher with a given list of code units.
  /// The set must contain at least one character.
  Set.fromCodeUnits(Iterable<int> charSet) {
    if (charSet.length <= 0)
      throw new Exception("May not create a Set with zero characters.");
    Map<int, bool> map = new Map<int, bool>();
    for (int char in charSet) map[char] = true;
    List<int> reducedSet = new List<int>.from(map.keys);
    reducedSet.sort();
    this._set = reducedSet;
  }

  /// Determines if this matcher matches the given character, [c].
  /// Returns true if the given character is in the set, false otherwise.
  bool match(int c) => this._set.contains(c);

  /// Returns the string for this matcher.
  String toString() => new String.fromCharCodes(this._set);
}
