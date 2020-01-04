part of PatiteParserDart.test;

void parser00(TestArgs args) {
  args.log('parser00');

  Tokenizer.Tokenizer tok = new Tokenizer.Tokenizer();
  tok.start("start");
  tok.join("start", "(")..addSet("(");
  tok.join("start", ")")..addSet(")");
  tok.join("start", "+")..addSet("+");
  tok.join("start", "num")..addRange("0", "9");
  tok.join("num", "num")..addRange("0", "9");
  tok.setToken("(", "(");
  tok.setToken(")", ")");
  tok.setToken("+", "+");
  tok.setToken("num", "n");
  // 1. E → T
  // 2. E → ( E )
  // 3. T → n
  // 4. T → + T
  // 5. T → T + n
  Grammar.Grammar grammar = new Grammar.Grammar();
  grammar.start("E");
  grammar.newRule("E").addTerm("T");
  grammar.newRule("E").addToken("(").addTerm("E").addToken(")");
  grammar.newRule("T").addToken("n");
  grammar.newRule("T").addToken("+").addTerm("T");
  grammar.newRule("T").addTerm("T").addToken("+").addToken("n");
  Parser.Parser parser = new Parser.Parser.fromGrammar(grammar, tok);
  args.checkParser(parser, ["103"],
    ['─<E>',
     '  └─<T>',
     '     └─[n:3:"103"]']);
  args.checkParser(parser, ["+2"],
    ['─<E>',
     '  └─<T>',
     '     ├─[+:1:"+"]',
     '     └─<T>',
     '        └─[n:2:"2"]']);
  args.checkParser(parser, ["3+4"],
    ['─<E>',
     '  └─<T>',
     '     ├─<T>',
     '     │  └─[n:1:"3"]',
     '     ├─[+:2:"+"]',
     '     └─[n:3:"4"]']);
  args.checkParser(parser, ["((42+6))"],
    ['─<E>',
     '  ├─[(:1:"("]',
     '  ├─<E>',
     '  │  ├─[(:2:"("]',
     '  │  ├─<E>',
     '  │  │  └─<T>',
     '  │  │     ├─<T>',
     '  │  │     │  └─[n:4:"42"]',
     '  │  │     ├─[+:5:"+"]',
     '  │  │     └─[n:6:"6"]',
     '  │  └─[):7:")"]',
     '  └─[):8:")"]']);
}

void parser01(TestArgs args) {
  args.log('parser01');

  Tokenizer.Tokenizer tok = new Tokenizer.Tokenizer();
  tok.start("start");
  tok.join("start", "(")..addSet("(");
  tok.join("start", ")")..addSet(")");
  tok.setToken("(", "(");
  tok.setToken(")", ")");
  // 1. X → ( X )
  // 2. X → ( )
  Grammar.Grammar grammar = new Grammar.Grammar();
  grammar.start("X");
  grammar.newRule("X").addToken("(").addTerm("X").addToken(")");
  grammar.newRule("X").addToken("(").addToken(")");
  Parser.Parser parser = new Parser.Parser.fromGrammar(grammar, tok);
  args.checkParser(parser, ["()"],
    ['─<X>',
     '  ├─[(:1:"("]',
     '  └─[):2:")"]']);
  args.checkParser(parser, ["((()))"],
    ['─<X>',
     '  ├─[(:1:"("]',
     '  ├─<X>',
     '  │  ├─[(:2:"("]',
     '  │  ├─<X>',
     '  │  │  ├─[(:3:"("]',
     '  │  │  └─[):4:")"]',
     '  │  └─[):5:")"]',
     '  └─[):6:")"]']);
}

