part of PatiteParserDart.Parser;

/// This is a builder used to generate a parser giving a grammar.
class _Builder {
  Grammar _grammar;
  List<_State> _states;
  Set<Object> _items;
  _Table _table;
  StringBuffer _errors;

  /// Constructs of a new parser builder.
  _Builder(Grammar grammar) {
    this._grammar = grammar.copy();
    Term oldStart = this._grammar.startTerm;
    this._grammar.start(_startTerm);
    this._grammar.newRule(_startTerm).addTerm(oldStart.name).addToken(_eofTokenName);

    this._states = new List<_State>();
    this._items = new Set<Object>();
    this._table = new _Table();
    this._errors = new StringBuffer();

    for (Term term in this._grammar.terms) {
      for (Rule rule in term.rules)
        this._items.addAll(rule.items);
    }
  }
  
  /// Finds a state with the given offset index for the given rule.
  _State find(int index, Rule rule) {
    for (_State state in this._states) {
      for (int i = 0; i < state.indices.length; i++) {
        if ((state.indices[i] == index) &&
            (state.rules[i] == rule)) return state;
      }
    }
    return null;
  }

  /// Determines all the parser states for the grammar.
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

  /// Determines the next states following the given state.
  List<_State> nextStates(_State state) {
    List<_State> changed = new List<_State>();
    for (int i = 0; i < state.indices.length; i++) {
      int index = state.indices[i];
      Rule rule = state.rules[i];
      if (index < rule.items.length) {
        Object item = rule.items[index];
        if (item.toString() == _eofTokenName) {
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

  /// Fills the parse table with the information from the states.
  void fillTable() {
    for (_State state in this._states) {
      if (state.hasAccept)
        this._table.writeShift(state.number, _eofTokenName, new _Accept());
      
      for (int i = 0; i < state.rules.length; i++) {
        Rule rule = state.rules[i];
        int index = state.indices[i];
        if (rule.items.length <= index) {
          List<Object> items = rule.term.determineFollows();
          if (items.length > 0) {
            List<String> ruleItems = new List<String>();
            for (Object item in rule.items) {
              if (item is Term) ruleItems.add(item.name);
              else ruleItems.add(item as String);
            }
            _Reduce action = new _Reduce(rule.term.name, List<String>.unmodifiable(ruleItems));
            for (Object item in items)
              this._table.writeShift(state.number, item, action);
          }
        }
      }

      for (int i = 0; i < state.gotos.length; i++) {
        Object onItem = state.onItems[i];
        int goto = state.gotos[i].number;
        if (onItem is Term) {
          if (state.number == goto)
            this._errors.writeln('Goto $goto on row ${state.number} and column ${onItem.name} will cause infinate loop.');
          this._table.writeGoto(state.number, onItem.name, new _Goto(goto));
        } else this._table.writeShift(state.number, onItem as String, new _Shift(goto));
      }
    }
  }

  /// Gets all the error which occurred during the build,
  /// or an empty string if no error occurred.
  String get buildErrors => this._errors.toString();
  
  /// The table from the builder.
  _Table get table => this._table;

  /// Returns a human readable string for debugging of the parser being built.
  String toString() {
    StringBuffer buf = new StringBuffer();
    for (_State state in this._states) {
       buf.write(state.toString());
    }
    buf.writeln();
    buf.writeln(this._table.toString());
    if (this._errors.isNotEmpty) {
      buf.writeln();
      buf.write(this._errors.toString());
    }
    return buf.toString();
  }
}
