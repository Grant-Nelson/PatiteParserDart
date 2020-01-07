library PatiteParserDart.examples;

import 'package:PatiteParserDart/Calculator.dart' as Calc;

import 'dart:io' as io;

void main() async {
  Calc.Calculator calc = new Calc.Calculator();
  await calc.loadParser();

  print('Enter in an equation and press enter to calculate the result.');
  print('Type "exit" to exit. See documentation for more information.');

  while (true) {
    io.stdout.write("> ");
    String input = io.stdin.readLineSync();
    if (input.toLowerCase() == 'exit') break;

    calc.clear();
    calc.calculate(input);
    print(calc.results);
  }
}
