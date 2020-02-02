part of PetiteParserDart.test;

void calc00(TestArgs args) {
  args.log('calc00');
  Calculator.Calculator calc = new Calculator.Calculator();

  args.checkCalc(calc, '42', ['42']);
  args.checkCalc(calc, '2 * 3', ['6']);
  args.checkCalc(calc, '2 + 3', ['5']);
  args.checkCalc(calc, '2 * 3 + 5', ['11']);
  args.checkCalc(calc, '2 * (3 + 5)', ['16']);
  args.checkCalc(calc, '(2 * 3) + 5', ['11']);
  args.checkCalc(calc, '(2 * (3 + 5))', ['16']);
  args.checkCalc(calc, '2*5 + 5*2', ['20']);
  args.checkCalc(calc, '12 - 5', ['7']);
  args.checkCalc(calc, '12 + -5', ['7']);
  args.checkCalc(calc, '2*6 - 5', ['7']);
  args.checkCalc(calc, '2*2*3 + 5*(-1)', ['7']);
  args.checkCalc(calc, '2*2*3 + 5*(-1)', ['7']);
  args.checkCalc(calc, '2**3', ['8']);
}

void calc01(TestArgs args) {
  args.log('calc01');
  
  Calculator.Calculator calc = new Calculator.Calculator();
  args.checkCalc(calc, '3.14', ['3.14']);
  args.checkCalc(calc, '314e-2', ['3.14']);
  args.checkCalc(calc, '314.0e-2', ['3.14']);
  args.checkCalc(calc, '31.4e-1', ['3.14']);
  args.checkCalc(calc, '0.0314e2', ['3.14']);
  args.checkCalc(calc, '0.0314e+2', ['3.14']);
  args.checkCalc(calc, '2.0 * 3', ['6.0']);
  args.checkCalc(calc, '2 * 3.0', ['6.0']);
  args.checkCalc(calc, '2.0 * 3.0', ['6.0']);
  args.checkCalc(calc, 'real(2) * 3', ['6.0']);
  args.checkCalc(calc, '2.0 - 3', ['-1.0']);
  args.checkCalc(calc, '2.0 ** 3', ['8.0']);
}

void calc02(TestArgs args) {
  args.log('calc02');

  Calculator.Calculator calc = new Calculator.Calculator();
  args.checkCalc(calc, 'min(2, 4, 3)', ['2']);
  args.checkCalc(calc, 'max(2, 4, 3)', ['4']);
  args.checkCalc(calc, 'sum(2, 4, 3)', ['9']);
  args.checkCalc(calc, 'avg(2, 4, 3)', ['3.0']);
  args.checkCalc(calc, 'min(2+4, 4-2, 1*3)', ['2']);
}
