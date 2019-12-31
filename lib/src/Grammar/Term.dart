part of PatiteParserDart.Grammar;

/// A term is a group of rules and part of a rule
/// which defines part of the grammar language.
/// 
/// For example the term `<T>` with the rules `<T> => "(" <E> ")"`,
/// `<T> => <E> * <E>`, and `<T> => <E> + <E>`.
class Term extends Item {
  final Grammar _grammar;
  List<Rule> _rules;

  /// Creates a new term with the given name for the given grammar.
  Term._(Grammar this._grammar, String name): super._(name) {
    this._rules = new List<Rule>();
  }
  
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
  List<TokenItem> determineFirsts() {
    Set<TokenItem> tokens = new Set<TokenItem>();
    this._determineFirsts(tokens, new Set<Term>());
    return tokens.toList();
  }

  /// Determines the follow tokens that can be reached from the reduction of all the rules,
  /// ie. the tokens which follow after the term and any first term in all the rules.
  List<TokenItem> determineFollows() {
    Set<TokenItem> tokens = new Set<TokenItem>();
    this._determineFollows(tokens, new Set<Term>());
    return tokens.toList();
  }
  
  /// This is the recursive part of the determination of the first token sets which
  /// allows for terms which have already been checked to not be checked again.
  void _determineFirsts(Set<TokenItem> tokens, Set<Term> checked) {
    if (checked.contains(this)) return;
    checked.add(this);
    bool needFollows = false;
    for (Rule rule in this._rules) {
      if (this._determineRuleFirsts(rule, tokens, checked)) needFollows = true;
    }
    if (needFollows) this._determineFollows(tokens, new Set<Term>());
  }
  
  /// This determines the firsts for the given rule.
  /// If the rule has no tokens or terms this will return true
  /// indicating that the rule needs follows to be added.
  bool _determineRuleFirsts(Rule rule, Set<TokenItem> tokens, Set<Term> checked) {
    for (Item item in rule.items) {
      if (item is Term) {
        item._determineFirsts(tokens, checked);
        return false;
      } else if (item is TokenItem) {
        tokens.add(item);
        return false;
      }
      // else if Trigger continue.
    }
    return true;
  }

  /// This is the recursive part of the determination of the follow token sets which
  /// allows for terms which have already been checked to not be checked again.
  void _determineFollows(Set<TokenItem> tokens, Set<Term> checked) {
    if (checked.contains(this)) return;
    checked.add(this);
    for (Term term in this._grammar.terms) {
      for (Rule rule in term.rules) {
        int count = rule.items.length;
        for (int i = 0; i < count-1; i++) {
          if (rule.items[i] == this) {
            Item item = rule.items[i+1];
            if (item is Term)
              item._determineFirsts(tokens, new Set<Term>());
            else if (item is TokenItem) tokens.add(item);
            // else ignore trigger
          }
        }

        if ((rule.items.length > 0) && (rule.items[count-1] == this)) {
          term._determineFollows(tokens, checked);
        }
      }
    }
  }
  
  /// Gets the string for this term.
  String toString() => "<${this.name}>";
}
