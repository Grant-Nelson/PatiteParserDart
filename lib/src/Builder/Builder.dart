library PatiteParserDart.Builder;

import 'package:PatiteParserDart/src/Grammar/Grammar.dart' as Grammar;

part 'Rule.dart';
part 'State.dart';
part 'Term.dart';

/// This is a builder used to generate a parser giving a grammar.
class Builder {
  Term _start;
  List<Term> _terms;
  List<State> _states;

  Builder() {
    this._start = null;
    this._terms = new List<Term>();
    this._states = new List<State>();
  }

  void setGrammar(Grammar.Grammar grammar) {
    if (grammar.start == null)
      throw new Exception('No start term defined in grammar.');

    grammar.terms.map((Grammar.Term term) {
      if (term.rules.isEmpty)
        throw new Exception('Term ${term.name} must have at least one rule.');
      this._terms.add(new Term(this, term.name));
    });
    
    this._start = this.findTerm(grammar.startTerm.name);

    for (Grammar.Term term in grammar.terms) {
      Term builderTerm = this.findTerm(term.name);
      for (Grammar.Rule rule in term.rules) {
        Rule ruleCopy = new Rule(this, builderTerm);

        for (Object obj in rule.items) {
          Object builderObj;
          if (obj is Term)
            builderObj = this.findTerm(obj.name);
          else builderObj = obj as String;
          ruleCopy.items.add(builderObj);
        }

        builderTerm.rules.add(ruleCopy);
      }
    }
  }

  List<Term> get terms => this._terms;
  
  /// Finds a term in this grammar by the given name.
  /// Returns null if no term by that name if found.
  Term findTerm(String termName) {
    for (Term term in this._terms) {
      if (term.name == termName) return term;
    }
    return null;
  }

  void determineFirstsAndFollows() {
    for (Term term in this._terms)
      term.determineFirstsAndFollows();
  }
}