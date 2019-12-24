part of PatiteParserDart.test;

void loader00(TestArgs args) {
    args.log('loader00');

    Parser parser = new Parser.fromGrammar(Loader.getGrammar(), Loader.getTokenizer());
    args.checkParser(parser, ["(Start)"],
      ['--defSet',
       '  |--defSet',
       '  `--def',
       '     `--stateDef',
       '        `--stateID',
       '           |--openParen:1:"("',
       '           |--id:6:"Start"',
       '           `--closeParen:7:")"']);

    args.checkParser(parser, ["> (Start)"],
      ['--defSet',
       '  |--defSet',
       '  `--def',
       '     |--closeAngle:1:">"',
       '     `--stateDef',
       '        `--stateID',
       '           |--openParen:3:"("',
       '           |--id:8:"Start"',
       '           `--closeParen:9:")"']);
       
    args.checkParser(parser, ["> (Start): * => (Any)"],
      ['--defSet',
       '  |--defSet',
       '  `--def',
       '     |--closeAngle:1:">"',
       '     `--stateDef',
       '        |--stateID',
       '        |  |--openParen:3:"("',
       '        |  |--id:8:"Start"',
       '        |  `--closeParen:9:")"',
       '        |--colon:10:":"',
       '        |--startMatcher',
       '        |  `--any:12:"*"',
       '        |--arrow:15:"=>"',
       '        `--stateDef',
       '           `--stateID',
       '              |--openParen:17:"("',
       '              |--id:20:"Any"',
       '              `--closeParen:21:")"']);
       
    args.checkParser(parser, ["(O): 'ab' => (AB): 'cde' => (CDE)"],
      ['--defSet',
       '  |--defSet',
       '  `--def',
       '     `--stateDef',
       '        |--stateID',
       '        |  |--openParen:1:"("',
       '        |  |--id:2:"O"',
       '        |  `--closeParen:3:")"',
       '        |--colon:4:":"',
       '        |--startMatcher',
       '        |  `--matcher',
       '        |     `--charSetRange',
       '        |        `--charSet:9:"\'ab\'"',
       '        |--arrow:12:"=>"',
       '        `--stateDef',
       '           |--stateID',
       '           |  |--openParen:14:"("',
       '           |  |--id:16:"AB"',
       '           |  `--closeParen:17:")"',
       '           |--colon:18:":"',
       '           |--startMatcher',
       '           |  `--matcher',
       '           |     `--charSetRange',
       '           |        `--charSet:24:"\'cde\'"',
       '           |--arrow:27:"=>"',
       '           `--stateDef',
       '              `--stateID',
       '                 |--openParen:29:"("',
       '                 |--id:32:"CDE"',
       '                 `--closeParen:33:")"']);
}
      
void loader01(TestArgs args) {
    args.log('loader01');
    
    //Parser parser = new Parser.fromGrammar(Loader.getGrammar(), Loader.getTokenizer());
    // checkParser(parser, ["(A)(B)(C)"],
    //   ['']);
}