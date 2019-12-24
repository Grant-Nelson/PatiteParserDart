part of PatiteParserDart.test;

void tokenizer00(TestArgs args) {
  args.log('tokenizer00');

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

  args.checkTok(tok, "hello world",
    ['[id]:5:"hello"',
     '[id]:11:"world"']);

  args.checkTok(tok, "a + b * c",
    ['[id]:1:"a"',
     '[add]:3:"+"',
     '[id]:5:"b"',
     '[mul]:7:"*"',
     '[id]:9:"c"']);

  args.checkTok(tok, "(a + b)",
    ['[open]:1:"("',
     '[id]:2:"a"',
     '[add]:4:"+"',
     '[id]:6:"b"',
     '[close]:7:")"']);
  
  args.checkTok(tok, "a + (b * c) + d",
    ['[id]:1:"a"',
     '[add]:3:"+"',
     '[open]:5:"("',
     '[id]:6:"b"',
     '[mul]:8:"*"',
     '[id]:10:"c"',
     '[close]:11:")"',
     '[add]:13:"+"',
     '[id]:15:"d"']);
}

void tokenizer01(TestArgs args) {
  args.log('tokenizer01');

  Tokenizer tok = new Tokenizer();
  tok.start("start");
  //         .--a--(a1)--b--(b1)[ab]--c--(c2)--d--(d2)--f--(f1)[abcdf]
  // start--{---c--(c1)--d--(d1)[cd]
  //         '--e--(e1)[e]
  tok.join("start", "(a1)")..addSet("a");
  tok.join("(a1)", "(b1)")..addSet("b");
  tok.join("(b1)", "(c2)")..addSet("c");
  tok.join("(c2)", "(d2)")..addSet("d");
  tok.join("(d2)", "(f1)")..addSet("f");
  tok.join("start", "(c1)")..addSet("c");
  tok.join("(c1)", "(d1)")..addSet("d");
  tok.join("start", "(e1)")..addSet("e");
  tok.setToken("(b1)", "[ab]");
  tok.setToken("(d1)", "[cd]");
  tok.setToken("(f1)", "[abcdf]");
  tok.setToken("(e1)", "[e]");

  args.checkTok(tok, "abcde",
    ['[ab]:2:"ab"',
     '[cd]:4:"cd"',
     '[e]:5:"e"']);
}
