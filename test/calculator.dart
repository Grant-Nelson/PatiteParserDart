part of PetiteParserDart.test;

void calc00(TestArgs args) {
  args.log('calc00');
  Calculator.Calculator calc = new Calculator.Calculator();

  args.checkCalc(calc, '', ['no result']);
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
  args.checkCalc(calc, '1100b', ['12']);
  args.checkCalc(calc, '0xF00A', ['61450']);
  args.checkCalc(calc, '77o', ['63']);
  args.checkCalc(calc, '42d', ['42']);
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
  args.checkCalc(calc, 'floor(3.5)', ['3']);
  args.checkCalc(calc, 'round(3.5)', ['4']);
  args.checkCalc(calc, 'ceil(3.5)', ['4']);
}

void calc03(TestArgs args) {
  args.log('calc03');
  
  Calculator.Calculator calc = new Calculator.Calculator();
  args.checkCalc(calc, 'square(11)',
    ['Errors in calculator input:',
     'Exception: No function called square found.']);

  calc.addFunc("square", (List<Object?> list) {
    if (list.length != 1) throw new Exception('Square may one and only one input.');
    Calculator.Variant v = new Calculator.Variant(list[0]);
    if (v.implicitInt) return v.asInt*v.asInt;
    if (v.implicitReal) return v.asReal*v.asReal;
    throw new Exception("May only square an int or real number but got $v.");
  });
  
  args.checkCalc(calc, 'square(11)', ['121']);
  args.checkCalc(calc, 'square(-4.33)', ['18.7489']);
  args.checkCalc(calc, 'square("cat")',
    ['Errors in calculator input:',
     'Exception: May only square an int or real number but got String(cat).']);
}

void calc04(TestArgs args) {
  args.log('calc04');

  Calculator.Calculator calc = new Calculator.Calculator();
  args.checkCalc(calc, '"cat" + "9"', ['cat9']);
  args.checkCalc(calc, '"cat" + string(9)', ['cat9']);
  args.checkCalc(calc, '"cat" + string(6 + int("3"))', ['cat9']);
  args.checkCalc(calc, 'bin(42)', ['101010b']);
  args.checkCalc(calc, 'oct(42)', ['52o']);
  args.checkCalc(calc, 'hex(42)', ['0x2A']);
  args.checkCalc(calc, 'upper("CAT-cat")', ['CAT-CAT']);
  args.checkCalc(calc, 'lower("CAT-cat")', ['cat-cat']);

  args.checkCalc(calc, 'sub("catch", 0, 3)', ['cat']);
  args.checkCalc(calc, 'sub("catch", 1, 3)', ['at']);
  args.checkCalc(calc, 'sub("catch", 3, 1)',
    ['Errors in calculator input:',
     'RangeError: Value not in range: 3']);

  args.checkCalc(calc, 'len("catch")', ['5']);
  args.checkCalc(calc, 'len("cat")', ['3']);
  args.checkCalc(calc, 'len("\\"")', ['1']);
  args.checkCalc(calc, 'len("")', ['0']);
  args.checkCalc(calc, 'bool("tr"+"ue")', ['true']);
}

void calc05(TestArgs args) {
  args.log('calc05');
  
  Calculator.Calculator calc = new Calculator.Calculator();
  args.checkCalc(calc, 'hex(0xFF00 & 0xF0F0)', ['0xF000']);
  args.checkCalc(calc, 'hex(0xFF00 | 0xF0F0)', ['0xFFF0']);
  args.checkCalc(calc, 'hex(0xFF00 ^ 0xF0F0)', ['0xFF0']);
  args.checkCalc(calc, 'hex(~0xFF00 & 0x0FF0)', ['0xF0']);

  args.checkCalc(calc, '!true', ['false']);
  args.checkCalc(calc, '!false', ['true']);  
  args.checkCalc(calc, 'true & true', ['true']);
  args.checkCalc(calc, 'true & false', ['false']);
  args.checkCalc(calc, 'false & true', ['false']);
  args.checkCalc(calc, 'false & false', ['false']);
  args.checkCalc(calc, 'true | true', ['true']);
  args.checkCalc(calc, 'true | false', ['true']);
  args.checkCalc(calc, 'false | true', ['true']);
  args.checkCalc(calc, 'false | false', ['false']);
  args.checkCalc(calc, 'true ^ true', ['false']);
  args.checkCalc(calc, 'true ^ false', ['true']);
  args.checkCalc(calc, 'false ^ true', ['true']);
  args.checkCalc(calc, 'false ^ false', ['false']);
}

