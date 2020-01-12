part of PatiteParserDart.Grammar;

/// A rule is a single definition from a grammar.
///
/// For example `<T> → "(" <E> ")"`. The term for the rule is
/// the left hand side (`T`) while the items are the parts on the right hand size.
/// The items are made up of tokens (`(`, `)`) and the rule's term or other terms (`E`).
/// The order of the items defines how this rule in the grammer is to be used.
class Rule {
  Grammar _grammar;
  Term _term;
  List<Item> _items;

  /// Creates a new rule for the the given grammar and term.
  Rule._(Grammar this._grammar, Term this._term) {
    this._items = List<Item>();
  }

  /// Adds a term to this rule.
  /// This will get or create a new term to the grammar.
  /// Returns this rule so that rule creation can be chained.
  Rule addTerm(String termName) {
    Term term = this._grammar.term(termName);
    this._items.add(term);
    return this;
  }

  /// Adds a token to this rule.
  /// Returns this rule so that rule creation can be chained.
  Rule addToken(String tokenName) {
    TokenItem token = this._grammar.token(tokenName);
    this._items.add(token);
    return this;
  }

  /// Adds a trigger to this rule.
  /// Returns this rule so that rule creation can be chained.
  Rule addTrigger(String triggerName) {
    Trigger trigger = this._grammar.trigger(triggerName);
    this._items.add(trigger);
    return this;
  }

  /// Gets the left hand side term to the rule.
  Term get term => this._term;

  /// Gets all the terms, tokens, and triggers for this rule.
  /// The items are in the order defined by this rule.
  List<Item> get items => this._items;

  /// Gets the set of terms and tokens without the triggers.
  List<Item> get basicItems {
    List<Item> items = new List<Item>();
    for (Item item in this._items) {
      if (item is! Trigger) items.add(item);
    }
    return items;
  }

  /// Determines if the given rule is equal to this rule.
  /// This uses pointer comparison for item equivalency.
  bool equals(Rule other) {
    if (other == null) return false;
    if (this._term != other._term) return false;
    if (this._items.length != other._items.length) return false;
    for (int i = this._items.length - 1; i >= 0; i--) {
      if (this._items[i] != other._items[i]) return false;
    }
    return true;
  }

  /// Gets the string for this rule.
  /// Has an optional step index for showing the different
  /// states of the parser generator.
  String toString([int stepIndex = -1]) {
    List<String> parts = new List<String>();
    int index = 0;
    for (Item item in this._items) {
      if (index == stepIndex) {
        parts.add("•");
        stepIndex = -1;
      }
      parts.add(item.toString());
      if (item is! Trigger) index++;
    }
    if (index == stepIndex) parts.add("•");
    return this._term.toString() + " → " + parts.join(" ");
  }
}
