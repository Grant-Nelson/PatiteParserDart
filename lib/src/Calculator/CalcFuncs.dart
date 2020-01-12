part of PatiteParserDart.Calculator;

/// This is a collection of functions for the calculator.
class _CalcFuncs {
  Map<String, CalcFunc> _funcs;
  math.Random _rand;

  /// Creates a new collection of calculator function.
  _CalcFuncs() {
    this._funcs = {
      'abs':    this._funcAbs,
      'acos':   this._funcAcos,
      'asin':   this._funcAsin,
      'atan':   this._funcAtan,
      'atan2':  this._funcAtan2,
      'avg':    this._funcAvg,
      'bin':    this._funcBin,
      'bool':   this._funcBool,
      'ceil':   this._funcCeil,
      'cos':    this._funcCos,
      'floor':  this._funcFloor,
      'hex':    this._funcHex,
      'int':    this._funcInt,
      'log':    this._funcLog,
      'log2':   this._funcLog2,
      'log10':  this._funcLog10,
      'ln':     this._funcLn,
      'max':    this._funcMax,
      'min':    this._funcMin,
      'oct':    this._funcOct,
      'rand':   this._funcRand,
      'real':   this._funcReal,
      'round':  this._funcRound,
      'sin':    this._funcSin,
      'sqrt':   this._funcSqrt,
      'string': this._funcString,
      'sub':    this._funcSub,
      'sum':    this._funcSum,
      'tan':    this._funcTan};
    this._rand = new math.Random(0);
  }

  /// Adds a new function that can be called by the language.
  /// Set to null to remove a function.
  void addFunc(String name, CalcFunc hndl) {
    if (hndl == null) this._funcs.remove(name);
    else this._funcs[name] = hndl;
  }

  /// Finds the function with the given name.
  CalcFunc findFunc(String name) => this._funcs[name];
  
  /// This checks that the specified number of arguments has been given.
  void _argCount(String name, List<Object> args, int count) {
    if (args.length != count)
      throw new Exception('The function $name requires $count arguments but got ${args.length}.');
  }

