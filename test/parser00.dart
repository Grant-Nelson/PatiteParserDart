part of PatiteParserDart.test;

void parser00() {
  // S → E
  // E → T
  // E → ( E )
  // T → n
  // T → + T
  // T → T + n
  Parser parser = new Parser();
  parser.start("S");
  parser.newRule("S").addTerm("E");
  parser.newRule("E").addTerm("T");
  parser.newRule("E").addToken("(").addTerm("E").addToken(")");
  parser.newRule("T").addToken("n");
  parser.newRule("T").addToken("+").addTerm("T");
  parser.newRule("T").addTerm("T").addToken("+").addToken("n");

  print(parser);
  parser.calculate();
}
