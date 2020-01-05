part of PatiteParserDart.Parser;

/// Loader is a parser and interpreter for reading a tokenizer and grammar
/// definition from a string to create a parser. 
class Loader {

  /// Gets the tokenizer used for loading a parser definition.
  static Tokenizer.Tokenizer getTokenizer() {
    Tokenizer.Tokenizer tok = new Tokenizer.Tokenizer();
    tok.start("start");

    tok.join("start", "whitespace").addSet(" \n\r\t");
    tok.join("whitespace", "whitespace").addSet(" \n\r\t");
    tok.setToken("whitespace", "whitespace").consume();
    
    tok.joinToToken("start", "openParen").addSet("(");
    tok.joinToToken("start", "closeParen").addSet(")");
    tok.joinToToken("start", "openBracket").addSet("[");
    tok.joinToToken("start", "closeBracket").addSet("]");
    tok.joinToToken("start", "openAngle").addSet("<");
    tok.joinToToken("start", "closeAngle").addSet(">");
    tok.joinToToken("start", "openCurly").addSet("{");
    tok.joinToToken("start", "closeCurly").addSet("}");
    tok.joinToToken("start", "or").addSet("|");
    tok.joinToToken("start", "not").addSet("!");
    tok.joinToToken("start", "consume").addSet("^");
    tok.joinToToken("start", "colon").addSet(":");
    tok.joinToToken("start", "semicolon").addSet(";");
    tok.joinToToken("colon", "assign").addSet("=");
    tok.joinToToken("start", "comma").addSet(",");
    tok.joinToToken("start", "any").addSet("*");
    tok.joinToToken("start", "lambda").addSet("_");
    
    tok.join("start", "equal").addSet("=");
    tok.join("equal", "arrow").addSet(">");
    tok.setToken("arrow", "arrow");
    
    tok.join("start", "startRange").addSet(".");
    tok.joinToToken("startRange", "range").addSet(".");

    Matcher.Group hexMatcher = new Matcher.Group()..addRange('0', '9')..addRange('A', 'F')..addRange('a', 'f');
    Matcher.Group idLetter = new Matcher.Group()..addRange('a', 'z')..addRange('A', 'Z')..addRange('0', '9')..addSet("_.-");

    tok.joinToToken("start", "id").add(idLetter);
    tok.join("id", "id").add(idLetter);

    tok.join("start", "charSet.open")..addSet("'")..consume=true;
    tok.join("charSet.open", "charSet.escape").addSet("\\");
    tok.join("charSet.open", "charSet.body").addAll();
    tok.join("charSet.body", "charSet")..addSet("'")..consume=true;
    tok.join("charSet.body", "charSet.escape").addSet("\\");
    tok.join("charSet.escape", "charSet.body").addSet("\\nrt'");
    tok.join("charSet.escape", "charSet.hex1").addSet("x");
    tok.join("charSet.hex1", "charSet.hex2").add(hexMatcher);
    tok.join("charSet.hex2", "charSet.body").add(hexMatcher);
    tok.join("charSet.escape", "charSet.unicode1").addSet("u");
    tok.join("charSet.unicode1", "charSet.unicode2").add(hexMatcher);
    tok.join("charSet.unicode2", "charSet.unicode3").add(hexMatcher);
    tok.join("charSet.unicode3", "charSet.unicode4").add(hexMatcher);
    tok.join("charSet.unicode4", "charSet.body").add(hexMatcher);
    tok.join("charSet.body", "charSet.body").addAll();
    tok.setToken("charSet", "charSet");

    tok.join("start", "string.open")..addSet('"')..consume=true;
    tok.join("string.open", "string.escape").addSet("\\");
    tok.join("string.open", "string.body").addAll();
    tok.join("string.body", "string")..addSet('"')..consume=true;
    tok.join("string.body", "string.escape").addSet("\\");
    tok.join("string.escape", "string.body").addSet('\\nrt"');
    tok.join("string.escape", "string.hex1").addSet("x");
    tok.join("string.hex1", "string.hex2").add(hexMatcher);
    tok.join("string.hex2", "string.body").add(hexMatcher);
    tok.join("string.escape", "string.unicode1").addSet("u");
    tok.join("string.unicode1", "string.unicode2").add(hexMatcher);
    tok.join("string.unicode2", "string.unicode3").add(hexMatcher);
    tok.join("string.unicode3", "string.unicode4").add(hexMatcher);
    tok.join("string.unicode4", "string.body").add(hexMatcher);
    tok.join("string.body", "string.body").addAll();
    tok.setToken("string", "string");
    return tok;
  }

