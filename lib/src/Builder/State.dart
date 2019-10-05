part of PatiteParserDart.Builder;

class State {
  Object _item;
  List<int> _indices;
  List<Rule> _rules;

  State(Object this._item) {
    this._indices = new List<int>();
    this._rules = new List<Rule>();
  }

  String toString() {
    StringBuffer buf = new StringBuffer();
    buf.writeln(this._item);
    for (int i = 0; i < this._rules.length; i++)
      buf.writeln(this._rules[i].toString(this._indices[i]));
    return buf.toString();
  }
}
