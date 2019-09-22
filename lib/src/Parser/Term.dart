part of PatiteParserDart.Parser;

class Term {
  Parser _parser;
  String _name;
  List<Rule> _rules;
  List<String> _firsts;

  Term._(Parser this._parser, String this._name) {
    this._rules = new List<Rule>();
    this._firsts = null;
  }
  
  /// Gets the name of the term.
  String get name => this._name;

  List<Rule> get rules => this._rules;

  List<String> get firsts => this._firsts;

  Rule newRule() {
    Rule rule = new Rule._(this._parser, this);
    this._rules.add(rule);
    return rule;
  }

  void _calculate() {
    this._firsts = this._determineTermFirsts();
  }

  List<String> _determineTermFirsts([Set<Term> checked = null]) {
    checked ??= new Set<Term>();
    checked.add(this);
    Set<String> tokens = new Set<String>();
    for (Rule rule in this.rules) {
      Object item = rule.items[0];
      if (item is Term) {
        if (!checked.contains(item))
          tokens.addAll(item._determineTermFirsts(checked));
      } else tokens.add(item);
    }
    return tokens.toList();
  }
  
  /// Gets the name for this term.
  String toString() => this._name;
}
