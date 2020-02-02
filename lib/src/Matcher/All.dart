part of PetiteParserDart.Matcher;

/// A matcher which matches all characters.
/// Since transitions are called in the order they are added
/// this matcher can be used as an "else" matcher.
class All implements Matcher {

  /// Creates a new all character matcher.
  All();

  /// Determines if this matcher matches the given character, [c].
  /// In this case it always returns true.
  bool match(int c) => true;

  /// Returns the string for this matcher.
  String toString() => "all";
}
