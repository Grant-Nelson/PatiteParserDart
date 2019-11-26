library PatiteParserDart.Parser;

import 'package:PatiteParserDart/src/Grammar/Grammar.dart';
import '../Builder/Builder.dart';

class Parser {

  Parser._(){
    
  }

  factory Parser.fromGrammar(Grammar grammar) {
    Builder builder = new Builder();
    builder.setGrammar(grammar);
    builder.determineFirstsAndFollows();
    builder.determineStates();

    print(builder);

    return new Parser._();
  }

  // TODO: Parser.fromFile
  // TODO: Parser.fromSerial



}