  /// This function gets the absolute value of the given integer or real.
  Object _funcAbs(List<Object> args) {
    this._argCount('abs', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.abs();
    if (arg.implicitReal) return arg.asReal.abs();
    throw new Exception('Can not use $arg in either abs(int) or abs(real).');
  }

  /// This function gets the arccosine of the given real.
  Object _funcAcos(List<Object> args) {
    this._argCount('acos', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.acos(arg.asReal);
    throw new Exception('Can not use $arg in acos(real).');
  }
  
  /// This function gets the arcsine of the given real.
  Object _funcAsin(List<Object> args) {
    this._argCount('asin', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.asin(arg.asReal);
    throw new Exception('Can not use $arg in asin(real).');
  }

  /// This function gets the arctangent of the given real.
  Object _funcAtan(List<Object> args) {
    this._argCount('atan', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.atan(arg.asReal);
    throw new Exception('Can not use $arg in atan(real).');
  }

  /// This function gets the arctangent of the two given reals.
  Object _funcAtan2(List<Object> args) {
    this._argCount('atan2', args, 2);
    Variant left  = new Variant(args[0]);
    Variant right = new Variant(args[1]);
    if (left.implicitReal && right.implicitReal) return math.atan2(left.asReal, right.asReal);
    throw new Exception('Can not use $left and $right in atan2(real, real).');
  }

  /// This function gets the average of one or more reals.
  Object _funcAvg(List<Object> args) {
    if (args.length <= 0)
      throw new Exception('The function avg requires at least one argument.');
    double sum = 0.0;
    for (Object arg in args) {
      Variant value = new Variant(arg);
      if (value.implicitReal) sum += value.asReal;
      else throw new Exception('Can not use $arg in avg(real, real, ...).');
    }
    return sum / args.length;
  }

  /// This function gets the binary formatted integer as a string.
  Object _funcBin(List<Object> args) {
    this._argCount('bin', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.toRadixString(2);
    throw new Exception('Can not use $arg to bin(int).');
  }

  /// This function casts the given value into a boolean value.
  Object _funcBool(List<Object> args) {
    this._argCount('bool', args, 1);
    Variant arg = new Variant(args[0]);
    return arg.asBool;
  }

  /// This function gets the ceiling of the given real.
  Object _funcCeil(List<Object> args) {
    this._argCount('ceil', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return arg.asReal.ceil();
    throw new Exception('Can not use $arg to ceil(real) or already an int.');
  }

  /// This function gets the cosine of the given real.
  Object _funcCos(List<Object> args) {
    this._argCount('cos', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.cos(arg.asReal);
    throw new Exception('Can not use $arg in cos(real).');
  }

  /// This function gets the floor of the given real.
  Object _funcFloor(List<Object> args) {
    this._argCount('floor', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return arg.asReal.floor();
    throw new Exception('Can not use $arg to floor(real) or already an int.');
  }

  /// This function gets the hexadecimal formatted integer as a string.
  Object _funcHex(List<Object> args) {
    this._argCount('hex', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.toRadixString(16);
    throw new Exception('Can not use $arg to hex(int).');
  }

  /// This function casts the given value into an integer value.
  Object _funcInt(List<Object> args) {
    this._argCount('int', args, 1);
    Variant arg = new Variant(args[0]);
    return arg.asInt;
  }

  /// This function gets the log of the given real with the base of another real.
  Object _funcLog(List<Object> args) {
    this._argCount('log', args, 2);
    Variant left  = new Variant(args[0]);
    Variant right = new Variant(args[1]);
    if (left.implicitReal && right.implicitReal) return math.log(left.asReal)/math.log(right.asReal);
    throw new Exception('Can not use $left and $right in log(real, real).');
  }

  /// This function gets the log base 2 of the given real.
  Object _funcLog2(List<Object> args) {
    this._argCount('log2', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.log(arg.asReal)/math.ln2;
    throw new Exception('Can not use $arg in log2(real).');
  }

  /// This function gets the log base 10 of the given real.
  Object _funcLog10(List<Object> args) {
    this._argCount('log10', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.log(arg.asReal)/math.ln10;
    throw new Exception('Can not use $arg in log10(real).');
  }

  /// This function gets the natural log of the given real.
  Object _funcLn(List<Object> args) {
    this._argCount('ln', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.log(arg.asReal);
    throw new Exception('Can not use $arg in ln(real).');
  }

  /// This function gets the maximum value of one or more integers or reals.
  Object _funcMax(List<Object> args) {
    if (args.length <= 0)
      throw new Exception('The function max requires at least one argument.');
    bool allInt = true;
    for (Object arg in args) {
      Variant value = new Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw new Exception('Can not use $arg in max(real, real, ...) or max(int, int, ...).');
    }

    if (allInt) {
      int value = new Variant(args[0]).asInt;
      for (Object arg in args) value = math.max(value, new Variant(arg).asInt);
      return value;
    } else {
      double value = new Variant(args[0]).asReal;
      for (Object arg in args) value = math.max(value, new Variant(arg).asReal);
      return value;
    }
  }

  /// This function gets the minimum value of one or more integers or reals.
  Object _funcMin(List<Object> args) {
    if (args.length <= 0)
      throw new Exception('The function min requires at least one argument.');
    bool allInt = true;
    for (Object arg in args) {
      Variant value = new Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw new Exception('Can not use $arg in min(real, real, ...) or min(int, int, ...).');
    }

    if (allInt) {
      int value = new Variant(args[0]).asInt;
      for (Object arg in args) value = math.min(value, new Variant(arg).asInt);
      return value;
    } else {
      double value = new Variant(args[0]).asReal;
      for (Object arg in args) value = math.min(value, new Variant(arg).asReal);
      return value;
    }
  }

  /// This function gets the octal formatted integer as a string.
  Object _funcOct(List<Object> args) {
    this._argCount('oct', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.toRadixString(8);
    throw new Exception('Can not use $arg to oct(int).');
  }

  /// This function puts a random number onto the stack.
  Object _funcRand(List<Object> args) {
    this._argCount('rand', args, 0);
    return this._rand.nextDouble();
  }

  /// This function casts the given value into a real value.
  Object _funcReal(List<Object> args) {
    this._argCount('real', args, 1);
    Variant arg = new Variant(args[0]);
    return arg.asReal;
  }

  /// This function gets the round of the given real.
  Object _funcRound(List<Object> args) {
    this._argCount('round', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return arg.asReal.round();
    throw new Exception('Can not use $arg in round(real).');
  }

  /// This function gets the sine of the given real.
  Object _funcSin(List<Object> args) {
    this._argCount('sin', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.sin(arg.asReal);
    throw new Exception('Can not use $arg in sin(real).');
  }

  /// This function gets the square root of the given real.
  Object _funcSqrt(List<Object> args) {
    this._argCount('sqrt', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.sqrt(arg.asReal);
    throw new Exception('Can not use $arg in sqrt(real).');
  }

  /// This function casts the given value into a string value.
  Object _funcString(List<Object> args) {
    this._argCount('string', args, 1);
    Variant arg = new Variant(args[0]);
    return arg.asStr;
  }

  /// This function gets a substring for a given string with a start and stop integer.
  Object _funcSub(List<Object> args) {
    this._argCount('sub', args, 3);
    Variant arg0 = new Variant(args[0]);
    Variant arg1 = new Variant(args[1]);
    Variant arg2 = new Variant(args[2]);
    if (arg0.implicitStr && arg1.implicitInt && arg2.implicitInt)
      return arg0.asStr.substring(arg1.asInt, arg2.asInt);
    throw new Exception('Can not uce $arg0, $arg1, and $arg2 in sub(string, int, int).');
  }

  /// This function gets the sum of zero or more integers or reals.
  Object _funcSum(List<Object> args) {
    bool allInt = true;
    for (Object arg in args) {
      Variant value = new Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw new Exception('Can not use $arg in sum(real, real, ...) or sum(int, int, ...).');
    }

    if (allInt) {
      int value = 0;
      for (Object arg in args) value += new Variant(arg).asInt;
      return value;
    } else {
      double value = 0.0;
      for (Object arg in args) value += new Variant(arg).asReal;
      return value;
    }
  }

  /// This function gets the tangent of the given real.
  Object _funcTan(List<Object> args) {
    this._argCount('tan', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.tan(arg.asReal);
    throw new Exception('Can not use $arg in tan(real).');
  }
}
