library PetiteParserDart.examples;

import 'package:PetiteParserDart/Calculator.dart' as Calc;

import 'dart:io' as io;

void main() {
  Calc.Calculator calc = new Calc.Calculator();

  print('Enter in an equation and press enter to calculate the result.');
  print('Type "exit" to exit. See documentation for more information.');

  while (true) {
    io.stdout.write("> ");
    String input = io.stdin.readLineSync() ?? '';
    if (input.toLowerCase() == 'exit') break;

    calc.clear();
    calc.calculate(input);
    print(calc.stackToString);
  }
}
