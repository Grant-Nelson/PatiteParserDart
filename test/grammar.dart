part of PatiteParserDart.test;

void grammar00(TestArgs args) {
  args.log('grammar00');

  Grammar.Grammar gram = new Grammar.Grammar();
  gram.start("defSet");
  gram.newRule("defSet").addTerm("defSet").addTerm("def");
  gram.newRule("defSet");

  gram.newRule("def").addTerm("stateDef").addTerm("defBody");
  gram.newRule("stateDef").addToken("closeAngle");
  gram.newRule("stateDef");
  gram.newRule("defBody").addTerm("stateOrTokenID");
  gram.newRule("defBody").addTerm("defBody").addToken("colon").addToken("arrow").addTerm("stateOrTokenID");

  gram.newRule("stateOrTokenID").addTerm("stateID");
  gram.newRule("stateOrTokenID").addTerm("tokenID");
  gram.newRule("stateID").addToken("openParen").addToken("id").addToken("closeParen");
  gram.newRule("tokenID").addToken("openBracket").addToken("id").addToken("closeBracket");

  args.checkGrammar(gram,
    ['> <defSet>',
     '<defSet> → <defSet> <def>',
     '<defSet> → ',
     '<def> → <stateDef> <defBody>',
     '<stateDef> → [closeAngle]',
     '<stateDef> → ',
     '<defBody> → <stateOrTokenID>',
     '<defBody> → <defBody> [colon] [arrow] <stateOrTokenID>',
     '<stateOrTokenID> → <stateID>',
     '<stateOrTokenID> → <tokenID>',
     '<stateID> → [openParen] [id] [closeParen]',
     '<tokenID> → [openBracket] [id] [closeBracket]']);

  args.checkTermFirst(gram, 'defSet', ['[closeAngle]', '[openParen]', '[openBracket]']);
  args.checkTermFollow(gram, 'defSet', ['[closeAngle]', '[openParen]', '[openBracket]']);

  args.checkTermFirst(gram, 'def', ['[closeAngle]', '[openParen]', '[openBracket]']);
  args.checkTermFollow(gram, 'def', ['[closeAngle]', '[openParen]', '[openBracket]']);

  args.checkTermFirst(gram, 'stateDef', ['[closeAngle]', '[openParen]', '[openBracket]']);
  args.checkTermFollow(gram, 'stateDef', ['[openParen]', '[openBracket]']);
  
  args.checkTermFirst(gram, 'defBody', ['[openParen]', '[openBracket]']);
  args.checkTermFollow(gram, 'defBody', ['[closeAngle]', '[openParen]', '[openBracket]', '[colon]']);
  
  args.checkTermFirst(gram, 'stateOrTokenID', ['[openParen]', '[openBracket]']);
  args.checkTermFollow(gram, 'stateOrTokenID', ['[closeAngle]', '[openParen]', '[openBracket]', '[colon]']);

  args.checkTermFirst(gram, 'stateID', ['[openParen]']);
  args.checkTermFollow(gram, 'stateID', ['[closeAngle]', '[openParen]', '[openBracket]', '[colon]']);

  args.checkTermFirst(gram, 'tokenID', ['[openBracket]']);
  args.checkTermFollow(gram, 'tokenID', ['[closeAngle]', '[openParen]', '[openBracket]', '[colon]']);
}

void grammar01(TestArgs args) {
  args.log('grammar01');

  Grammar.Grammar gram1 = new Grammar.Grammar();
  gram1.start("def.set");
  gram1.newRule("def.set").addTerm("def.set").addTerm("def");
  gram1.newRule("def.set");

  gram1.newRule("def").addToken("closeAngle").addTerm("def.tok");
  gram1.newRule("def").addTerm("def.tok");
  gram1.newRule("def.tok").addTerm("stateID");
  gram1.newRule("def.tok").addTerm("tokenID");
  gram1.newRule("def.tok").addTerm("def.tok").addToken("colon").addTerm("matcher.start").addToken("arrow").addTerm("stateID");
  gram1.newRule("def.tok").addTerm("def.tok").addToken("colon").addTerm("matcher.start").addToken("arrow").addTerm("tokenID");
  gram1.newRule("def.tok").addTerm("def.tok").addToken("arrow").addTerm("tokenID");

  gram1.newRule("stateID").addToken("openParen").addToken("id").addToken("closeParen").addTrigger("new.state");
  gram1.newRule("tokenID").addToken("openBracket").addToken("id").addToken("closeBracket").addTrigger("new.token");
  gram1.newRule("tokenID").addToken("consume").addToken("openBracket").addToken("id").addToken("closeBracket").addTrigger("new.token.consume");

  gram1.newRule("matcher.start").addToken("any").addTrigger("match.any");
  gram1.newRule("matcher.start").addTerm("matcher");
  gram1.newRule("matcher.start").addToken("consume").addTrigger("match.consume").addTerm("matcher");

  gram1.newRule("matcher").addTerm("charSetRange");
  gram1.newRule("matcher").addTerm("matcher").addToken("comma").addTerm("charSetRange");

  gram1.newRule("charSetRange").addToken("charSet").addTrigger("match.set");
  gram1.newRule("charSetRange").addToken("not").addToken("charSet").addTrigger("match.set.not");
  gram1.newRule("charSetRange").addToken("charSet").addToken("range").addToken("charSet").addTrigger("match.range");
  gram1.newRule("charSetRange").addToken("not").addToken("charSet").addToken("range").addToken("charSet").addTrigger("match.range.not");
  
Grammar.Grammar gram2 = new Grammar.Grammar();
  gram2.start("def.set");
  gram2.newRule("def.set").addTerm("def.set").addTerm("def");
  gram2.newRule("def.set");

  gram2.newRule("def").addToken("closeAngle").addTerm("def.tok");
  gram2.newRule("def").addTerm("def.tok");
  gram2.newRule("def.tok").addTerm("stateID");
  gram2.newRule("def.tok").addTerm("tokenID");
  gram2.newRule("def.tok").addTerm("def.tok").addToken("colon").addTerm("matcher.start").addToken("arrow").addTerm("stateID");
  gram2.newRule("def.tok").addTerm("def.tok").addToken("colon").addTerm("matcher.start").addToken("arrow").addTerm("tokenID");
  gram2.newRule("def.tok").addTerm("def.tok").addToken("arrow").addTerm("tokenID");

  gram2.newRule("stateID").addToken("openParen").addToken("id").addToken("closeParen");
  gram2.newRule("tokenID").addToken("openBracket").addToken("id").addToken("closeBracket");
  gram2.newRule("tokenID").addToken("consume").addToken("openBracket").addToken("id").addToken("closeBracket");

  gram2.newRule("matcher.start").addToken("any");
  gram2.newRule("matcher.start").addTerm("matcher");
  gram2.newRule("matcher.start").addToken("consume").addTerm("matcher");

  gram2.newRule("matcher").addTerm("charSetRange");
  gram2.newRule("matcher").addTerm("matcher").addToken("comma").addTerm("charSetRange");

  gram2.newRule("charSetRange").addToken("charSet");
  gram2.newRule("charSetRange").addToken("not").addToken("charSet");
  gram2.newRule("charSetRange").addToken("charSet").addToken("range").addToken("charSet");
  gram2.newRule("charSetRange").addToken("not").addToken("charSet").addToken("range").addToken("charSet");
  
  String debug1 = Parser.Parser.getDebugStateString(gram1);
  String debug2 = Parser.Parser.getDebugStateString(gram2);
  args.error(Diff.plusMinusLines(debug1, debug2));
}