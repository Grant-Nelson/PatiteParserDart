part of PatiteParserDart.test;

void tokenizer00() {
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

  // tok.tokenize("a + b * c");
  print(tok.tokenize("(a + b)"));
  // tok.tokenize("a + (b * c) + d");
}
