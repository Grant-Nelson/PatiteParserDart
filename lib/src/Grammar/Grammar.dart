library PatiteParserDart.Grammar;

part 'Rule.dart';
part 'Term.dart';

/// A grammar is a definition of a language.
/// It is made up of a set of terms and the rules for how each term is used.
/// 
/// Formally a Grammer is defined as `G = (V, E, R, S)`:
/// - `V` is the set of `v` (non-terminal characters / variables).
///   These are referred to as the terms of the grammer in this implementation.
/// - `E` (normally shown as an epsilon) is the set of `t` (terminals / tokens).
///   These are referred to as the tokens of this grammer in this implementation.
///   `V` and `E` are disjoint, meaning no `v` exists in `E` and no `t` exists in `V`.
/// - `R` is the relationship of `V` to `(V union E)*`, where here the astrisk is
///   the Kleene star operation. Each `r` in `R` is a rule (rewrite rules / productions)
///   of the grammar as represented by `v → [v or t]*` where `[v or t]` is an item in
///   in the rule. Each term must be the start of one or more rules with, at least
///   one rule must contain a single item. Each term may include a rule with no items
///   (`v → ε`). There should be no duplicate rules for a term.
/// - `S` is the start term where `S` must exist in `V`.
/// 
/// For the LR1 parser, used by Patite Parser Dart, the grammar must be a Context-free
/// Language (CFL) where `L(G) = {w in E*: S => w}`, meaning that all nontermals can be
/// reached (`=>` means reachable) from the start term following the rules of the grammar.
/// 
/// To be a _proper_ CFG there my be no unreachable terms (for all `N` in `V` there
/// exists an `a` and `b` in `(V union U)*` such that `S => a N b`), no unproductive
/// symbols (for all `N` in `V` there exists a `w` in `E*` such that `N => w`),
/// no ε-rules (there does not exist an `N` in `V` such that `N → ε` exist in `R`), and
/// there are no cycles (there does not exist an `N` in `V` such that `N => ... => N`).
/// 
/// For more information see https://en.wikipedia.org/wiki/Context-free_grammar
class Grammar {
  Set<Term> _terms;
  Set<String> _tokens;
  Term _start;
  
  /// Creates a new empty grammar.
  Grammar() {
    this._terms = new Set<Term>();
    this._tokens = new Set<String>();
    this._start = null;
  }

  /// Creates a copy of this grammar.
  Grammar copy() {
    Grammar grammar = new Grammar();
    for (Term term in this._terms)
      grammar._add(term.name);

    if (this._start != null)
      grammar._start = grammar._findTerm(this._start.name);

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

  /// This will trim the term name and check if the name is empty.
  String _sanitizedTermName(String name) {
    name = name.trim();
    if (name.isEmpty)
      throw new Exception("May not have an all whitespace or empty term name.");
    return name;
  }

  /// Creates or adds a term for a set of rules
  /// and sets it as the starting term for the grammar.
  Term start(String termName) {
    this._start = this.term(termName);
    return this._start;
  }
  
  /// Gets the start term for this grammar.
  Term get startTerm => this._start;

  /// Gets the terms for this grammar.
  List<Term> get terms => this._terms.toList();
  
  /// Gets the tokens for this grammar.
  List<String> get tokens => this._tokens.toList();

  /// Finds a term in this grammar by the given name.
  /// Returns null if no term by that name if found.
  Term _findTerm(String termName) {
    for (Term term in this._terms) {
      if (term.name == termName) return term;
    }
    return null;
  }

  /// Adds a new term to this grammar.
  /// If the start term isn't set, it will be set to this term.
  Term _add(String termName) {
      Term nt = new Term._(this, termName);
      this._terms.add(nt);
      this._start ??= nt;
      return nt;
  }

  /// Find the existing token in this grammar.
  /// This is done this way to reduce pointer usage and have only
  /// one duplicate string for any given token.
  String _findAddToken(String tokenName) {
    tokenName = tokenName.trim();
    if (tokenName.isEmpty)
      throw new Exception("May not have an all whitespace or empty token name.");
    for (String token in this._tokens) {
      if (token == tokenName) return token;
    }
    this._tokens.add(tokenName);
    return tokenName;
  }

  /// Gets or adds a term for a set of rules to this grammar.
  /// If the start term isn't set, it will be set to this term.
  Term term(String termName) {
    termName = this._sanitizedTermName(termName);
    Term nt = this._findTerm(termName);
    nt ??= this._add(termName);
    return nt;
  }
  
  /// Gets or adds a term for and starts a new rule for that term.
  /// If the start term isn't set, it will be set to this rule's term.
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

  /// Validates the grammers configuration,
  /// on success (no errors) an empty string is returned,
  /// on failure a string containing each error line separated is returned.
  String validate() {
    StringBuffer buf = new StringBuffer();
    if (this._terms.isEmpty)
      buf.writeln('No terms are defined.');
    if (this._tokens.isEmpty)
      buf.writeln('No tokens are defined.');

    if (this._start == null)
      buf.writeln('The start term is not set.');
    else if (!this._terms.contains(this._start))
      buf.writeln('The start term, ${this._start}, was not found in the set of terms.');

    List<Term> termList = this._terms.toList();
    for (int i = termList.length - 1; i >= 0; i--) {
      for (int j = i - 1; j >= 0; j--) {
        if (termList[i].name == termList[j].name)
          buf.writeln('There exists two terms with the same name, ${termList[i].name}.');
      }
    }

    for (Term term in this._terms) {
      if (term.name.trim().isEmpty)
        buf.writeln('There exists a term which is all whitespace or emtpy.');
      if (term._rules.length <= 0)
        buf.writeln('The term, $term, has no rules defined for it.');

      for (int i = term._rules.length - 1; i >= 0; i--) {
        for (int j = i - 1; j >= 0; j--) {
          if (term._rules[i].equals(term._rules[j]))
            buf.writeln('There exists two rules which are the same, ${term._rules[i].toString()}.');
        }
      }

      for (Rule rule in term._rules) {
        if (rule._term == null)
          buf.writeln('The rule for ${term.name} is rule.');
        else if (rule._term != term)
          buf.writeln('The rule for ${term.name} says it is for ${rule._term.name}.');

        for (Object item in rule._items) {
          if (item is Term) {
            if (!this._terms.contains(item))
              buf.writeln("The term, ${item.name}, in a rule for ${term.name}, was not found in the set of terms.");
          } else {
            if ((item as String).trim().isEmpty)
              buf.writeln('There exists a token in rule for ${term.name} which is all whitespace or emtpy.');
            if (!this._tokens.contains(item))
              buf.writeln('The token, $item, in a rule for ${term.name}, was not found in the set of tokens.');
          }
        }
      }
    }

    Set<String> termUnreached = new Set<String>.from(termList.map<String>((Term t) => t.name));
    Set<String> tokenUnreached = new Set<String>.from(this._tokens);
    Function(Object item) touch;
    touch = (Object item) {
      if (item is Term) {
        if (termUnreached.contains(item.name)) {
          termUnreached.remove(item.name);
          for (Rule r in item._rules)
            for (Object item in r._items)
              touch(item);
        }
      } else tokenUnreached.remove(item);
    };
    touch(this._start);
    if (termUnreached.length > 0)
      buf.writeln('The following terms are unreachable: ${termUnreached.join(", ")}');
    if (tokenUnreached.length > 0)
      buf.writeln('The following tokens are unreachable: ${tokenUnreached.join(", ")}');

    return buf.toString();
  }
}