  /// Gets the grammar used for loading a parser definition.
  static Grammar.Grammar getGrammar() {
    Grammar.Grammar gram = new Grammar.Grammar();
    gram.start("def.set");
    gram.newRule("def.set").addTerm("def.set").addTerm("def").addToken("semicolon");
    gram.newRule("def.set");

    gram.newRule("def").addTrigger("new.def").addToken("closeAngle").addTerm("stateID").addTrigger("start.state").addTerm("def.state.optional");
    gram.newRule("def").addTrigger("new.def").addTerm("stateID").addTerm("def.state");
    gram.newRule("def").addTrigger("new.def").addTerm("tokenStateID").addTerm("def.token");
    
    gram.newRule("def.state.optional");
    gram.newRule("def.state.optional").addTerm("def.state");

    gram.newRule("def.state").addToken("colon").addTerm("matcher.start").addToken("arrow").addTerm("stateID").addTrigger("join.state").addTerm("def.state.optional");
    gram.newRule("def.state").addToken("colon").addTerm("matcher.start").addToken("arrow").addTerm("tokenStateID").addTrigger("join.token").addTerm("def.token.optional");
    gram.newRule("def.state").addToken("arrow").addTerm("tokenStateID").addTrigger("assign.token").addTerm("def.token.optional");

    gram.newRule("stateID").addToken("openParen").addToken("id").addToken("closeParen").addTrigger("new.state");
    gram.newRule("tokenStateID").addToken("openBracket").addToken("id").addToken("closeBracket").addTrigger("new.token.state");
    gram.newRule("tokenStateID").addToken("consume").addToken("openBracket").addToken("id").addToken("closeBracket").addTrigger("new.token.consume");
    gram.newRule("termID").addToken("openAngle").addToken("id").addToken("closeAngle").addTrigger("new.term");
    gram.newRule("tokenItemID").addToken("openBracket").addToken("id").addToken("closeBracket").addTrigger("new.token.item");
    gram.newRule("triggerID").addToken("openCurly").addToken("id").addToken("closeCurly").addTrigger("new.trigger");
    
    gram.newRule("matcher.start").addToken("any").addTrigger("match.any");
    gram.newRule("matcher.start").addTerm("matcher");
    gram.newRule("matcher.start").addToken("consume").addTerm("matcher").addTrigger("match.consume");

    gram.newRule("matcher").addTerm("charSetRange");
    gram.newRule("matcher").addTerm("matcher").addToken("comma").addTerm("charSetRange");

    gram.newRule("charSetRange").addToken("charSet").addTrigger("match.set");
    gram.newRule("charSetRange").addToken("not").addToken("charSet").addTrigger("match.set.not");
    gram.newRule("charSetRange").addToken("charSet").addToken("range").addToken("charSet").addTrigger("match.range");
    gram.newRule("charSetRange").addToken("not").addToken("charSet").addToken("range").addToken("charSet").addTrigger("match.range.not");
    gram.newRule("charSetRange").addToken("not").addToken("openParen").addTrigger("not.group.start").addTerm("matcher").addToken("closeParen").addTrigger("not.group.end");
    
    gram.newRule("def.token.optional");
    gram.newRule("def.token.optional").addTerm("def.token");
    gram.newRule("def.token").addToken("colon").addTerm("replaceText").addToken("arrow").addTerm("tokenStateID").addTrigger("replace.token");

    gram.newRule("replaceText").addToken("string").addTrigger("add.replace.text");
    gram.newRule("replaceText").addTerm("replaceText").addToken("comma").addToken("string").addTrigger("add.replace.text");

    gram.newRule("def").addTrigger("new.def").addToken("closeAngle").addTerm("termID").addTrigger("start.term").addTerm("start.rule.optional");
    gram.newRule("def").addTrigger("new.def").addTerm("termID").addToken("assign").addTrigger("start.rule").addTerm("start.rule").addTerm("next.rule.optional");

    gram.newRule("start.rule.optional");
    gram.newRule("start.rule.optional").addToken("assign").addTrigger("start.rule").addTerm("start.rule").addTerm("next.rule.optional");
    
    gram.newRule("next.rule.optional");
    gram.newRule("next.rule.optional").addTerm("next.rule.optional").addToken("or").addTrigger("start.rule").addTerm("start.rule");

    gram.newRule("start.rule").addTerm("tokenItemID").addTrigger("item.token").addTerm("rule.item");
    gram.newRule("start.rule").addTerm("termID").addTrigger("item.term").addTerm("rule.item");
    gram.newRule("start.rule").addTerm("triggerID").addTrigger("item.trigger").addTerm("rule.item");
    gram.newRule("start.rule").addToken("lambda");
    
    gram.newRule("rule.item");
    gram.newRule("rule.item").addTerm("rule.item").addTerm("tokenItemID").addTrigger("item.token");
    gram.newRule("rule.item").addTerm("rule.item").addTerm("termID").addTrigger("item.term");
    gram.newRule("rule.item").addTerm("rule.item").addTerm("triggerID").addTrigger("item.trigger");
    return gram;
  }

