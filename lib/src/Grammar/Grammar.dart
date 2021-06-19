library PetiteParserDart.Grammar;

import 'package:PetiteParserDart/src/Simple/Simple.dart' as Simple;

part 'Item.dart';
part 'Rule.dart';
part 'Term.dart';
part 'TokenItem.dart';
part 'Trigger.dart';

/// A grammar is a definition of a language.
/// It is made up of a set of terms and the rules for how each term is used.
///
/// Formally a Grammar is defined as `G = (V, E, R, S)`:
/// - `V` is the set of `v` (non-terminal characters / variables).
///   These are referred to as the terms of the grammar in this implementation.
/// - `E` (normally shown as an epsilon) is the set of `t` (terminals / tokens).
///   These are referred to as the tokens of this grammar in this implementation.
///   `V` and `E` are disjoint, meaning no `v` exists in `E` and no `t` exists in `V`.
/// - `R` is the relationship of `V` to `(V union E)*`, where here the asterisk is
///   the Kleene star operation. Each `r` in `R` is a rule (rewrite rules / productions)
///   of the grammar as represented by `v → [v or t]*` where `[v or t]` is an item in
///   in the rule. Each term must be the start of one or more rules with, at least
///   one rule must contain a single item. Each term may include a rule with no items
///   (`v → ε`). There should be no duplicate rules for a term.
/// - `S` is the start term where `S` must exist in `V`.
///
/// For the LR1 parser, used by Petite Parser Dart, the grammar must be a Context-free
/// Language (CFL) where `L(G) = {w in E*: S => w}`, meaning that all non-terminals can be
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
  Set<Term> _terms = Set();
  Set<TokenItem> _tokens = Set();
  Set<Trigger> _triggers = Set();
  Term? _start = null;

  /// Creates a new empty grammar.
  Grammar();

  /// Deserializes the given serialized data into a grammar.
  factory Grammar.deserialize(Simple.Deserializer data) {
    int version = data.readInt();
    if (version != 1)
      throw new Exception('Unknown version, $version, for grammar serialization.');
    Grammar grammar = new Grammar();
    grammar.start(data.readStr());
    int termCount = data.readInt();
    for (int i = 0; i < termCount; i++) {
      Term term = grammar.term(data.readStr());
      int ruleCount = data.readInt();
      for (int j = 0; j < ruleCount; j++) {
        Rule rule = term.newRule();
        int itemCount = data.readInt();
        for (int k = 0; k < itemCount; k++) {
          int itemType = data.readInt();
          String itemName = data.readStr();
          switch (itemType) {
            case 1: rule.addTerm(itemName);    break;
            case 2: rule.addToken(itemName);   break;
            case 3: rule.addTrigger(itemName); break;
          }
        }
      }
    }
    return grammar;
  }

  /// Creates a copy of this grammar.
  Grammar copy() {
    Grammar grammar = new Grammar();
    for (Term term in this._terms)
      grammar._add(term.name);

    if (this._start != null)
      grammar._start = grammar._findTerm(this._start?.name ?? '');

    for (Term term in this._terms) {
      Term? termCopy = grammar._findTerm(term.name);
      if (termCopy != null) {
        for (Rule rule in term.rules) {
          Rule ruleCopy = new Rule._(grammar, termCopy);
          for (Item item in rule.items) {
            Item itemCopy;
            if (item is Term)           itemCopy = grammar.term(item.name);
            else if (item is TokenItem) itemCopy = grammar.token(item.name);
            else if (item is Trigger)   itemCopy = grammar.trigger(item.name);
            else throw new Exception('Unknown item type: $item');
            ruleCopy._items.add(itemCopy);
          }
          termCopy.rules.add(ruleCopy);
        }
      }
    }
    return grammar;
  }

  /// Serializes the grammar.
  Simple.Serializer serialize() {
    Simple.Serializer data = new Simple.Serializer();
    data.writeInt(1); // Version 1
    data.writeStr(this._start?.name ?? '');
    data.writeInt(this._terms.length);
    for (Term term in this._terms) {
      data.writeStr(term.name);
      data.writeInt(term.rules.length);
      for (Rule rule in term.rules) {
        data.writeInt(rule.items.length);
        for (Item item in rule.items) {
          int itemType = (item is Term)? 1:
            ((item is TokenItem)? 2: 3);
          data.writeInt(itemType);
          data.writeStr(item.name);
        }
      }
    }
    return data;
  }

  /// This will trim the term name and check if the name is empty.
  String _sanitizedTermName(String name) {
    name = name.trim();
    if (name.isEmpty)
      throw new Exception('May not have an all whitespace or empty term name.');
    return name;
  }

  /// Creates or adds a term for a set of rules
  /// and sets it as the starting term for the grammar.
  Term start(String termName) =>
    this._start = this.term(termName);

  /// Gets the start term for this grammar.
  Term? get startTerm => this._start;

  /// Gets the terms for this grammar.
  List<Term> get terms => this._terms.toList();

  /// Gets the tokens for this grammar.
  List<TokenItem> get tokens => this._tokens.toList();

  /// Gets the triggers for this grammar.
  List<Trigger> get triggers => this._triggers.toList();

  /// Finds a term in this grammar by the given name.
  /// Returns null if no term by that name if found.
  Term? _findTerm(String termName) {
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

  /// Find the existing token in this grammar
  /// or add it if not found.
  TokenItem token(String tokenName) {
    tokenName = tokenName.trim();
    if (tokenName.isEmpty)
      throw new Exception('May not have an all whitespace or empty token name.');
    for (TokenItem token in this._tokens) {
      if (token.name == tokenName) return token;
    }
    TokenItem token = new TokenItem(tokenName);
    this._tokens.add(token);
    return token;
  }

  /// Find the existing trigger in this grammar
  /// or add it if not found.
  Trigger trigger(String triggerName) {
    triggerName = triggerName.trim();
    if (triggerName.isEmpty)
      throw new Exception('May not have an all whitespace or empty trigger name.');
    for (Trigger trigger in this._triggers) {
      if (trigger.name == triggerName) return trigger;
    }
    Trigger trigger = new Trigger(triggerName);
    this._triggers.add(trigger);
    return trigger;
  }

  /// Gets or adds a term for a set of rules to this grammar.
  /// If the start term isn't set, it will be set to this term.
  Term term(String termName) {
    termName = this._sanitizedTermName(termName);
    Term? nt = this._findTerm(termName);
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
      buf.writeln("> "+this._start.toString());
    for (Term term in this._terms) {
      for (Rule rule in term.rules)
       buf.writeln(rule);
    }
    return buf.toString();
  }

  /// Validates the grammars configuration,
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
        buf.writeln('There exists a term which is all whitespace or empty.');
      if (term._rules.length <= 0)
        buf.writeln('The term, $term, has no rules defined for it.');

      for (int i = term._rules.length - 1; i >= 0; i--) {
        for (int j = i - 1; j >= 0; j--) {
          if (term._rules[i].equals(term._rules[j]))
            buf.writeln('There exists two rules which are the same, ${term._rules[i].toString()}.');
        }
      }

      for (Rule rule in term._rules) {
        if (rule.term == null)
          buf.writeln('The rule for ${term.name} is rule.');
        else if (rule.term != term)
          buf.writeln('The rule for ${term.name} says it is for ${rule.term?.name ?? 'null'}.');

        for (Item item in rule._items) {
          if (item.name.trim().isEmpty)
            buf.writeln('There exists an item in rule for ${term.name} which is all whitespace or empty.');
          if (item is Term) {
            if (!this._terms.contains(item))
              buf.writeln("The term, $item, in a rule for ${term.name}, was not found in the set of terms.");
          } else if (item is TokenItem) {
            if (!this._tokens.contains(item))
              buf.writeln('The token, $item, in a rule for ${term.name}, was not found in the set of tokens.');
          } else if (item is Trigger) {
            if (!this._triggers.contains(item))
              buf.writeln('The trigger, $item, in a rule for ${term.name}, was not found in the set of triggers.');
          } else throw new Exception('Unknown item type in ${term.name}.');
        }
      }
    }

    _grammarUnreached unreached = _grammarUnreached(buf, termList, this._tokens, this._triggers);    
    unreached.touch(this._start);
    unreached.validate();

    return buf.toString();
  }
}

