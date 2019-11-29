part of PatiteParserDart.Parser;

enum _ActionType {
  Shift,
  Goto,
  Reduce,
  Accept,
  Error
}

class _Action {
  final _ActionType _type;
  final String _error;
  final int _state;
  final Rule _rule;

  _Action._(this._type, this._error, this._state, Rule this._rule);
  
  factory _Action.shift(int state) => new _Action._(_ActionType.Shift, null, state, null);
  factory _Action.goto(int state) => new _Action._(_ActionType.Goto, null, state, null);
  factory _Action.reduce(Rule rule) => new _Action._(_ActionType.Reduce, null, -1, rule);
  factory _Action.accept() => new _Action._(_ActionType.Accept, null, -1, null);
  factory _Action.error(String error) => new _Action._(_ActionType.Error, error, -1, null);
  
  _ActionType get type => this._type;
  String get error => this._error;
  int get state => this._state;
  Rule get rule => this._rule;

  String toString() {
    switch (this._type) {
      case _ActionType.Shift:  return "shift ${this._state}";
      case _ActionType.Goto:   return "goto ${this._state}";
      case _ActionType.Reduce: return "reduce ${this._rule}";
      case _ActionType.Accept: return "accept";
      case _ActionType.Error:  return "error ${this._error}";
    }
    return "unknown";
  }
}
