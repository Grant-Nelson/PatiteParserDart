part of PatiteParserDart.test;

void parser00() {
  print("parser00");
  // S → E $
  // E → T
  // E → ( E )
  // T → n
  // T → + T
  // T → T + n
  Grammar grammar = new Grammar();
  grammar.start("S");
  grammar.accept("\$");
  grammar.newRule("S").addTerm("E").addToken("\$");
  grammar.newRule("E").addTerm("T");
  grammar.newRule("E").addToken("(").addTerm("E").addToken(")");
  grammar.newRule("T").addToken("n");
  grammar.newRule("T").addToken("+").addTerm("T");
  grammar.newRule("T").addTerm("T").addToken("+").addToken("n");
  //print(grammar);

  Parser parser = new Parser.fromGrammar(grammar);
  print(parser);
}

void parser01() {
  print("parser01");
  // S → X $
  // X → ( X )
  // X → ( )
  Grammar grammar = new Grammar();
  grammar.start("S");
  grammar.accept("\$");
  grammar.newRule("S").addTerm("X").addToken("\$");
  grammar.newRule("X").addToken("(").addTerm("X").addToken(")");
  grammar.newRule("X").addToken("(").addToken(")");
  //print(grammar);

  Parser parser = new Parser.fromGrammar(grammar);
  print(parser);
}

void parser02() {
  print("parser02");
  // S → X $
  // X → ( X )
  // X → null
  Grammar grammar = new Grammar();
  grammar.start("S");
  grammar.accept("\$");
  grammar.newRule("S").addTerm("X").addToken("\$");
  grammar.newRule("X").addToken("(").addTerm("X").addToken(")");
  grammar.newRule("X");
  //print(grammar);

  Parser parser = new Parser.fromGrammar(grammar);
  print(parser);
}
