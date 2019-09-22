part of PatiteParserDart.Parser;

/// A token contains the text and information from a tokenizer.
class Rule {
  Parser _parser;
  Term _term;
  List<Object> _items;

  Rule._(Parser this._parser, Term this._term) {
    this._items = List<Object>();
  }
  
  Rule addTerm(String termName) {
    Term term = this._parser.term(termName);
    this._items.add(term);
    return this;
  }
  
  List<Object> get items => this._items;

  Rule addToken(String tokenName) {
    this._items.add(tokenName);
    return this;
  }

  String toString([int stepIndex = -1]) {
    List<String> parts = new List<String>();
    for (Object item in this._items)
      parts.add(item.toString());
    if (stepIndex >= 0)
      parts.insert(stepIndex, "•");
    return this._term.name + " -> " + parts.join(" ");
  }
}