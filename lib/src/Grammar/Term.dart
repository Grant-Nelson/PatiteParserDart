part of PatiteParserDart.Grammar;

/// A term is a group of rules and part of a rule
/// which defines part of the grammar language.
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
  
  /// Gets the name for this term.
  String toString() => this._name;
}
