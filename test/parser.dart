part of PatiteParserDart.test;

void parser00() {
  // S → E
  // E → T
  // E → ( E )
  // T → n
  // T → + T
  // T → T + n
  Grammar grammar = new Grammar();
  grammar.start("S");
  grammar.newRule("S").addTerm("E");
  grammar.newRule("E").addTerm("T");
  grammar.newRule("E").addToken("(").addTerm("E").addToken(")");
  grammar.newRule("T").addToken("n");
  grammar.newRule("T").addToken("+").addTerm("T");
  grammar.newRule("T").addTerm("T").addToken("+").addToken("n");

  print(grammar);

  Parser parser = new Parser.fromGrammar(grammar);

  print(parser);
  //grammar.calculate();
}
