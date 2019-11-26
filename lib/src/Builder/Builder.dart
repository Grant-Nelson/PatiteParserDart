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

  /// Constructs of a new parser builder.
  Builder() {
    this._start = null;
    this._terms = new List<Term>();
    this._states = new List<State>();
  }

  /// Sets the grammer for the parser.
  void setGrammar(Grammar.Grammar grammar) {
    if (grammar.start == null)
      throw new Exception('No start term defined in grammar.');

    for (Grammar.Term term in grammar.terms) {
      if (term.rules.isEmpty)
        throw new Exception('Term ${term.name} must have at least one rule.');
      this._terms.add(new Term(this, term.name));
    }
    
    this._start = this.findTerm(grammar.startTerm.name);

    for (Grammar.Term term in grammar.terms) {
      Term builderTerm = this.findTerm(term.name);
      for (Grammar.Rule rule in term.rules) {
        Rule ruleCopy = new Rule(this, builderTerm);

        for (Object obj in rule.items) {
          Object builderObj;
          if (obj is Grammar.Term)
            builderObj = this.findTerm(obj.name);
          else builderObj = obj as String;
          ruleCopy.items.add(builderObj);
        }

        builderTerm.rules.add(ruleCopy);
      }
    }
  }

  /// Gets the list of terms from this builder.
  List<Term> get terms => this._terms;
  
  /// Finds a term in this grammar by the given name.
  /// Returns null if no term by that name if found.
  Term findTerm(String termName) {
    for (Term term in this._terms) {
      if (term.name == termName) return term;
    }
    return null;
  }

  /// Determines the firsts and follows tokens for the terms.
  void determineFirstsAndFollows() {
    for (Term term in this._terms)
      term.determineFirstsAndFollows();
  }

  State find(int index, Rule rule) {
    for (State state in this._states) {
      for (int i = 0; i < state.indices.length; i++) {
        if ((state.indices[i] == index) &&
            (state.rules[i] == rule)) return state;
      }
    }
    return null;
  }

  void determineStates() {
    State startState = new State(0);
    for (Rule rule in this._start.rules)
      startState.addRule(0, rule);
    this._states.add(startState);
    List<State> changed = List<State>()
      ..add(startState);

    while (changed.isNotEmpty) {
      State state = changed.removeLast();
      changed.addAll(this.nextStates(state));
    }
  }

  List<State> nextStates(State state) {
    List<State> changed = new List<State>();
    for (int i = 0; i < state.indices.length; i++) {
      int index = state.indices[i];
      Rule rule = state.rules[i];
      if (index < rule.items.length) {
        Object item = rule.items[index];
        if (item.toString() == '\$') continue;

        State next = state.findGoto(item);
        if (next == null) {
          next = this.find(index+1, rule);
          if (next == null) {
            next = new State(this._states.length);
            this._states.add(next);
          }
          state.addGoto(item, next);
        }

        if (next.addRule(index+1, rule)) {
          changed.add(next);
        }
      }
    }

    return changed;
  }

  // Returns a human readable string for debugging of the parser being built.
  String toString() {
    StringBuffer buf = new StringBuffer();

    buf.writeln("terms:");
    if (this._start != null)
      buf.writeln("  > "+this._start.name);
    for (Term term in this._terms) {
      for (Rule rule in term.rules)
        buf.writeln("  "+rule.toString());
    }
    buf.writeln();

    buf.writeln("firsts:");
    for (Term term in this._terms) {
      buf.write("  "+term.toString() + ":");
      for (String first in term.firsts)
        buf.write(" "+first);
      buf.writeln();
    }
    buf.writeln();

    buf.writeln("follows:");
    for (Term term in this._terms) {
      buf.write("  "+term.toString() + ":");
      for (String follow in term.follows)
        buf.write(" "+follow);
      buf.writeln();
    }
    buf.writeln();

    buf.writeln("states:");
    for (State state in this._states) {
       buf.writeln("  "+state.toString("  "));
    }
    return buf.toString();
  }
}