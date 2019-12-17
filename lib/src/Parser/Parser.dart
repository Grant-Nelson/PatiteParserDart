library PatiteParserDart.Parser;

import 'dart:math' as math;

import 'package:PatiteParserDart/src/Grammar/Grammar.dart';
import 'package:PatiteParserDart/src/Tokenizer/Tokenizer.dart';
import 'package:PatiteParserDart/src/Simple/Simple.dart' as Simple;

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
  Tokenizer _tokenizer;

  /// Creates a new grammar.
  Parser._(this._table, this._tokenizer);

  /// Creates a new parser with the given grammar.
  factory Parser.fromGrammar(Grammar grammar, Tokenizer tokenizer) {
    _Builder builder = new _Builder(grammar);
    builder.determineStates();
    builder.fillTable();
    return new Parser._(builder.table, tokenizer);
  }

  /// Creates a parser from the given json serialization.
  factory Parser.deserialize(Simple.Deserializer data) =>
    new Parser._(
      new _Table.deserialize(data.readSer()),
      new Tokenizer.deserialize(data.readSer()));

  /// Serializes the parser into a json serialization.
  Simple.Serializer serialize() =>
    new Simple.Serializer()
      ..writeSer(this._table.serialize())
      ..writeSer(this._tokenizer.serialize());

  /// This parses the given string and returns the results.
  Result parse(String input) =>
    this.parseTokens(this._tokenizer.tokenize(input));

  /// This parses the given characters and returns the results.
  Result parseChars(Iterator<int> iterator) =>
    this.parseTokens(this._tokenizer.tokenizeChars(iterator));

  /// This parses the given tokens and returns the results.
  Result parseTokens(Iterable<Token> tokens, [int errorCap = 0]) {
    _Runner runner = new _Runner(this._table, errorCap);
    for (Token token in tokens) {
      if (!runner.add(token)) return runner.result;
    }
    runner.add(new Token(_eofTokenName, _eofTokenName, -1));
    return runner.result;
  }
}
