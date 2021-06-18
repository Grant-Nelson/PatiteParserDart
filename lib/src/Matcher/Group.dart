part of PetiteParserDart.Matcher;

/// A group of matchers for matching complicated sets of characters.
class Group implements Matcher {
  List<Matcher> _matchers = [];

  /// Creates a new matcher group.
  Group();

  /// Gets the list of matchers in this group.
  List<Matcher> get matchers => this._matchers;

  /// Determines if this matcher matches the given character, [c].
  /// If any matcher matches the given character true is returned.
  bool match(int c) {
    for (Matcher matcher in this._matchers) {
      if (matcher.match(c)) return true;
    }
    return false;
  }

  /// Adds a matcher to this group.
  Matcher add(Matcher matcher) {
    this._matchers.add(matcher);
    return matcher;
  }

  /// Adds a character set matcher to this group.
  Set addSet(String charSet) =>
    this.add(new Set(charSet)) as Set;

  /// Adds a range of characters to match to this group.
  Range addRange(String lowChar, String highChar) =>
    this.add(new Range(lowChar, highChar)) as Range;

  /// Adds a matcher to match all characters.
  All addAll() => this.add(new All()) as All;

  /// Adds a not matcher group.
  Not addNot() => this.add(new Not()) as Not;

  /// Returns the string for this matcher.
  String toString() {
    String str = "";
    for (Matcher matcher in this._matchers) {
      if (str.isNotEmpty) str += ", ";
      str += matcher.toString();
    }
    return str;
  }
}
