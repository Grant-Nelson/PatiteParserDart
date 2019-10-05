part of PatiteParserDart.Grammar;

/// A rule is a single definition from a grammar.
class Rule {
  Grammar _grammar;
  Term _term;
  List<Object> _items;

  /// Creates a new rule for the the given grammar and term.
  Rule._(Grammar this._grammar, Term this._term) {
    this._items = List<Object>();
  }
  
  /// Adds a term to this rule.
  /// This will get or create a new term to the grammar.
  /// Returns this rule so that rule creation can be chained.
  Rule addTerm(String termName) {
    Term term = this._grammar.term(termName);
    this._items.add(term);
    return this;
  }

  /// Adds a token to this rule.
  /// Returns this rule so that rule creation can be chained.
  Rule addToken(String tokenName) {
    this._items.add(tokenName);
    return this;
  }
  
  /// Gets all the term and token for this rule.
  /// The terms and tokens are in the order defined by this rule.
  List<Object> get items => this._items;

  /// Gets the string for this rule.
  String toString() {
    List<String> parts = new List<String>();
    for (Object item in this._items)
      parts.add(item.toString());
    return this._term.name + " -> " + parts.join(" ");
  }
}