  /// Creates a new parser for loading tokenizer and grammar definitions.
  static Parser getParser() =>
    new Parser.fromGrammar(Loader.getGrammar(), Loader.getTokenizer());
  
  Map<String, ParseTree.TriggerHandle> _handles;
  Grammar.Grammar _grammar;
  Tokenizer.Tokenizer _tokenizer;
  
  List<Tokenizer.State> _states;
  List<Tokenizer.TokenState> _tokenStates;
  List<Grammar.Term> _terms;
  List<Grammar.TokenItem> _tokenItems;
  List<Grammar.Trigger> _triggers;
  List<Matcher.Group> _curTransGroups;
  bool _curTransConsume;
  List<String> _replaceText;
  Grammar.Rule _curRule;

  /// Creates a new loader.
  Loader() {
    this._handles = {
      'new.def':           this._newDef,
      'start.state':       this._startState,
      'join.state':        this._joinState,
      'join.token':        this._joinToken,
      'assign.token':      this._assignToken,
      'new.state':         this._newState,
      'new.token.state':   this._newTokenState,
      'new.token.consume': this._newTokenConsume,
      'new.term':          this._newTerm,
      'new.token.item':    this._newTokenItem,
      'new.trigger':       this._newTrigger,
      'match.any':         this._matchAny,
      'match.consume':     this._matchConsume,
      'match.set':         this._matchSet,
      'match.set.not':     this._matchSetNot,
      'match.range':       this._matchRange,
      'match.range.not':   this._matchRangeNot,
      'not.group.start':   this._notGroupStart,
      'not.group.end':     this._notGroupEnd,
      'add.replace.text':  this._addReplaceText,
      'replace.token':     this._replaceToken,
      'start.term':        this._startTerm,
      'start.rule':        this._startRule,
      'item.token':        this._itemToken,
      'item.term':         this._itemTerm,
      'item.trigger':      this._itemTrigger};
    this._grammar     = new Grammar.Grammar();
    this._tokenizer   = new Tokenizer.Tokenizer();
    this._states      = new List<Tokenizer.State>();
    this._tokenStates = new List<Tokenizer.TokenState>();
    this._terms       = new List<Grammar.Term>();
    this._tokenItems  = new List<Grammar.TokenItem>();
    this._triggers    = new List<Grammar.Trigger>();
    this._curTransGroups  = new List<Matcher.Group>();
    this._curTransConsume = false;
    this._replaceText     = new List<String>();
    this._curRule         = null;
  }

  /// Adds several blocks of definitions to the grammar and tokenizer
  /// which are being loaded via a string containing the definition.
  void load(String input) => this.loadChars(input.codeUnits.iterator);

