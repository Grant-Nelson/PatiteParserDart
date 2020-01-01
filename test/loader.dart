part of PatiteParserDart.test;

void loader00(TestArgs args) {
  args.log('loader00');
  Parser.Parser parser = Parser.Loader.getParser();
  args.checkParser(parser, ["(Start)"],
    ['--def.set',
     '  |--def.set',
     '  `--def',
     '     `--def.tok',
     '        `--stateID',
     '           |--openParen:1:"("',
     '           |--id:6:"Start"',
     '           `--closeParen:7:")"']);

  args.checkParser(parser, ["> (Start)"],
    ['--def.set',
     '  |--def.set',
     '  `--def',
     '     |--closeAngle:1:">"',
     '     `--def.tok',
     '        `--stateID',
     '           |--openParen:3:"("',
     '           |--id:8:"Start"',
     '           `--closeParen:9:")"']);
      
  args.checkParser(parser, ["> (Start): * => (Any)"],
    ['--def.set',
     '  |--def.set',
     '  `--def',
     '     |--closeAngle:1:">"',
     '     `--def.tok',
     '        |--def.tok',
     '        |  `--stateID',
     '        |     |--openParen:3:"("',
     '        |     |--id:8:"Start"',
     '        |     `--closeParen:9:")"',
     '        |--colon:10:":"',
     '        |--matcher.start',
     '        |  `--any:12:"*"',
     '        |--arrow:15:"=>"',
     '        `--stateID',
     '           |--openParen:17:"("',
     '           |--id:20:"Any"',
     '           `--closeParen:21:")"']);
}
       
void loader01(TestArgs args) {
  args.log('loader01');
  Parser.Parser parser = Parser.Loader.getParser();
  args.checkParser(parser, ["(O): 'ab' => (AB): 'cde' => (CDE)"],
    ['--def.set',
     '  |--def.set',
     '  `--def',
     '     `--def.tok',
     '        |--def.tok',
     '        |  |--def.tok',
     '        |  |  `--stateID',
     '        |  |     |--openParen:1:"("',
     '        |  |     |--id:2:"O"',
     '        |  |     `--closeParen:3:")"',
     '        |  |--colon:4:":"',
     '        |  |--matcher.start',
     '        |  |  `--matcher',
     '        |  |     `--charSetRange',
     '        |  |        `--charSet:9:"\'ab\'"',
     '        |  |--arrow:12:"=>"',
     '        |  `--stateID',
     '        |     |--openParen:14:"("',
     '        |     |--id:16:"AB"',
     '        |     `--closeParen:17:")"',
     '        |--colon:18:":"',
     '        |--matcher.start',
     '        |  `--matcher',
     '        |     `--charSetRange',
     '        |        `--charSet:24:"\'cde\'"',
     '        |--arrow:27:"=>"',
     '        `--stateID',
     '           |--openParen:29:"("',
     '           |--id:32:"CDE"',
     '           `--closeParen:33:")"']);
}

void loader02(TestArgs args) {
  args.log('loader02');
  Parser.Parser parser = Parser.Loader.getParser();
  args.checkParser(parser, ["(A)(B)(C)[D]"],
    ['--def.set',
     '  |--def.set',
     '  |  |--def.set',
     '  |  |  |--def.set',
     '  |  |  |  |--def.set',
     '  |  |  |  `--def',
     '  |  |  |     `--def.tok',
     '  |  |  |        `--stateID',
     '  |  |  |           |--openParen:1:"("',
     '  |  |  |           |--id:2:"A"',
     '  |  |  |           `--closeParen:3:")"',
     '  |  |  `--def',
     '  |  |     `--def.tok',
     '  |  |        `--stateID',
     '  |  |           |--openParen:4:"("',
     '  |  |           |--id:5:"B"',
     '  |  |           `--closeParen:6:")"',
     '  |  `--def',
     '  |     `--def.tok',
     '  |        `--stateID',
     '  |           |--openParen:7:"("',
     '  |           |--id:8:"C"',
     '  |           `--closeParen:9:")"',
     '  `--def',
     '     `--def.tok',
     '        `--tokenID',
     '           |--openBracket:10:"["',
     '           |--id:11:"D"',
     '           `--closeBracket:12:"]"']);
}

void loader03(TestArgs args) {
  args.log('loader03');
  Parser.Parser parser = Parser.Loader.getParser();
  args.checkParser(parser, ["(A): ^'a', 'c'..'f', !'abcd' => [D]"],
    ['--def.set',
     '  |--def.set',
     '  `--def',
     '     `--def.tok',
     '        |--def.tok',
     '        |  `--stateID',
     '        |     |--openParen:1:"("',
     '        |     |--id:2:"A"',
     '        |     `--closeParen:3:")"',
     '        |--colon:4:":"',
     '        |--matcher.start',
     '        |  |--consume:6:"^"',
     '        |  `--matcher',
     '        |     |--matcher',
     '        |     |  |--matcher',
     '        |     |  |  `--charSetRange',
     '        |     |  |     `--charSet:9:"\'a\'"',
     '        |     |  |--comma:10:","',
     '        |     |  `--charSetRange',
     '        |     |     |--charSet:14:"\'c\'"',
     '        |     |     |--range:16:".."',
     '        |     |     `--charSet:19:"\'f\'"',
     '        |     |--comma:20:","',
     '        |     `--charSetRange',
     '        |        |--not:22:"!"',
     '        |        `--charSet:28:"\'abcd\'"',
     '        |--arrow:31:"=>"',
     '        `--tokenID',
     '           |--openBracket:33:"["',
     '           |--id:34:"D"',
     '           `--closeBracket:35:"]"']);
}

void loader04(TestArgs args) {
  args.log('loader04');
  Parser.Parser parser = Parser.Loader.getParser();
  args.checkParser(parser, ["(A) => [D]"],
    ['--def.set',
     '  |--def.set',
     '  `--def',
     '     `--def.tok',
     '        |--def.tok',
     '        |  `--stateID',
     '        |     |--openParen:1:"("',
     '        |     |--id:2:"A"',
     '        |     `--closeParen:3:")"',
     '        |--arrow:6:"=>"',
     '        `--tokenID',
     '           |--openBracket:8:"["',
     '           |--id:9:"D"',
     '           `--closeBracket:10:"]"']);

  args.checkParser(parser, ["(A) => ^[D]"],
    ['--def.set',
     '  |--def.set',
     '  `--def',
     '     `--def.tok',
     '        |--def.tok',
     '        |  `--stateID',
     '        |     |--openParen:1:"("',
     '        |     |--id:2:"A"',
     '        |     `--closeParen:3:")"',
     '        |--arrow:6:"=>"',
     '        `--tokenID',
     '           |--consume:8:"^"',
     '           |--openBracket:9:"["',
     '           |--id:10:"D"',
     '           `--closeBracket:11:"]"']);
}
