part of PatiteParserDart.Parser;

class _Action {
  final String _error;
  final bool _shift;
  final int _state;

  _Action._(this._error, this._shift, this._state);
  
  factory _Action.shift(int state) => new _Action._(null, true, state);
  factory _Action.goto(int state) => new _Action._(null, false, state);
  factory _Action.error(String error) => new _Action._(error, false, -1);
  
  bool get isError => this._error?.isNotEmpty ?? false;
  bool get isShift => !isError && this._shift;
  bool get isGoto => !isError && !this._shift;

  String get error => this._error;
  int get state => this._state;

  String toString() {
    if (this.isError) return this._error;
    if (this._shift) return "shift ${this.state}";
    return "goto ${this.state}";
  }
}