void calc06(TestArgs args) {
  args.log('calc06');

  Calculator.Calculator calc = new Calculator.Calculator();
  args.checkCalc(calc, '10 == 3', ['false']);
  args.checkCalc(calc, '3 == 3', ['true']);
  args.checkCalc(calc, '10 != 3', ['true']);
  args.checkCalc(calc, '3 != 3', ['false']);
  args.checkCalc(calc, '10 < 3', ['false']);
  args.checkCalc(calc, '3 < 3', ['false']);
  args.checkCalc(calc, '3 <= 3', ['true']);
  args.checkCalc(calc, '3 <= 10', ['true']);
  args.checkCalc(calc, '10 <= 3', ['false']);
  args.checkCalc(calc, '2 < 3', ['true']);
  args.checkCalc(calc, '10 > 3', ['true']);
  args.checkCalc(calc, '3 > 3', ['false']);
  args.checkCalc(calc, '3 >= 3', ['true']);
  args.checkCalc(calc, '10 >= 3', ['true']);
  args.checkCalc(calc, '3 >= 10', ['false']);
  args.checkCalc(calc, '3 > 2', ['true']);

  args.checkCalc(calc, '3 == 3.0', ['true']);
  args.checkCalc(calc, '"3" == 3', ['false']);
  args.checkCalc(calc, '"3" == string(3)', ['true']);
  args.checkCalc(calc, 'true == false', ['false']);
  args.checkCalc(calc, 'true != false', ['true']);
}

void calc07(TestArgs args) {
  args.log('calc07');

  Calculator.Calculator calc = new Calculator.Calculator();
  args.checkCalc(calc, '(3 == 2) | (4 < 10)', ['true']);
  args.checkCalc(calc, 'x := 4+5; y := 9; x == y; x+y', ['true, 18']);
  args.checkCalc(calc, 'x', ['9']);
  args.checkCalc(calc, 'z',
    ['Errors in calculator input:',
     'Exception: No constant called z found.']);
  calc.setVar("z", true);
  args.checkCalc(calc, 'z', ['true']);
  args.checkCalc(calc, 'e', ['2.718281828459045']);
  args.checkCalc(calc, 'pi', ['3.141592653589793']);
  args.checkCalc(calc, 'cos(pi)', ['-1.0']);
}

void calc08(TestArgs args) {
  args.log('calc08');

  Calculator.Calculator calc = new Calculator.Calculator();
  args.checkCalc(calc, 'padLeft("Hello", 12)', ['       Hello']);
  args.checkCalc(calc, 'padRight("Hello", 12)', ['Hello       ']);
  args.checkCalc(calc, 'padLeft("Hello", 12, "-")', ['-------Hello']);
  args.checkCalc(calc, 'padRight("Hello", 12, "-")', ['Hello-------']);
  args.checkCalc(calc, 'trim("   Hello   ")', ['Hello']);
  args.checkCalc(calc, 'trimLeft("   Hello   ")', ['Hello   ']);
  args.checkCalc(calc, 'trimRight("   Hello   ")', ['   Hello']);
  args.checkCalc(calc, 'trim(str(1))',
    ['Errors in calculator input:',
     'Exception: No function called str found.']);
}
