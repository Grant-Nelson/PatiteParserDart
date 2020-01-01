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
  Grammar.Grammar gram = new Grammar.Grammar();
  Grammar.Rule rule0 = gram.newRule('E');
  Grammar.Rule rule1 = gram.newRule('E').addTerm("E").addToken("+").addTerm("E");
  Grammar.Rule rule2 = gram.newRule('E').addTerm("E").addToken("+").addTerm("E").addTrigger('add');
  Grammar.Rule rule3 = gram.newRule('E').addTerm("E").addToken("+").addTrigger('add').addTerm("E");
  Grammar.Rule rule4 = gram.newRule('E').addTrigger('add').addTerm("E").addToken("+").addTerm("E");

  args.checkRuleString(rule0, -1, '<E> → ');
  args.checkRuleString(rule0,  0, '<E> → •');
  args.checkRuleString(rule0,  1, '<E> → ');

  args.checkRuleString(rule1, -1, '<E> → <E> [+] <E>');
  args.checkRuleString(rule1,  0, '<E> → • <E> [+] <E>');
  args.checkRuleString(rule1,  1, '<E> → <E> • [+] <E>');
  args.checkRuleString(rule1,  2, '<E> → <E> [+] • <E>');
  args.checkRuleString(rule1,  3, '<E> → <E> [+] <E> •');
  args.checkRuleString(rule1,  4, '<E> → <E> [+] <E>');

  args.checkRuleString(rule2, -1, '<E> → <E> [+] <E> {add}');
  args.checkRuleString(rule2,  0, '<E> → • <E> [+] <E> {add}');
  args.checkRuleString(rule2,  1, '<E> → <E> • [+] <E> {add}');
  args.checkRuleString(rule2,  2, '<E> → <E> [+] • <E> {add}');
  args.checkRuleString(rule2,  3, '<E> → <E> [+] <E> • {add}');
  args.checkRuleString(rule2,  4, '<E> → <E> [+] <E> {add}');

  args.checkRuleString(rule3, -1, '<E> → <E> [+] {add} <E>');
  args.checkRuleString(rule3,  0, '<E> → • <E> [+] {add} <E>');
  args.checkRuleString(rule3,  1, '<E> → <E> • [+] {add} <E>');
  args.checkRuleString(rule3,  2, '<E> → <E> [+] • {add} <E>');
  args.checkRuleString(rule3,  3, '<E> → <E> [+] {add} <E> •');
  args.checkRuleString(rule3,  4, '<E> → <E> [+] {add} <E>');

  args.checkRuleString(rule4, -1, '<E> → {add} <E> [+] <E>');
  args.checkRuleString(rule4,  0, '<E> → • {add} <E> [+] <E>');
  args.checkRuleString(rule4,  1, '<E> → {add} <E> • [+] <E>');
  args.checkRuleString(rule4,  2, '<E> → {add} <E> [+] • <E>');
  args.checkRuleString(rule4,  3, '<E> → {add} <E> [+] <E> •');
  args.checkRuleString(rule4,  4, '<E> → {add} <E> [+] <E>');
}
