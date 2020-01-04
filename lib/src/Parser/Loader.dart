part of PatiteParserDart.Parser;

class Loader {

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

    tok.join("start", "charSet.open").addSet("'");
    tok.join("charSet.open", "charSet.escape").addSet("\\");
    tok.join("charSet.open", "charSet.body").addAll();
    tok.join("charSet.body", "charSet").addSet("'");
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

    tok.join("start", "string.open").addSet('"');
    tok.join("string.open", "string.escape").addSet("\\");
    tok.join("string.open", "string.body").addAll();
    tok.join("string.body", "string").addSet('"');
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

  static Grammar.Grammar getGrammar() {
    Grammar.Grammar gram = new Grammar.Grammar();
    gram.start("def.set");
    gram.newRule("def.set").addTerm("def.set").addTerm("def");
    gram.newRule("def.set");

    gram.newRule("def").addTrigger("new.def").addToken("closeAngle").addTerm("stateID").addTrigger("start.state").addTerm("def.state.optional");
    gram.newRule("def").addTrigger("new.def").addTerm("stateID").addTerm("def.state");
    gram.newRule("def").addTrigger("new.def").addTerm("tokenID").addTerm("def.token");
    
    gram.newRule("def.state.optional");
    gram.newRule("def.state.optional").addTerm("def.state");

    gram.newRule("def.state").addToken("colon").addTerm("matcher.start").addToken("arrow").addTerm("stateID").addTrigger("join.state").addTerm("def.state.optional");
    gram.newRule("def.state").addToken("colon").addTerm("matcher.start").addToken("arrow").addTerm("tokenID").addTrigger("join.token").addTerm("def.token.optional");
    gram.newRule("def.state").addToken("arrow").addTerm("tokenID").addTrigger("assign.token").addTerm("def.token.optional");

    gram.newRule("stateID").addToken("openParen").addToken("id").addToken("closeParen").addTrigger("new.state");
    gram.newRule("tokenID").addToken("openBracket").addToken("id").addToken("closeBracket").addTrigger("new.token");
    gram.newRule("tokenID").addToken("consume").addToken("openBracket").addToken("id").addToken("closeBracket").addTrigger("new.token.consume");
    gram.newRule("termID").addToken("openAngle").addToken("id").addToken("closeAngle").addTrigger("new.term");
    gram.newRule("triggerID").addToken("openCurly").addToken("id").addToken("closeCurly").addTrigger("new.trigger");
    
    gram.newRule("matcher.start").addToken("any").addTrigger("match.any");
    gram.newRule("matcher.start").addTerm("matcher").addTrigger("match");
    gram.newRule("matcher.start").addToken("consume").addTerm("matcher").addTrigger("match.consume");

    gram.newRule("matcher").addTerm("charSetRange");
    gram.newRule("matcher").addTerm("matcher").addToken("comma").addTerm("charSetRange");

    gram.newRule("charSetRange").addToken("charSet").addTrigger("match.set");
    gram.newRule("charSetRange").addToken("not").addToken("charSet").addTrigger("match.set.not");
    gram.newRule("charSetRange").addToken("charSet").addToken("range").addToken("charSet").addTrigger("match.range");
    gram.newRule("charSetRange").addToken("not").addToken("charSet").addToken("range").addToken("charSet").addTrigger("match.range.not");

    gram.newRule("def.token.optional");
    gram.newRule("def.token.optional").addTerm("def.token");
    gram.newRule("def.token").addToken("colon").addToken("string").addToken("arrow").addTerm("tokenID").addTrigger("replace.token");

    gram.newRule("def").addTrigger("new.def").addToken("closeAngle").addTerm("termID").addTrigger("start.term").addTerm("start.rule.optional");
    gram.newRule("def").addTrigger("new.def").addTerm("termID").addToken("assign").addTerm("start.rule").addTerm("next.rule.optional");

    gram.newRule("start.rule.optional");
    gram.newRule("start.rule.optional").addToken("assign").addTrigger("start.rule").addTerm("start.rule").addTerm("next.rule.optional");
    
    gram.newRule("next.rule.optional");
    gram.newRule("next.rule.optional").addTerm("next.rule.optional").addToken("or").addTrigger("start.rule").addTerm("start.rule");

    gram.newRule("start.rule").addTerm("tokenID").addTrigger("item.token").addTerm("rule.item");
    gram.newRule("start.rule").addTerm("termID").addTrigger("item.term").addTerm("rule.item");
    gram.newRule("start.rule").addTerm("triggerID").addTrigger("item.trigger").addTerm("rule.item");
    gram.newRule("start.rule").addToken("lambda");
    
    gram.newRule("rule.item");
    gram.newRule("rule.item").addTerm("rule.item").addTerm("tokenID").addTrigger("item.token");
    gram.newRule("rule.item").addTerm("rule.item").addTerm("termID").addTrigger("item.term");
    gram.newRule("rule.item").addTerm("rule.item").addTerm("triggerID").addTrigger("item.trigger");
    return gram;
  }

  static Parser _loadParserSingleton;

  static Parser getParser() {
    _loadParserSingleton ??= new Parser.fromGrammar(Loader.getGrammar(), Loader.getTokenizer());
    return _loadParserSingleton;
  }

  Loader();

  Parser load(String input) => this.loadChars(input.codeUnits.iterator);

  Parser loadChars(Iterator<int> iterator) {
    Result result = getParser().parseChars(iterator);
    if (result.errors.isNotEmpty)
      throw new Exception('Error in provided language definition:\n${result.errors}');
    return this._load(result.tree);
  }

  Parser _load(ParseTree.TreeNode node) {




    return null;
  }
}
