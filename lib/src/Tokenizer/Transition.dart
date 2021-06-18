part of PetiteParserDart.Tokenizer;

/// A transition is a matcher group which connects two states together.
/// When at one state this transition should be taken to the next if
/// the next character in the input is a match.
class Transition extends Matcher.Group {
  State? _target;
  bool _consume = false;

  /// Creates a new transition.
  Transition._(this._target): super();

  /// Gets the state to goto if a character matches this transition.
  State? get target => this._target;

  /// Indicates if the character should be consumed (true)
  /// or appended (false) to the resulting string.
  bool get consume => this._consume;
  void set consume(bool consume) { this._consume = consume; }

  /// Gets the string for this transition.
  String toString() => "${this._target?.name}: ${super.toString()}";
}
