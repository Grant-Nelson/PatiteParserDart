part of PatiteParserDart.Parser;

/// This is a builder used to generate a parser giving a grammar.
class _Builder {
  Grammar.Grammar _grammar;
  List<_State> _states;
  Set<Grammar.Item> _items;
  _Table _table;
  StringBuffer _errors;

  /// Constructs of a new parser builder.
  _Builder(Grammar.Grammar this._grammar) {
    Grammar.Term oldStart = this._grammar.startTerm;
    this._grammar.start(_startTerm);
    this._grammar.newRule(_startTerm).addTerm(oldStart.name).addToken(_eofTokenName);

    this._states = new List<_State>();
    this._items = new Set<Grammar.Item>();
    this._table = new _Table();
    this._errors = new StringBuffer();

    for (Grammar.Term term in this._grammar.terms) {
      this._items.add(term);
      for (Grammar.Rule rule in term.rules) {
        for (Grammar.Item item in rule.items) {
          if (item is! Grammar.Trigger) this._items.add(item);
        }
      }
    }
  }
  
  /// Finds a state with the given offset index for the given rule.
  _State find(int index, Grammar.Rule rule) {
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
    for (Grammar.Rule rule in this._grammar.startTerm.rules)
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
      Grammar.Rule rule = state.rules[i];
      List<Grammar.Item> items = rule.basicItems;
      if (index < items.length) {
        Grammar.Item item = items[index];

        if ((item is Grammar.TokenItem) && (item.name == _eofTokenName)) {
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
        Grammar.Rule rule = state.rules[i];
        int index = state.indices[i];
        List<Grammar.Item> items = rule.basicItems;
        if (items.length <= index) {

          List<Grammar.TokenItem> follows = rule.term.determineFollows();
          if (follows.length > 0) {
            // Add the reduce action to all the follow items.
            _Reduce reduce = new _Reduce(rule);
            for (Grammar.TokenItem follow in follows)
              this._table.writeShift(state.number, follow.name, reduce);
          }
        }
      }

      for (int i = 0; i < state.gotos.length; i++) {
        Grammar.Item onItem = state.onItems[i];
        int goto = state.gotos[i].number;
        if (onItem is Grammar.Term)
          this._table.writeGoto(state.number, onItem.name, new _Goto(goto));
        else this._table.writeShift(state.number, onItem.name, new _Shift(goto));
      }
    }

    // Check for goto loops.
    for (Grammar.Term term in this._grammar.terms) {
      List<int> checked = new List<int>();
      for (int i = 0; i < this._states.length; i++) {
        if (checked.contains(i)) continue;
        checked.add(i);

        _Action action = this._table.readGoto(i, term.name);
        List<int> reached = new List<int>();
        while (action is _Goto) {
          reached.add(i);
          checked.add(i);
          i = (action as _Goto).state;
          if (reached.contains(i)) {
            List<int> loop = reached.sublist(reached.indexOf(i));
            this._errors.writeln('Infinite goto loop found in term ${term.name} between the state(s) $loop.');
            break;
          }
          action = this._table.readGoto(i, term.name);
        }
      }
    }
  }

  /// Gets all the error which occurred during the build,
  /// or an empty string if no error occurred.
  String get buildErrors => this._errors.toString();
  
  /// The table from the builder.
  _Table get table => this._table;

  /// Returns a human readable string for debugging of the parser being built.
  String toString({bool showState: true, bool showTable: true, bool showError: true}) {
    StringBuffer buf = new StringBuffer();
    if (showState) {
      for (_State state in this._states)
        buf.write(state.toString());
    }
    if (showTable) {
      if (buf.isNotEmpty) buf.writeln();
      buf.writeln(this._table.toString());
    }
    if ((showError) && (this._errors.isNotEmpty)) {
      if (buf.isNotEmpty) buf.writeln();
      buf.write(this._errors.toString());
    }
    return buf.toString();
  }
}
