library PatiteParserDart.test;

import 'package:PatiteParserDart/Grammar.dart';
import 'package:PatiteParserDart/Parser.dart';
import 'package:PatiteParserDart/src/Tokenizer/Tokenizer.dart';

part 'parser.dart';
part 'tokenizer.dart';

/// Tests for Patite Parser Dart.
void main() {
  tokenizer00();
  tokenizer01();

  parser00();
  parser01();
  parser02();
  parser03();
  parser04();
}
