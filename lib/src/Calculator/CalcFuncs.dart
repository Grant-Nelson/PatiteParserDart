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

  Object _funcAvg(List<Object> args) {
    if (args.length <= 0)
      throw new Exception('The function Average requires at least one argument.');
    double sum = 0.0;
    for (Object arg in args) {
      Variant value = new Variant(arg);
      if (value.implicitReal) sum += value.asReal;
      else throw new Exception('Can not get the Average with $arg.');
    }
    return sum / args.length;
  }

  Object _funcBin(List<Object> args) {
    this._argCount('bin', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.toRadixString(2);
    throw new Exception('Can not get the binary string of $arg.');
  }

  Object _funcBool(List<Object> args) {
    this._argCount('bool', args, 1);
    Variant arg = new Variant(args[0]);
    return arg.asBool;
  }

  Object _funcCeil(List<Object> args) {
    this._argCount('ceil', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitInt) return arg.asInt;
    if (arg.implicitReal) return arg.asReal.ceil();
    throw new Exception('Can not get the Ceiling of $arg.');
  }

  Object _funcCos(List<Object> args) {
    this._argCount('cos', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.cos(arg.asReal);
    throw new Exception('Can not get the Cos of $arg.');
  }

  Object _funcFloor(List<Object> args) {
    this._argCount('floor', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitInt) return arg.asInt;
    if (arg.implicitReal) return arg.asReal.floor();
    throw new Exception('Can not get the Floor of $arg.');
  }

  Object _funcHex(List<Object> args) {
    this._argCount('hex', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.toRadixString(16);
    throw new Exception('Can not get the hexadecimal string of $arg.');
  }

  Object _funcInt(List<Object> args) {
    this._argCount('int', args, 1);
    Variant arg = new Variant(args[0]);
    return arg.asInt;
  }

  Object _funcLog(List<Object> args) {
    this._argCount('log', args, 2);
    Variant left  = new Variant(args[0]);
    Variant right = new Variant(args[1]);
    if (left.implicitReal && right.implicitReal) return math.log(left.asReal)/math.log(right.asReal);
    throw new Exception('Can not Log $left with $right.');
  }

  Object _funcLog2(List<Object> args) {
    this._argCount('log2', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.log(arg.asReal)/math.ln2;
    throw new Exception('Can not Log2 of $arg.');
  }

  Object _funcLog10(List<Object> args) {
    this._argCount('log10', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.log(arg.asReal)/math.ln10;
    throw new Exception('Can not Log10 of $arg.');
  }

  Object _funcLn(List<Object> args) {
    this._argCount('ln', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.log(arg.asReal);
    throw new Exception('Can not Ln of $arg.');
  }

  Object _funcMax(List<Object> args) {
    if (args.length <= 0)
      throw new Exception('The function Maximum requires at least one argument.');
    bool allInt = true;
    for (Object arg in args) {
      Variant value = new Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw new Exception('Can not get the Maximum with $arg.');
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

  Object _funcMin(List<Object> args) {
    if (args.length <= 0)
      throw new Exception('The function Minimum requires at least one argument.');
    bool allInt = true;
    for (Object arg in args) {
      Variant value = new Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw new Exception('Can not get the Minimum with $arg.');
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

  Object _funcOct(List<Object> args) {
    this._argCount('oct', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitInt) return arg.asInt.toRadixString(8);
    throw new Exception('Can not get the octal string of $arg.');
  }

  Object _funcRand(List<Object> args) {
    this._argCount('rand', args, 0);
    return this._rand.nextDouble();
  }

  Object _funcReal(List<Object> args) {
    this._argCount('real', args, 1);
    Variant arg = new Variant(args[0]);
    return arg.asReal;
  }

  Object _funcRound(List<Object> args) {
    this._argCount('round', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return arg.asReal.round();
    throw new Exception('Can not Round of $arg.');
  }

  Object _funcSin(List<Object> args) {
    this._argCount('sin', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.sin(arg.asReal);
    throw new Exception('Can not Sin of $arg.');
  }

  Object _funcSqrt(List<Object> args) {
    this._argCount('sqrt', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.sqrt(arg.asReal);
    throw new Exception('Can not Sqrt of $arg.');
  }

  Object _funcString(List<Object> args) {
    this._argCount('string', args, 1);
    Variant arg = new Variant(args[0]);
    return arg.asStr;
  }

  Object _funcSub(List<Object> args) {
    this._argCount('sub', args, 3);
    Variant arg0 = new Variant(args[0]);
    Variant arg1 = new Variant(args[1]);
    Variant arg2 = new Variant(args[2]);
    if (arg0.implicitStr && arg1.implicitInt && arg2.implicitInt)
      return arg0.asStr.substring(arg1.asInt, arg2.asInt);
    throw new Exception('Can not Sub with $arg0, $arg1, and $arg2.');
  }

  Object _funcSum(List<Object> args) {
    bool allInt = true;
    for (Object arg in args) {
      Variant value = new Variant(arg);
      if (value.implicitInt) continue;
      allInt = false;
      if (value.implicitReal) continue;
      throw new Exception('Can not get the Sum with $arg.');
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

  Object _funcTan(List<Object> args) {
    this._argCount('tan', args, 1);
    Variant arg = new Variant(args[0]);
    if (arg.implicitReal) return math.tan(arg.asReal);
    throw new Exception('Can not Tan of $arg.');
  }
}
