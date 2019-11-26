part of PatiteParserDart.Builder;

class Term {
  Builder _builder;
  String _name;
  List<Rule> _rules;
  List<String> _firsts;
  List<String> _follows;

  Term(Builder this._builder, String this._name) {
    this._rules = new List<Rule>();
    this._firsts = new List<String>();
    this._follows = new List<String>();
  }

  /// Gets the name of the term.
  String get name => this._name;

  /// Gets the list of rules starting with this term.
  List<Rule> get rules => this._rules;
  
  List<String> get firsts => this._firsts;
  
  List<String> get follows => this._follows;

  void determineFirstsAndFollows() {
    Set<String> tokens = new Set<String>();
    this._determineFirsts(tokens, new Set<Term>());
    this._firsts = tokens.toList();

    tokens = new Set<String>();
    this._determineFollows(tokens, new Set<Term>());
    this._follows = tokens.toList();
  }

  void _determineFirsts(Set<String> tokens, Set<Term> checked) {
    checked.add(this);
    for (Rule rule in this._rules) {
      Object item = rule.items[0];
      if (item is Term) {
        if (!checked.contains(item))
          item._determineFirsts(tokens, checked);
      } else tokens.add(item);
    }
  }

  void _determineFollows(Set<String> tokens, Set<Term> checked) {
    checked.add(this);
    for (Term term in this._builder.terms) {
      for (Rule rule in term.rules) {

        int count = rule.items.length;
        for (int i = 0; i < count-1; i++) {
          if (rule.items[i] == this) {
            Object item = rule.items[i+1];
            if (item is Term) 
              tokens.addAll(item._firsts);
            else tokens.add(item);
          }
        }

        if (rule.items[count-1] == this) {
          if (!checked.contains(term))
            term._determineFollows(tokens, checked);
        }

      }
    }
  }

  String toString() => this._name;
}
