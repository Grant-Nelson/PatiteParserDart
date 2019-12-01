part of PatiteParserDart.test;

void parser00() {
  print("parser00");
  // 1. S → E $
  // 2. E → T
  // 3. E → ( E )
  // 4. T → n
  // 5. T → + T
  // 6. T → T + n
  Grammar grammar = new Grammar();
  grammar.start("S");
  grammar.accept("\$");
  grammar.newRule("S").addTerm("E").addToken("\$");
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
  // 1. S → X $
  // 2. X → ( X )
  // 3. X → ( )
  Grammar grammar = new Grammar();
  grammar.start("S");
  grammar.accept("\$");
  grammar.newRule("S").addTerm("X").addToken("\$");
  grammar.newRule("X").addToken("(").addTerm("X").addToken(")");
  grammar.newRule("X").addToken("(").addToken(")");
  Parser parser = new Parser.fromGrammar(grammar);
  print(parser);
}

void parser02() {
  print("parser02");
  // 1. S → X $
  // 2. X → ( X )
  // 3. X → 𝜀
  Grammar grammar = new Grammar();
  grammar.start("S");
  grammar.accept("\$");
  grammar.newRule("S").addTerm("X").addToken("\$");
  grammar.newRule("X").addToken("(").addTerm("X").addToken(")");
  grammar.newRule("X");
  Parser parser = new Parser.fromGrammar(grammar);
  print(parser);
}


void parser03() {
  print("parser02");
  // 1. S' → S $
  // 2. S → b A d S
  // 3. S → 𝜀
  // 4. A → a A
  // 5. A → 𝜀
  Grammar grammar = new Grammar();
  grammar.start("S'");
  grammar.accept("\$");
  grammar.newRule("S'").addTerm("S").addToken("\$");
  grammar.newRule("S").addToken("b").addTerm("A").addToken("d").addTerm("S");
  grammar.newRule("S");
  grammar.newRule("A").addToken("a").addTerm("A");
  grammar.newRule("A");
  Parser parser = new Parser.fromGrammar(grammar);
  print(parser);
}
