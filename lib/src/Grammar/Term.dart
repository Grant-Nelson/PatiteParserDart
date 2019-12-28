part of PatiteParserDart.Grammar;

/// A term is a group of rules and part of a rule
/// which defines part of the grammar language.
/// 
/// For example the term `<T>` with the rules `<T> => "(" <E> ")"`,
/// `<T> => <E> * <E>`, and `<T> => <E> + <E>`.
class Term {
  Grammar _grammar;
  String _name;
  List<Rule> _rules;

  /// Creates a new term with the given name for the given grammar.
  Term._(Grammar this._grammar, String this._name) {
    this._rules = new List<Rule>();
  }
  
  /// Gets the name of the term.
  String get name => this._name;

  /// Gets the list of rules starting with this term.
  List<Rule> get rules => this._rules;

  /// Adds a new rule to this term.
  Rule newRule() {
    Rule rule = new Rule._(this._grammar, this);
    this._rules.add(rule);
    return rule;
  }
  
  /// Determines the first tokens that can be reached from
  /// the rules of this term.
  List<String> determineFirsts() {
    Set<String> tokens = new Set<String>();
    this._determineFirsts(tokens, new Set<Term>());
    return tokens.toList();
  }

  /// Determines the follow tokens that can be reached from the reduction of all the rules,
  /// ie. the tokens which follow after the term and any first term in all the rules.
  List<String> determineFollows() {
    Set<String> tokens = new Set<String>();
    this._determineFollows(tokens, new Set<Term>());
    return tokens.toList();
  }
  
  /// This is the recursive part of the determination of the first token sets which
  /// allows for terms which have already been checked to not be checked again.
  void _determineFirsts(Set<String> tokens, Set<Term> checked) {
    checked.add(this);
    for (Rule rule in this._rules) {
      if (rule.items.length <= 0) {
        rule.term._determineFollows(tokens, new Set<Term>());
      } else {
        Object item = rule.items[0];
        if (item is Term) {
          if (!checked.contains(item))
            item._determineFirsts(tokens, checked);
        } else tokens.add(item);
      }
    }
  }

  /// This is the recursive part of the determination of the follow token sets which
  /// allows for terms which have already been checked to not be checked again.
  void _determineFollows(Set<String> tokens, Set<Term> checked) {
    checked.add(this);
    for (Term term in this._grammar.terms) {
      for (Rule rule in term.rules) {
        int count = rule.items.length;
        for (int i = 0; i < count-1; i++) {
          if (rule.items[i] == this) {
            Object item = rule.items[i+1];
            if (item is Term)
              item._determineFirsts(tokens, new Set<Term>());
            else tokens.add(item);
          }
        }

        if ((rule.items.length > 0) && (rule.items[count-1] == this)) {
          if (!checked.contains(term))
            term._determineFollows(tokens, checked);
        }
      }
    }
  }
  
  /// Gets the name for this term.
  String toString() => this._name;
}
