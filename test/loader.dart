part of PatiteParserDart.test;

void loader00() {
    Parser parser = new Parser.fromGrammar(Loader.getGrammar(), Loader.getTokenizer());

    checkParser(parser, ["(Start)"],
      ["--defSet",
       "  '--def",
       "     '--stateDef",
       "        '--stateID",
       "           |--openParen:1:\"(\"",
       "           |--id:6:\"Start\"",
       "           '--closeParen:7:\")\""]);

    checkParser(parser, ["> (Start)"],
      ["--defSet",
       "  '--def",
       "     |--closeAngle:1:\">\"",
       "     '--stateDef",
       "        '--stateID",
       "           |--openParen:3:\"(\"",
       "           |--id:8:\"Start\"",
       "           '--closeParen:9:\")\""]);
       
    checkParser(parser, ["> (Start): * => (Any)"],
      ["--defSet",
       "  '--def",
       "     |--closeAngle:1:\">\"",
       "     '--stateDef",
       "        |--stateID",
       "        |  |--openParen:3:\"(\"",
       "        |  |--id:8:\"Start\"",
       "        |  '--closeParen:9:\")\"",
       "        |--colon:10:\":\"",
       "        |--matcher",
       "        |  '--any:12:\"*\"",
       "        |--arrow:15:\"=>\"",
       "        '--stateDef",
       "           '--stateID",
       "              |--openParen:17:\"(\"",
       "              |--id:20:\"Any\"",
       "              '--closeParen:21:\")\""]);
       
    checkParser(parser, ["(O): 'ab' => (AB): 'cde' => (CDE)"],
      ["--defSet",
       "  '--def",
       "     '--stateDef",
       "        |--stateID",
       "        |  |--openParen:1:\"(\"",
       "        |  |--id:2:\"O\"",
       "        |  '--closeParen:3:\")\"",
       "        |--colon:4:\":\"",
       "        |--matcher",
       "        |  |--charSet:9:\"'ab'\"",
       "        |  '--matcherTail",
       "        |--arrow:12:\"=>\"",
       "        '--stateDef",
       "           |--stateID",
       "           |  |--openParen:14:\"(\"",
       "           |  |--id:16:\"AB\"",
       "           |  '--closeParen:17:\")\"",
       "           |--colon:18:\":\"",
       "           |--matcher",
       "           |  |--charSet:24:\"'cde'\"",
       "           |  '--matcherTail",
       "           |--arrow:27:\"=>\"",
       "           '--stateDef",
       "              '--stateID",
       "                 |--openParen:29:\"(\"",
       "                 |--id:32:\"CDE\"",
       "                 '--closeParen:33:\")\""]);
       
    checkParser(parser, ["(A)(B)(C)"],
      [""]);
}