library PetiteParserDart.test;

import 'package:PetiteParserDart/Calculator.dart' as Calculator;
import 'package:PetiteParserDart/Grammar.dart' as Grammar;
import 'package:PetiteParserDart/Parser.dart' as Parser;
import 'package:PetiteParserDart/Tokenizer.dart' as Tokenizer;
import 'package:PetiteParserDart/Simple.dart' as Simple;
import 'package:PetiteParserDart/Diff.dart' as Diff;

part 'calculator.dart';
part 'diff.dart';
part 'grammar.dart';
part 'loader.dart';
part 'parser.dart';
part 'testArgs.dart';
part 'testTool.dart';
part 'tokenizer.dart';

/// Tests for Petite Parser Dart.
void main() async {
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
  test.run(loader08);
  test.run(loader09);

  await Calculator.Calculator.loadParser();
  test.run(calc00);
  test.run(calc01);
  test.run(calc02);

  test.printResult();
}
