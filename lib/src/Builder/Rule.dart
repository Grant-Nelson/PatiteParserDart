part of PatiteParserDart.Builder;

class Rule {
  Builder _builder;
  Term _term;
  List<Object> _items;

  Rule(Builder this._builder, Term this._term) {
    this._items = List<Object>();
  }
  
  /// Gets all the term and token for this rule.
  /// The terms and tokens are in the order defined by this rule.
  List<Object> get items => this._items;
  
  /// Gets the string for this rule.
  /// Has an optional step index for showing the different
  /// states of the parser generator.
  String toString([int stepIndex = -1]) {
    List<String> parts = new List<String>();
    for (Object item in this._items)
      parts.add(item.toString());
    if ((stepIndex >= 0) && (stepIndex <= parts.length))
      parts.insert(stepIndex, "•");
    return this._term.name + " -> " + parts.join(" ");
  }
}