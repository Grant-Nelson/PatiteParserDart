part of PatiteParserDart.test;

void parser00() {
  print("parser00");
  // 1. E → T
  // 2. E → ( E )
  // 3. T → n
  // 4. T → + T
  // 5. T → T + n
  Grammar grammar = new Grammar();
  grammar.start("E");
  grammar.newRule("E").addTerm("T");
  grammar.newRule("E").addToken("(").addTerm("E").addToken(")");
  grammar.newRule("T").addToken("n");
  grammar.newRule("T").addToken("+").addTerm("T");
  grammar.newRule("T").addTerm("T").addToken("+").addToken("n");
  Parser parser = new Parser.fromGrammar(grammar);
  print(parser);
}

void parser01() {
  print("parser01");
  // 1. X → ( X )
  // 2. X → ( )
  Grammar grammar = new Grammar();
  grammar.start("X");
  grammar.newRule("X").addToken("(").addTerm("X").addToken(")");
  grammar.newRule("X").addToken("(").addToken(")");
  Parser parser = new Parser.fromGrammar(grammar);
  print(parser);
}

void parser02() {
  print("parser02");
  // 1. X → ( X )
  // 2. X → 𝜀
  Grammar grammar = new Grammar();
  grammar.start("X");
  grammar.newRule("X").addToken("(").addTerm("X").addToken(")");
  grammar.newRule("X");
  Parser parser = new Parser.fromGrammar(grammar);
  print(parser);
}

void parser03() {
  print("parser03");
  // 1. S → b A d S
  // 2. S → 𝜀
  // 3. A → a A
  // 4. A → 𝜀
  Grammar grammar = new Grammar();
  grammar.start("S");
  grammar.newRule("S").addToken("b").addTerm("A").addToken("d").addTerm("S");
  grammar.newRule("S");
  grammar.newRule("A").addToken("a").addTerm("A");
  grammar.newRule("A");
  Parser parser = new Parser.fromGrammar(grammar);
  print(parser);
}

void parser04() {
  print("parser04");
  Tokenizer tok = new Tokenizer();
  tok.start("start");
  tok.join("start", "id")..addRange("a", "z");
  tok.join("id", "id")..addRange("a", "z");
  tok.join("start", "add")..addSet("+");
  tok.join("start", "mul")..addSet("*");
  tok.join("start", "open")..addSet("(");
  tok.join("start", "close")..addSet(")");
  tok.join("start", "start")..addSet(" ")..consume = true;
  tok.setToken("add", "+");
  tok.setToken("mul", "*");
  tok.setToken("open", "(");
  tok.setToken("close", ")");
  tok.setToken("id", "id");
  // 1. E → E + E
  // 2. E → E * E
  // 3. E → ( E )
  // 4. E → id
  Grammar grammar = new Grammar();
  grammar.start("E");
  grammar.newRule("E").addTerm("E").addToken("+").addTerm("E");
  grammar.newRule("E").addTerm("E").addToken("*").addTerm("E");
  grammar.newRule("E").addToken("(").addTerm("E").addToken(")");
  grammar.newRule("E").addToken("id");
  Parser parser = new Parser.fromGrammar(grammar);

  //Result result = parser.parse(tok.tokenize("a + b * c"));
  Result result = parser.parse(tok.tokenize("(a + b)"));
  //Result result = parser.parse(tok.tokenize("a + (b * c) + d"));

  print(result);
}
