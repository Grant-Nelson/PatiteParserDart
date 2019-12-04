library PatiteParserDart.Parser;

import 'dart:math' as math;

import 'package:PatiteParserDart/src/Grammar/Grammar.dart';
import 'package:PatiteParserDart/src/Tokenizer/Tokenizer.dart';

part 'Action.dart';
part 'Builder.dart';
part 'Result.dart';
part 'Runner.dart';
part 'State.dart';
part 'Table.dart';
part 'TreeNode.dart';

const String _startTerm    = 'startTerm';
const String _eofTokenName = 'eofToken';

/// This is a parser for running tokens against a grammar to see
/// if the tokens are part of that grammar.
class Parser {
  _Table _table;

  /// Creates a new grammar.
  Parser._(this._table);

  /// Creates a new parser with the given grammar.
  factory Parser.fromGrammar(Grammar grammar) {
    _Builder builder = new _Builder(grammar);
    builder.determineStates();
    builder.fillTable();
    print(builder); // Uncomment to help with debugging.
    return new Parser._(builder.table);
  }

  // TODO: Parser.fromFile
  // TODO: Parser.fromSerial
  // TODO: Serialize

  /// This parses the given tokens and returns the results.
  Result parse(Iterable<Token> tokens, [int errorCap = 0]) {
    print("]] tokens: $tokens");
    _Runner runner = new _Runner(this._table, errorCap);
    for (Token token in tokens) {
      if (!runner.add(token)) return runner.result;
    }
    runner.add(new Token(_eofTokenName, _eofTokenName, -1));
    return runner.result;
  }
}
