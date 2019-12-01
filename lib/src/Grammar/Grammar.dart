library PatiteParserDart.Grammar;

part 'Rule.dart';
part 'Term.dart';

/// A grammar is a definition of a language.
/// It is made up of a set of terms and the rules
/// for how each term is used.
class Grammar {
  List<Term> _terms;
  Term _start;
  String _accept;
  
  /// Creates a new empty grammar.
  Grammar() {
    this._terms = new List<Term>();
    this._start = null;
    this._accept = "\$";
  }

  /// Creates a copy of this grammar.
  Grammar copy() {
    Grammar grammar = new Grammar();
    for (Term term in this._terms)
      grammar._add(term.name);

    if (this._start != null)
      this._start = grammar._findTerm(this._start.name);

    for (Term term in this._terms) {
      Term termCopy = grammar._findTerm(term.name);
      
      for (Rule rule in term.rules) {
        Rule ruleCopy = new Rule._(grammar, termCopy);

        for (Object obj in rule.items) {
          Object objCopy;
          if (obj is Term)
            objCopy = grammar._findTerm(obj.name);
          else objCopy = obj as String;
          ruleCopy._items.add(objCopy);
        }
        termCopy.rules.add(ruleCopy);
      }
    }
    return grammar;
  }

  /// Creates or adds a term for a set of rules
  /// and sets it as the starting term for the grammar.
  Term start(String termName) {
    this._start = this.term(termName);
    return this._start;
  }

  /// Sets the accept token for the grammar.
  void accept(String token) => this._accept = token;
  
  /// Gets the start term for tis grammar.
  Term get startTerm => this._start;

  /// Gets the terms for tis grammar.
  List<Term> get terms => this._terms;
  
  /// Gets the token to use for the accept condition.
  String get acceptToken => this._accept;

  /// Finds a term in this grammar by the given name.
  /// Returns null if no term by that name if found.
  Term _findTerm(String termName) {
    for (Term term in this._terms) {
      if (term.name == termName) return term;
    }
    return null;
  }

  /// Adds a new term to this grammar.
  Term _add(String termName) {
      Term nt = new Term._(this, termName);
      this._terms.add(nt);
      return nt;
  }

  /// Gets or adds a term for a set of rules to this grammar.
  Term term(String termName) {
    Term nt = this._findTerm(termName);
    if (nt == null) nt = this._add(termName);
    return nt;
  }
  
  /// Gets or adds a term for and starts a new rule for that term.
  /// The new rule is returned.
  Rule newRule(String termName) =>
    this.term(termName).newRule();

  /// Gets a string showing the whole language.
  String toString() {
    StringBuffer buf = new StringBuffer();
    if (this._start != null)
      buf.writeln("> "+this._start.name);
    for (Term term in this._terms) {
      for (Rule rule in term.rules)
       buf.writeln(rule);
    }
    return buf.toString();
  }
}
