library PatiteParserDart.Parser;

import 'dart:math' as math;

import 'package:PatiteParserDart/src/Grammar/Grammar.dart' as Grammar;
import 'package:PatiteParserDart/src/Matcher/Matcher.dart' as Matcher;
import 'package:PatiteParserDart/src/Tokenizer/Tokenizer.dart' as Tokenizer;
import 'package:PatiteParserDart/src/Simple/Simple.dart' as Simple;
import 'package:PatiteParserDart/src/ParseTree/ParseTree.dart' as ParseTree;

part 'Action.dart';
part 'Builder.dart';
part 'Loader.dart';
part 'Result.dart';
part 'Runner.dart';
part 'State.dart';
part 'Table.dart';

const String _startTerm    = 'startTerm';
const String _eofTokenName = 'eofToken';

/// This is a parser for running tokens against a grammar to see
/// if the tokens are part of that grammar.
class Parser {
  _Table _table;
  Grammar.Grammar _grammar;
  Tokenizer.Tokenizer _tokenizer;

  static String getDebugStateString(Grammar.Grammar grammar) {
    _Builder builder = new _Builder(grammar.copy());
    builder.determineStates();
    StringBuffer buf = new StringBuffer();
    for (_State state in builder._states) {
       buf.write(state.toString());
    }
    return buf.toString();
  }

  /// Creates a new grammar.
  Parser._(this._table, this._grammar, this._tokenizer);

  /// Creates a new parser with the given grammar.
  factory Parser.fromGrammar(Grammar.Grammar grammar, Tokenizer.Tokenizer tokenizer) {
    String errors = grammar.validate();
    if (errors.isNotEmpty)
      throw new Exception('Error: Parser can not use invalid grammar:\n' + errors);

    grammar = grammar.copy();
    _Builder builder = new _Builder(grammar);
    builder.determineStates();
    builder.fillTable();
    String errs = builder.buildErrors;
    if (errs.isNotEmpty)
      throw new Exception('Errors while building parser:\n' + builder.toString(showTable: false));
    return new Parser._(builder.table, grammar, tokenizer);
  }

  /// Creates a parser from the given json serialization.
  factory Parser.deserialize(Simple.Deserializer data) {
    int version = data.readInt();
    if (version != 1)
      throw new Exception('Unknown version, $version, for parser serialization.');

    Grammar.Grammar grammar = new Grammar.Grammar.deserialize(data.readSer());
    _Table table = new _Table.deserialize(data.readSer(), grammar);
    Tokenizer.Tokenizer tokenizer = new Tokenizer.Tokenizer.deserialize(data.readSer());
    return new Parser._(table, grammar, tokenizer);
  }

  /// Creates a parser from a parser definition file.
  factory Parser.fromDefinition(String input) => (new Loader()..load(input)).parser;

  /// Creates a parser from a parser definition string.
  factory Parser.fromDefinitionChar(Iterator<int> input) => (new Loader()..loadChars(input)).parser;

  /// Serializes the parser into a json serialization.
  Simple.Serializer serialize() =>
    new Simple.Serializer()
      ..writeInt(1) // Version 1
      ..writeSer(this._grammar.serialize())
      ..writeSer(this._table.serialize())
      ..writeSer(this._tokenizer.serialize());

  /// Gets the grammar for this parser.
  /// This should be treated as a constant, modifying it could cause the parser to fail.
  Grammar.Grammar get grammar => this._grammar;

  /// Gets the tokenizer for this parser.
  /// This should be treated as a constant, modifying it could cause the parser to fail.
  Tokenizer.Tokenizer get tokenizer => this._tokenizer;

  /// This parses the given string and returns the results.
  Result parse(String input) =>
    this.parseTokens(this._tokenizer.tokenize(input));

  /// This parses the given characters and returns the results.
  Result parseChars(Iterator<int> iterator) =>
    this.parseTokens(this._tokenizer.tokenizeChars(iterator));

  /// This parses the given tokens and returns the results.
  Result parseTokens(Iterable<Tokenizer.Token> tokens, [int errorCap = 0]) {
    _Runner runner = new _Runner(this._table, errorCap);
    for (Tokenizer.Token token in tokens) {
      if (!runner.add(token)) return runner.result;
    }
    runner.add(new Tokenizer.Token(_eofTokenName, _eofTokenName, -1));
    return runner.result;
  }
}
