part of PatiteParserDart.Parser;

/// This is a builder used to generate a parser giving a grammar.
class _Builder {
  Grammar _grammar;
  List<_State> _states;
  Set<Object> _items;
  _Table _table;

  /// Constructs of a new parser builder.
  _Builder(this._grammar) {
    this._states = new List<_State>();
    this._items = new Set<Object>();
    this._table = new _Table();

    for (Term term in this._grammar.terms) {
      for (Rule rule in term.rules)
        this._items.addAll(rule.items);
    }
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
        if (item.toString() == this._grammar.acceptToken) {
          state.setAccept();
        } else {
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
    }
    return changed;
  }

  void fillTable() {
    for (_State state in this._states) {
      if (state.hasAccept)
        this._table.write(state.number, this._grammar.acceptToken, new _Action.accept());
      
      for (int i = 0; i < state.rules.length; i++) {
        Rule rule = state.rules[i];
        int index = state.indices[i];
        if (rule.items.length <= index) {
          // TODO: use follows
          _Action action = new _Action.reduce(rule);
          for (Object item in this._items)
            this._table.write(state.number, item, action);
        }
      }

      for (int i = 0; i < state.gotos.length; i++) {
        Object onItem = state.onItems[i];
        int goto = state.gotos[i].number;
        _Action action;
        if (onItem is Term) action = new _Action.goto(goto);
        else                action = new _Action.shift(goto);
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
    buf.writeln();
    buf.writeln(this._table.toString());
    return buf.toString();
  }
}