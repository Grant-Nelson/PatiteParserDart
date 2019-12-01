library PatiteParserDart.Parser;

import 'dart:math' as math;

import 'package:PatiteParserDart/src/Grammar/Grammar.dart';

part 'Action.dart';
part 'Builder.dart';
part 'State.dart';
part 'Table.dart';

class Parser {
  _Table _table;

  Parser._(this._table) {
    
  }

  factory Parser.fromGrammar(Grammar grammar) {
    _Builder builder = new _Builder(grammar);
    builder.determineStates();
    builder.fillTable();
    //print(builder); // Uncomment to print rules and table.
    return new Parser._(builder.table);
  }

  // TODO: Parser.fromFile
  // TODO: Parser.fromSerial



}