void parser02(TestArgs args) {
  args.log('parser02');

  Tokenizer.Tokenizer tok = new Tokenizer.Tokenizer();
  tok.start("start");
  tok.join("start", "(")..addSet("(");
  tok.join("start", ")")..addSet(")");
  tok.setToken("(", "(");
  tok.setToken(")", ")");
  // 1. X → ( X )
  // 2. X → 𝜀
  Grammar.Grammar grammar = new Grammar.Grammar();
  grammar.start("X");
  grammar.newRule("X").addToken("(").addTerm("X").addToken(")");
  grammar.newRule("X");
  Parser.Parser parser = new Parser.Parser.fromGrammar(grammar, tok);
  args.checkParser(parser, [""],
    ['─<X>']);
  args.checkParser(parser, ["()"],
    ['─<X>',
     '  ├─[(:1:"("]',
     '  ├─<X>',
     '  └─[):2:")"]']);
  args.checkParser(parser, ["((()))"],
    ['─<X>',
     '  ├─[(:1:"("]',
     '  ├─<X>',
     '  │  ├─[(:2:"("]',
     '  │  ├─<X>',
     '  │  │  ├─[(:3:"("]',
     '  │  │  ├─<X>',
     '  │  │  └─[):4:")"]',
     '  │  └─[):5:")"]',
     '  └─[):6:")"]']);
}

void parser03(TestArgs args) {
  args.log('parser03');

  Tokenizer.Tokenizer tok = new Tokenizer.Tokenizer();
  tok.start("start");
  tok.join("start", "a")..addSet("a");
  tok.join("start", "b")..addSet("b");
  tok.join("start", "d")..addSet("d");
  tok.setToken("a", "a");
  tok.setToken("b", "b");
  tok.setToken("d", "d");
  // 1. S → b A d S
  // 2. S → 𝜀
  // 3. A → a A
  // 4. A → 𝜀
  Grammar.Grammar grammar = new Grammar.Grammar();
  grammar.start("S");
  grammar.newRule("S").addToken("b").addTerm("A").addToken("d").addTerm("S");
  grammar.newRule("S");
  grammar.newRule("A").addToken("a").addTerm("A");
  grammar.newRule("A");
  Parser.Parser parser = new Parser.Parser.fromGrammar(grammar, tok);
  args.checkParser(parser, ["bd"],
    ['─<S>',
     '  ├─[b:1:"b"]',
     '  ├─<A>',
     '  ├─[d:2:"d"]',
     '  └─<S>']);
  args.checkParser(parser, ["bad"],
    ['─<S>',
     '  ├─[b:1:"b"]',
     '  ├─<A>',
     '  │  ├─[a:2:"a"]',
     '  │  └─<A>',
     '  ├─[d:3:"d"]',
     '  └─<S>']);
  args.checkParser(parser, ["bdbadbd"],
    ['─<S>',
     '  ├─[b:1:"b"]',
     '  ├─<A>',
     '  ├─[d:2:"d"]',
     '  └─<S>',
     '     ├─[b:3:"b"]',
     '     ├─<A>',
     '     │  ├─[a:4:"a"]',
     '     │  └─<A>',
     '     ├─[d:5:"d"]',
     '     └─<S>',
     '        ├─[b:6:"b"]',
     '        ├─<A>',
     '        ├─[d:7:"d"]',
     '        └─<S>']);
}

