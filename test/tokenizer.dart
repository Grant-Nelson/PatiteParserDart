part of PatiteParserDart.test;

void checkTok(Tokenizer tok, String input, List<String> expected) {
  List<String> results = new List<String>();
  for (Token token in tok.tokenize(input))
    results.add(token.toString());
  if (results.length != expected.length) {
    print("Error: The input did not result in correct number of expected results");
    print("  Input:    $input");
    print("  Expected: $expected");
    print("  Results:  $results");
    return;
  }
  for (int i = 0; i < results.length; i++) {
    if (results[i] != expected[i]) {
      print("Error: The input did not result in expected results at an index");
      print("  Input:    $input");
      print("  Index:    $i");
      print("  Expected: $expected");
      print("  Results:  $results");
    }
  }
}

void tokenizer00() {
  Tokenizer tok = new Tokenizer();
  tok.start("start");
  tok.join("start", "id")..addRange("a", "z");
  tok.join("id", "id")..addRange("a", "z");
  tok.join("start", "add")..addSet("+");
  tok.join("start", "mul")..addSet("*");
  tok.join("start", "open")..addSet("(");
  tok.join("start", "close")..addSet(")");
  tok.join("start", "space")..addSet(" ");
  tok.join("space", "space")..addSet(" ");
  tok.setToken("add", "[add]");
  tok.setToken("mul", "[mul]");
  tok.setToken("open", "[open]");
  tok.setToken("close", "[close]");
  tok.setToken("id", "[id]");
  tok.setToken("space", "[space]")..consume();

  checkTok(tok, "hello world", ['[id]:5:"hello"', '[id]:11:"world"']);
  checkTok(tok, "a + b * c", ['[id]:1:"a"', '[add]:3:"+"', '[id]:5:"b"', '[mul]:7:"*"', '[id]:9:"c"']);
  checkTok(tok, "(a + b)", ['[open]:1:"("', '[id]:2:"a"', '[add]:4:"+"', '[id]:6:"b"', '[close]:7:")"']);
  checkTok(tok, "a + (b * c) + d", ['[id]:1:"a"', '[add]:3:"+"', '[open]:5:"("',
    '[id]:6:"b"', '[mul]:8:"*"', '[id]:10:"c"', '[close]:11:")"', '[add]:13:"+"', '[id]:15:"d"']);
}