  /// Adds several blocks of definitions to the grammar and tokenizer
  /// which are being loaded via a list of characters containing the definition.
  void loadChars(Iterator<int> iterator) {
    Result result = getParser().parseChars(iterator);
    if (result.errors?.isNotEmpty ?? false)
      throw new Exception('Error in provided language definition:\n${result.errors}');
    result.tree.process(this._handles);
  }

  /// Gets the grammar which is being loaded.
  Grammar.Grammar get grammar => this._grammar;
  
  /// Gets the tokenizer which is being loaded.
  Tokenizer.Tokenizer get tokenizer => this._tokenizer;
  
  /// Creates a parser with the loaded tokenizer and grammar.
  Parser get parser => new Parser.fromGrammar(this._grammar, this._tokenizer);

  /// A trigger handle for starting a new definition block.
  void _newDef(ParseTree.TriggerArgs args) {
    args.tokens.clear();
    this._states.clear();
    this._tokenStates.clear();
    this._terms.clear();
    this._tokenItems.clear();
    this._triggers.clear();
    this._curTransGroups.clear();
    this._curTransConsume = false;
    this._replaceText.clear();
    this._curRule = null;
  }

  /// A trigger handle for setting the starting state of the tokenizer.
  void _startState(ParseTree.TriggerArgs args) =>
    this._tokenizer.start(this._states.last.name);

  /// A trigger handle for joining two states with the defined matcher.
  void _joinState(ParseTree.TriggerArgs args) {
    Tokenizer.State start = this._states[this._states.length-2];
    Tokenizer.State end   = this._states.last;
    Tokenizer.Transition trans = start.join(end.name);
    trans.matchers.addAll(this._curTransGroups[0].matchers);
    trans.consume = this._curTransConsume;
    this._curTransGroups.clear();
    this._curTransConsume = false;
  }

  /// A trigger handle for joining a state to a token with the defined matcher.
  void _joinToken(ParseTree.TriggerArgs args) {
    Tokenizer.State start = this._states.last;
    Tokenizer.TokenState end = this._tokenStates.last;
    Tokenizer.Transition trans = start.join(end.name);
    trans.matchers.addAll(this._curTransGroups[0].matchers);
    trans.consume = this._curTransConsume;
    this._tokenizer.state(end.name).setToken(end.name);
    this._curTransGroups.clear();
    this._curTransConsume = false;
  }

  /// A trigger handle for assigning a token to a state.
  void _assignToken(ParseTree.TriggerArgs args) {
    Tokenizer.State start = this._states.last;
    Tokenizer.TokenState end = this._tokenStates.last;
    start.setToken(end.name);
  }

  /// A trigger handle for adding a new state to the tokenizer.
  void _newState(ParseTree.TriggerArgs args) {
    String name = args.recent(2).text;
    Tokenizer.State state = this._tokenizer.state(name);
    this._states.add(state);
  }

  /// A trigger handle for adding a new token to the tokenizer.
  void _newTokenState(ParseTree.TriggerArgs args) {
    String name = args.recent(2).text;
    Tokenizer.TokenState token = this._tokenizer.token(name);
    this._tokenStates.add(token);
  }

  /// A trigger handle for adding a new token to the tokenizer
  /// and setting it to comsume that token.
  void _newTokenConsume(ParseTree.TriggerArgs args) {
    String name = args.recent(2).text;
    Tokenizer.TokenState token = this._tokenizer.token(name);
    token.consume();
    this._tokenStates.add(token);
  }

  /// A trigger handle for adding a new term to the grammar.
  void _newTerm(ParseTree.TriggerArgs args) {
    String name = args.recent(2).text;
    Grammar.Term term = this._grammar.term(name);
    this._terms.add(term);
  }

  /// A trigger handle for adding a new token to the grammar.
  void _newTokenItem(ParseTree.TriggerArgs args) {
    String name = args.recent(2).text;
    Grammar.TokenItem token = this._grammar.token(name);
    this._tokenItems.add(token);
  }

