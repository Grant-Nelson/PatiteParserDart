part of PatiteParserDart.Grammar;

/// A trigger is an optional item which can be added
/// to a parse that is carried through to the parse results.
/// The triggers can used when compiling or interpreting.
class Trigger extends Item {

  /// Creates a new trigger.
  Trigger(String name): super._(name);

  /// Gets the string for this trigger.
  String toString() => "{${this.name}}";
}