void parser04(TestArgs args) {
  args.log('parser04');

  Tokenizer.Tokenizer tok = new Tokenizer.Tokenizer();
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
  Grammar.Grammar grammar = new Grammar.Grammar();
  grammar.start("E");
  grammar.newRule("E").addTerm("E").addToken("+").addTerm("E");
  grammar.newRule("E").addTerm("E").addToken("*").addTerm("E");
  grammar.newRule("E").addToken("(").addTerm("E").addToken(")");
  grammar.newRule("E").addToken("id");
  Parser.Parser parser = new Parser.Parser.fromGrammar(grammar, tok);
  
  // Test serializing and deserializing too.
  String data = parser.serialize().toString();
  parser = new Parser.Parser.deserialize(new Simple.Deserializer(data));
  args.checkParser(parser, ["a"],
    ['─<E>',
     '  └─[id:1:"a"]']);
  args.checkParser(parser, ["(a + b)"],
    ['─<E>',
     '  ├─[(:1:"("]',
     '  ├─<E>',
     '  │  ├─<E>',
     '  │  │  └─[id:2:"a"]',
     '  │  ├─[+:4:"+"]',
     '  │  └─<E>',
     '  │     └─[id:6:"b"]',
     '  └─[):7:")"]']);
  args.checkParser(parser, ["a + b * c"],
    ['─<E>',
     '  ├─<E>',
     '  │  └─[id:1:"a"]',
     '  ├─[+:3:"+"]',
     '  └─<E>',
     '     ├─<E>',
     '     │  └─[id:5:"b"]',
     '     ├─[*:7:"*"]',
     '     └─<E>',
     '        └─[id:9:"c"]']);
  args.checkParser(parser, ["a + (b * c) + d"],
    ['─<E>',
     '  ├─<E>',
     '  │  └─[id:1:"a"]',
     '  ├─[+:3:"+"]',
     '  └─<E>',
     '     ├─<E>',
     '     │  ├─[(:5:"("]',
     '     │  ├─<E>',
     '     │  │  ├─<E>',
     '     │  │  │  └─[id:6:"b"]',
     '     │  │  ├─[*:8:"*"]',
     '     │  │  └─<E>',
     '     │  │     └─[id:10:"c"]',
     '     │  └─[):11:")"]',
     '     ├─[+:13:"+"]',
     '     └─<E>',
     '        └─[id:15:"d"]']);
}

void parser05(TestArgs args) {
  args.log('parser05');

  Tokenizer.Tokenizer tok = new Tokenizer.Tokenizer();
  tok.start("start");
  tok.join("start", "a").addSet("a");
  tok.setToken("a", "a");

  Grammar.Grammar grammar = new Grammar.Grammar();
  grammar.start("E");
  grammar.newRule("E");
  grammar.newRule("E").addTerm("E").addTerm("T");
  grammar.newRule("T").addToken("a");
  Parser.Parser parser = new Parser.Parser.fromGrammar(grammar, tok);
    
  args.checkParser(parser, ["aaa"],
    ['─<E>',
     '  ├─<E>',
     '  │  ├─<E>',
     '  │  │  ├─<E>',
     '  │  │  └─<T>',
     '  │  │     └─[a:1:"a"]',
     '  │  └─<T>',
     '  │     └─[a:2:"a"]',
     '  └─<T>',
     '     └─[a:3:"a"]']);
}

void parser06(TestArgs args) {
  args.log('parser06');

  Tokenizer.Tokenizer tok = new Tokenizer.Tokenizer();
  tok.start("start");
  tok.joinToToken("start", "*").addSet("*");

  Grammar.Grammar grammar = new Grammar.Grammar();
  grammar.start("E");
  grammar.newRule("E");
  grammar.newRule("E").addTerm("T").addTerm("E");
  grammar.newRule("T").addToken("*");

  args.checkParserBuildError(grammar, tok,
    ['Exception: Errors while building parser:',
     'state 0:',
     '  <startTerm> → • <E> [eofToken]',
     '  <E> → •',
     '  <E> → • <T> <E>',
     '  <T> → • [*]',
     '  <E>: goto state 1',
     '  <T>: goto state 2',
     '  [*]: goto state 3',
     'state 1:',
     '  <startTerm> → <E> • [eofToken]',
     'state 2:',
     '  <E> → <T> • <E>',
     '  <E> → •',
     '  <E> → • <T> <E>',
     '  <T> → • [*]',
     '  <E>: goto state 4',
     '  <T>: goto state 2',
     '  [*]: goto state 3',
     'state 3:',
     '  <T> → [*] •',
     'state 4:',
     '  <E> → <T> <E> •',
     '',
     'Infinite goto loop found in term T between the state(s) [2].']);
}
