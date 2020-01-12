part of PatiteParserDart.Parser;

/// An action indicates what to perform for a cell of the parse table.
abstract class _Action {}

/// A shift indicates to put the token into the parse set and move to the next state.
class _Shift implements _Action {

  /// The state number to move to.
  final int state;

  /// Creates a new shift action.
  _Shift(this.state);

  /// Gets the debug string for this action.
  String toString() => "shift ${this.state}";
}

/// A goto indicicates that the current token will be
/// handled by another action and simply move to the next state.
class _Goto implements _Action {

  /// The state number to goto.
  final int state;

  /// Creates a new goto action.
  _Goto(this.state);

  /// Gets the debug string for this action.
  String toString() => "goto ${this.state}";
}

/// A reduce indicates that the current token will be
/// handled by another action and the current rule
/// is used to reduce the parse set down to a term.
class _Reduce implements _Action {

  /// The rule to reduce from the parse set.
  final Grammar.Rule rule;

  /// Creates a new reduce action.
  _Reduce(this.rule);

  /// Gets the debug string for this action.
  String toString() => "reduce ${rule.toString()}";
}

/// An accept indicates that the full input has been
/// checked by the grammar and fits to the grammar.
class _Accept implements _Action {

  /// Creates a new accept action.
  _Accept();

  /// Gets the debug string for this action.
  String toString() => "accept";
}

/// An error indates that the given token can not
/// be processed from the current state.
/// A null action is a generic error, this one gives specific information.
class _Error implements _Action {

  /// The error message to return for this action.
  final String error;

  /// Creates a new error action.
  _Error(this.error);

  /// Gets the debug string for this action.
  String toString() => "error ${this.error}";
}
