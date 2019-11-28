library PatiteParserDart.Parser;

import 'dart:math' as math;

import 'package:PatiteParserDart/src/Grammar/Grammar.dart';

part 'Action.dart';
part 'Builder.dart';
part 'State.dart';
part 'Table.dart';

class Parser {

  Parser._(){
    
  }

  factory Parser.fromGrammar(Grammar grammar) {
    _Builder builder = new _Builder(grammar);
    builder.determineStates();
    builder.fillTable();

    print(builder);

    return new Parser._();
  }

  // TODO: Parser.fromFile
  // TODO: Parser.fromSerial



}

