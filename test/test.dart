library PatiteParserDart.test;

import 'package:PatiteParserDart/Grammar.dart' as Grammar;
import 'package:PatiteParserDart/Parser.dart' as Parser;
import 'package:PatiteParserDart/Tokenizer.dart' as Tokenizer;
import 'package:PatiteParserDart/Simple.dart' as Simple;
import 'package:PatiteParserDart/Diff.dart' as Diff;

part 'diff.dart';
part 'grammar.dart';
part 'loader.dart';
part 'parser.dart';
part 'testArgs.dart';
part 'testTool.dart';
part 'tokenizer.dart';

/// Tests for Patite Parser Dart.
void main() {
  TestTool test = new TestTool();

  test.run(diff00);

  test.run(grammar00);
  test.run(grammar01);

  test.run(tokenizer00);
  test.run(tokenizer01);

  test.run(parser00);
  test.run(parser01);
  test.run(parser02);
  test.run(parser03);
  test.run(parser04);
  test.run(parser05);
  test.run(parser06);

  test.run(loader00);
  test.run(loader01);
  test.run(loader02);
  test.run(loader03);
  test.run(loader04);
  test.run(loader05);
  test.run(loader06);
  test.run(loader07);

  test.printResult();
}
