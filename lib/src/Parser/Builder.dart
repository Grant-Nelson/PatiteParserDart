part of PatiteParserDart.Parser;

/// This is a builder used to generate a parser giving a grammar.
class _Builder {
  Grammar _grammar;
  List<_State> _states;
  _Table _table;

  /// Constructs of a new parser builder.
  _Builder(this._grammar) {
    this._states = new List<_State>();
    this._table = new _Table();
  }
  
  _State find(int index, Rule rule) {
    for (_State state in this._states) {
      for (int i = 0; i < state.indices.length; i++) {
        if ((state.indices[i] == index) &&
            (state.rules[i] == rule)) return state;
      }
    }
    return null;
  }

  void determineStates() {
    _State startState = new _State(0);
    for (Rule rule in this._grammar.startTerm.rules)
      startState.addRule(0, rule);
    this._states.add(startState);
    List<_State> changed = List<_State>()
      ..add(startState);

    while (changed.isNotEmpty) {
      _State state = changed.removeLast();
      changed.addAll(this.nextStates(state));
    }
  }

  List<_State> nextStates(_State state) {
    List<_State> changed = new List<_State>();
    for (int i = 0; i < state.indices.length; i++) {
      int index = state.indices[i];
      Rule rule = state.rules[i];
      if (index < rule.items.length) {
        Object item = rule.items[index];
        if (item.toString() == '\$') continue;

        _State next = state.findGoto(item);
        if (next == null) {
          next = this.find(index+1, rule);
          if (next == null) {
            next = new _State(this._states.length);
            this._states.add(next);
          }
          state.addGoto(item, next);
        }

        if (next.addRule(index+1, rule)) {
          changed.add(next);
        }
      }
    }
    return changed;
  }

  void fillTable() {
    for (_State state in this._states) {
      for (int i = 0; i < state.gotos.length; i++) {
        Object onItem = state.onItems[i];
        _State goto = state.gotos[i];
        _Action action;
        if (onItem is Term) action = new _Action.goto(goto.number);
        else                action = new _Action.shift(goto.number);
        this._table.write(state.number, onItem, action);
      }
    }
  }

  // Returns a human readable string for debugging of the parser being built.
  String toString() {
    StringBuffer buf = new StringBuffer();
    for (_State state in this._states) {
       buf.write(state.toString());
    }
    buf.writeln(this._table.toString());
    return buf.toString();
  }
}