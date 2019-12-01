part of PatiteParserDart.Grammar;

/// A rule is a single definition from a grammar.
/// 
/// For example `<T> => "(" <E> ")"`. The term for the rule is
/// the left hand side (`T`) while the items are the parts on the right hand size.
/// The items are made up of tokens (`(`, `)`) and the rule's term or other terms (`E`).
/// The order of the items defines how this rule in the grammer is to be used.
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
  
  /// Gets the left hand side term to the rule.
  Term get term => this._term;

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