  /// A trigger handle for adding a new trigger to the grammar.
  void _newTrigger(ParseTree.TriggerArgs args) {
    String name = args.recent(2).text;
    Grammar.Trigger trigger = this._grammar.trigger(name);
    this._triggers.add(trigger);
  }

  /// A trigger handle for setting the currently building matcher to match any.
  void _matchAny(ParseTree.TriggerArgs args) {
    if (this._curTransGroups.isEmpty) this._curTransGroups.add(new Matcher.Group());
    this._curTransGroups.last.addAll();
  }

  /// A trigger handle for setting the currently building matcher to be consumed.
  void _matchConsume(ParseTree.TriggerArgs args) =>
    this._curTransConsume = true;

  /// A trigger handle for setting the currently building matcher to match to a character set.
  void _matchSet(ParseTree.TriggerArgs args) {
    Tokenizer.Token token = args.recent(1);
    if (this._curTransGroups.isEmpty) this._curTransGroups.add(new Matcher.Group());
    this._curTransGroups.last.addSet(token.text);
  }

  /// A trigger handle for setting the currently building matcher to not match to a character set.
  void _matchSetNot(ParseTree.TriggerArgs args) {
    this._notGroupStart(args);
    this._matchSet(args);
    this._notGroupEnd(args);
  }

  /// A trigger handle for setting the currently building matcher to match to a character range.
  void _matchRange(ParseTree.TriggerArgs args) {
    Tokenizer.Token lowChar  = args.recent(3);
    Tokenizer.Token highChar = args.recent(1);
    if (lowChar.text.length != 1)
      throw new Exception('May only have one character for the low char of a range. $lowChar does not.');
    if (highChar.text.length != 1)
      throw new Exception('May only have one character for the high char of a range. $highChar does not.');
    if (this._curTransGroups.isEmpty) this._curTransGroups.add(new Matcher.Group());
    this._curTransGroups.last.addRange(lowChar.text, highChar.text);
  }

  /// A trigger handle for setting the currently building matcher to not match to a character range.
  void _matchRangeNot(ParseTree.TriggerArgs args) {
    this._notGroupStart(args);
    this._matchRange(args);
    this._notGroupEnd(args);
  }
  
  /// A trigger handle for starting a not group of matchers.
  void _notGroupStart(ParseTree.TriggerArgs args) {
    if (this._curTransGroups.isEmpty) this._curTransGroups.add(new Matcher.Group());
    this._curTransGroups.add(this._curTransGroups.last.addNot());
  }

  /// A trigger handle for ending a not group of matchers.
  void _notGroupEnd(ParseTree.TriggerArgs args) =>
    this._curTransGroups.removeLast();

  /// A trigger handle for adding a new replacement string to the loader.
  void _addReplaceText(ParseTree.TriggerArgs args) =>
    this._replaceText.add(args.recent(1).text);

  /// A trigger handle for setting a set of replacements between two
  /// tokens with a previously set replacement string set.
  void _replaceToken(ParseTree.TriggerArgs args) {
    Tokenizer.TokenState start = this._tokenStates[this._tokenStates.length-2];
    Tokenizer.TokenState end = this._tokenStates.last;
    start.replace(end.name, this._replaceText);
    this._replaceText.clear();
  }

  /// A trigger handle for starting a grammer definition of a term.
  void _startTerm(ParseTree.TriggerArgs args) =>
    this._grammar.start(this._terms.last.name);

  /// A trigger handle for starting defining a rule for the current term.
  void _startRule(ParseTree.TriggerArgs args) =>
    this._curRule = this._terms.last.newRule();

  /// A trigger handle for adding a token to the current rule being built.
  void _itemToken(ParseTree.TriggerArgs args) =>
    this._curRule.addToken(this._tokenItems.removeLast().name);

  /// A trigger handle for adding a term to the current rule being built.
  void _itemTerm(ParseTree.TriggerArgs args) =>
    this._curRule.addTerm(this._terms.removeLast().name);

  /// A trigger handle for adding a trigger to the current rule being built.
  void _itemTrigger(ParseTree.TriggerArgs args) =>
    this._curRule.addTrigger(this._triggers.removeLast().name);
}
