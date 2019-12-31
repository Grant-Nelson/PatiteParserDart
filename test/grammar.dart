part of PatiteParserDart.test;

void grammar00(TestArgs args) {
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
