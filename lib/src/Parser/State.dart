part of PatiteParserDart.Parser;

/// This is a state in the parser builder.
/// The state is a collection of rules with offset indices.
/// These states are used for generating the parser table.
class _State {
  List<int> _indices;
  List<Grammar.Rule> _rules;
  List<Grammar.Item> _onItems;
  List<_State> _gotos;
  bool _accept;

  /// This is the index of the state in the builder.
  final int number;

  /// Creates a new state for the parser builder.
  _State(this.number) {
    this._indices = new List<int>();
    this._rules   = new List<Grammar.Rule>();
    this._onItems = new List<Grammar.Item>();
    this._gotos   = new List<_State>();
    this._accept  = false;
  }
  
  /// The indices which indicated the offset into the matching rule.
  List<int> get indices => this._indices;
  
  /// The rules for this state which meatch up with the indices.
  List<Grammar.Rule> get rules => this._rules;

  /// This is the items which connect two states together.
  /// This matches with the goto values to create a connection.
  List<Grammar.Item> get onItems => this._onItems;

  /// This is the goto which indicates which state to go to for the matched items. 
  /// This matches with the `onItems` to create a connection.
  List<_State> get gotos => this._gotos;

  /// Indicates if this state can acceptance for this grammar.
  bool get hasAccept => this._accept;

  /// Sets this state as an accept state for the grammar.
  void setAccept() => this._accept = true;

  /// Checks if the given index and rule exist in this state.
  bool hasRule(int index, Grammar.Rule rule) {
    for (int i = this._indices.length - 1; i >= 0; i--) {
      if ((this._indices[i] == index) && (this._rules[i] == rule))
        return true;
    }
    return false;
  }

  /// Adds the given index and rule to this state.
  /// Returns false if it already exists, true if added.
  bool addRule(int index, Grammar.Rule rule) {
    if (this.hasRule(index, rule)) return false;
    this._indices.add(index);
    this._rules.add(rule);

    if (index < rule.items.length) {
      Grammar.Item item = rule.items[index];
      if (item is Grammar.Term) {
        for (Grammar.Rule rule in item.rules)
          this.addRule(0, rule);
      }
    }
    return true;
  }

  /// Finds the go to state from the given item,
  /// null is returned if none is found.
  _State findGoto(Grammar.Item item) {
    for (int i = this._onItems.length - 1; i >= 0; i--) {
      if (this._onItems[i] == item) return this._gotos[i];
    }
    return null;
  }

  /// Adds a goto connection on the given item to the given state.
  bool addGoto(Grammar.Item item, _State state) {
    if (this.findGoto(item) == state) return false;
    this._onItems.add(item);
    this._gotos.add(state);
    return true;
  }

  /// Determines if this state is equal to the given state.
  bool equals(_State other) {
    if (other.number != this.number) return false;
    if (other._indices.length != this._indices.length) return false;
    if (other._onItems.length != this._onItems.length) return false;
    for (int i = this._indices.length - 1; i >= 0; i--) {
      if (!this.hasRule(other._indices[i], other._rules[i])) return false;
    }
    for (int i = this._onItems.length - 1; i >= 0; i--) {
      if (this.findGoto(other._onItems[i]) != other._gotos[i]) return false;
    }
    return true;
  }

  /// Gets a string for this state for debugging the builder.
  String toString([String indent = ""]) {
    StringBuffer buf = new StringBuffer();
    buf.writeln("state ${this.number}:");
    for (int i = 0; i < this._rules.length; i++)
      buf.writeln(indent+"  "+this._rules[i].toString(this._indices[i]));
    for (int i = 0; i < this._onItems.length; i++)
      buf.writeln(indent+"  ${this._onItems[i]}: goto state ${this._gotos[i].number}");
    return buf.toString();
  }
}
