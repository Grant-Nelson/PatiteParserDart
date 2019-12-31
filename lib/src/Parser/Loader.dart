part of PatiteParserDart.Parser;

class Loader {

  static Tokenizer.Tokenizer getTokenizer() {
    Tokenizer.Tokenizer tok = new Tokenizer.Tokenizer();
    tok.start("start");

    tok.join("start", "whitespace").addSet(" \n\r\t");
    tok.join("whitespace", "whitespace").addSet(" \n\r\t");
    tok.setToken("whitespace", "whitespace").consume();
    
    tok.join("start", "openParen").addSet("(");
    tok.setToken("openParen", "openParen");
    
    tok.join("start", "closeParen").addSet(")");
    tok.setToken("closeParen", "closeParen");

    tok.join("start", "openBracket").addSet("[");
    tok.setToken("openBracket", "openBracket");
    
    tok.join("start", "closeBracket").addSet("]");
    tok.setToken("closeBracket", "closeBracket");

    tok.join("start", "openAngle").addSet("<");
    tok.setToken("openAngle", "openAngle");
    
    tok.join("start", "closeAngle").addSet(">");
    tok.setToken("closeAngle", "closeAngle");
    
    tok.join("start", "not").addSet("!");
    tok.setToken("not", "not");
    
    tok.join("start", "consume").addSet("^");
    tok.setToken("consume", "consume");
    
    tok.join("start", "colon").addSet(":");
    tok.setToken("colon", "colon");
    
    tok.join("start", "comma").addSet(",");
    tok.setToken("comma", "comma");
    
    tok.join("start", "any").addSet("*");
    tok.setToken("any", "any");
    
    tok.join("start", "lambda").addSet("_");
    tok.setToken("lambda", "lambda");
    
    tok.join("colon", "assign").addSet("=");
    tok.setToken("assign", "assign");
    
    tok.join("start", "equal").addSet("=");
    tok.setToken("equal", "equal");

    tok.join("equal", "arrow").addSet(">");
    tok.setToken("arrow", "arrow");
    
    tok.join("start", "startRange").addSet(".");
    tok.join("startRange", "range").addSet(".");
    tok.setToken("range", "range");

    Matcher.Group hexMatcher = new Matcher.Group()..addRange('0', '9')..addRange('A', 'F')..addRange('a', 'f');
    Matcher.Group idLetter = new Matcher.Group()..addRange('a', 'z')..addRange('A', 'Z')..addRange('0', '9')..addSet("_.-");

    tok.join("start", "id").add(idLetter);
    tok.join("id", "id").add(idLetter);
    tok.setToken("id", "id");

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
    
    // Tokens:
    //    openParen     (
    //    closeParen    )
    //    openBracket   [
    //    closeBracket  ]
    //    openAngle     <
    //    closeAngle    >
    //    not           !
    //    consume       ^
    //    colon         :
    //    comma         ,
    //    any           *
    //    lambda        _
    //    assign        :=
    //    equal         =
    //    arrow         =>
    //    range         ..
    //    id            [0-9a-fA-F_.-]+
    //    charSet       'any'
    //    string        "any"
    return tok;
  }

  static Grammar.Grammar getGrammar() {
    // Examples:
    //    Tokenizer:
    //       > (StartState)
    //       > (StartState): 'a' => (State)
    //       (State): 'a'..'c' => (State)
    //       (State): 'abcdef' => (State)
    //       (State): ! 'abcdef' => (State)
    //       (State): ^ 'a'..'b', 'c', => (State)
    //       (State): * => (State)
    //       (State) => [Token]
    //       (State) => ^[Token]
    //       [Token] = "word" => [Token]
    //       [Token] = "word" => ^[Token]
    //    Parser:
    //       > <StartTerm>
    //       > <StartTerm> := [Token] <Term>
    //       <Term> := _
    //       <Term> := <Term> | <Term>

    Grammar.Grammar gram = new Grammar.Grammar();
    gram.start("def.set");
    gram.newRule("def.set").addTerm("def.set").addTerm("def");
    gram.newRule("def.set");

    gram.newRule("def").addToken("closeAngle").addTerm("def.body");
    gram.newRule("def").addTerm("def.body");
    gram.newRule("def.body").addTerm("stateID");
    gram.newRule("def.body").addTerm("tokenID");
    gram.newRule("def.body").addTerm("def.body").addToken("colon").addTerm("matcher.start").addToken("arrow").addTerm("stateID");
    gram.newRule("def.body").addTerm("def.body").addToken("colon").addTerm("matcher.start").addToken("arrow").addTerm("tokenID");

    gram.newRule("stateID").addToken("openParen").addToken("id").addToken("closeParen");
    gram.newRule("tokenID").addToken("openBracket").addToken("id").addToken("closeBracket");

    gram.newRule("matcher.start").addToken("any");
    gram.newRule("matcher.start").addTerm("matcher");
    gram.newRule("matcher.start").addToken("consume").addTerm("matcher");

    gram.newRule("matcher").addTerm("charSetRange");
    gram.newRule("matcher").addTerm("matcher").addToken("comma").addTerm("charSetRange");

    gram.newRule("charSetRange").addToken("charSet");
    gram.newRule("charSetRange").addToken("not").addToken("charSet");
    gram.newRule("charSetRange").addToken("charSet").addToken("range").addToken("charSet");
    gram.newRule("charSetRange").addToken("not").addToken("charSet").addToken("range").addToken("charSet");

    // gram.newRule("def").addTerm("tokenDef");
    // gram.newRule("def").addToken("closeAngle").addTerm("tokenDef");
    // gram.newRule("def").addTerm("tokenDef");

    return gram;
  }

  static Parser getParser() =>
    new Parser.fromGrammar(Loader.getGrammar(), Loader.getTokenizer());

  Loader() {
    Parser parser = new Parser.fromGrammar(getGrammar(), getTokenizer());

    Result result = parser.parse(
      "> (Start)");
      
    print(result);
  }

  Parser load(String name) {
    return null;
  }
}