/// This is a tool to help gramar validate unreachable states.
class _grammarUnreached {
    StringBuffer _buf;
    Set<String> _terms    = Set();
    Set<String> _tokens   = Set();
    Set<String> _triggers = Set();

    /// Creates and populates a new unreachable validation.
    _grammarUnreached(this._buf, List<Term> terms, Set<TokenItem> tokens, Set<Trigger> triggers) {
      this._terms.addAll(terms.map<String>((Term t) => t.name));
      this._tokens.addAll(tokens.map<String>((TokenItem t) => t.name));
      this._triggers.addAll(triggers.map<String>((Trigger t) => t.name));
    }

    /// Touches the item and all the rules and items that are reachable.
    /// Anything reached is removed to leave only the unreachables.
    void touch(Item? item) {
      if (item == null) return;
      if (item is Term) {
        if (this._terms.contains(item.name)) {
          this._terms.remove(item.name);
          for (Rule r in item._rules)
            for (Item item in r._items)
              this.touch(item);
        }
      } else if (item is TokenItem) this._tokens.remove(item.name);
      else if (item is Trigger) this._triggers.remove(item.name);
      else _buf.writeln('Unknown item type: $item');
    }

    /// Validates the unreachable and writes errors to the buffer.
    void validate() {  
      if (this._terms.length > 0)
        _buf.writeln('The following terms are unreachable: ${this._terms.join(', ')}');
      if (this._tokens.length > 0)
        _buf.writeln('The following tokens are unreachable: ${this._tokens.join(', ')}');
      if (this._triggers.length > 0)
        _buf.writeln('The following triggers are unreachable: ${this._triggers.join(', ')}');
    }
}
