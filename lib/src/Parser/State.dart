part of PatiteParserDart.Parser;

class _State {
  int _number;
  List<int> _indices;
  List<Rule> _rules;
  List<Object> _onItems;
  List<_State> _gotos;

  _State(int this._number) {
    this._indices = new List<int>();
    this._rules   = new List<Rule>();
    this._onItems = new List<Object>();
    this._gotos   = new List<_State>();
  }
  
  int get number => this._number;
  List<int> get indices => this._indices;
  List<Rule> get rules => this._rules;
  List<Object> get onItems => this._onItems;
  List<_State> get gotos => this._gotos;

  bool hasRule(int index, Rule rule) {
    for (int i = this._indices.length - 1; i >= 0; i--) {
      if ((this._indices[i] == index) && (this._rules[i] == rule))
        return true;
    }
    return false;
  }

  bool addRule(int index, Rule rule) {
    if (this.hasRule(index, rule)) return false;
    this._indices.add(index);
    this._rules.add(rule);

    if (index < rule.items.length) {
      Object item = rule.items[index];
      if (item is Term) {
        for (Rule rule in item.rules)
          this.addRule(0, rule);
      }
    }
    return true;
  }

  _State findGoto(Object item) {
    for (int i = this._onItems.length - 1; i >= 0; i--) {
      if (this._onItems[i] == item) return this._gotos[i];
    }
    return null;
  }

  bool addGoto(Object item, _State state) {
    if (this.findGoto(item) == state) return false;
    this._onItems.add(item);
    this._gotos.add(state);
    return true;
  }

  bool equals(_State other) {
    if (other._number != this._number) return false;
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

  String toString([String indent = ""]) {
    StringBuffer buf = new StringBuffer();
    buf.writeln("state ${this._number}:");
    for (int i = 0; i < this._rules.length; i++)
      buf.writeln(indent+"  "+this._rules[i].toString(this._indices[i]));
    for (int i = 0; i < this._onItems.length; i++)
      buf.writeln(indent+"  ${this._onItems[i]}: goto state ${this._gotos[i].number}");
    return buf.toString();
  }
}
