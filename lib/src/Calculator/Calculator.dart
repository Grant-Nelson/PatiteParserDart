library PatiteParserDart.Calculator;

import 'package:resource/resource.dart' show Resource;
import 'package:PatiteParserDart/src/Parser/Parser.dart' as Parser;
import 'package:PatiteParserDart/src/ParseTree/ParseTree.dart' as ParseTree;

import 'dart:math' as math;
import 'dart:async';

part 'Variant.dart';

class Calculator {
  static Parser.Parser _parser;

  Map<String, ParseTree.TriggerHandle> _handles;
  List<Variant> _stack;
  Map<String, Variant> _consts;
  Map<String, CalcFunc> _funcs;
  math.Random _rand;

  Calculator() {
    this._handles = {
      'Add':         this._handleAdd,
      'And':         this._handleAnd,
      'Binary':      this._handleBinary,
      'Call':        this._handleCall,
      'Decimal':     this._handleDecimal,
      'Divide':      this._handleDivide,
      'Hexadecimal': this._handleHexadecimal,
      'Id':          this._handleId,
      'Invert':      this._handleInvert,
      'Multiply':    this._handleMultiply,
      'Negate':      this._handleNegate,
      'Not':         this._handleNot,
      'Octal':       this._handleOctal,
      'Or':          this._handleOr,
      'Power':       this._handlePower,
      'Real':        this._handleReal,
      'StartCall':   this._handleStartCall,
      'Subtract':    this._handleSubtract};
    this._stack = new List<Variant>();
    this._consts = {
      "pi":    new Variant.Real(math.pi),
      "e":     new Variant.Real(math.e),
      "true":  new Variant.Bool(true),
      "false": new Variant.Bool(false)};
    this._funcs = {
      "abs":    this._funcAbs,
      "acos":   this._funcAcos,
      "asin":   this._funcAsin,
      "atan":   this._funcAtan,
      "atan2":  this._funcAtan2,
      "avg":    this._funcAvg,
      "bool":   this._funcBool,
      "ceil":   this._funcCeil,
      "cos":    this._funcCos,
      "floor":  this._funcFloor,
      "int":    this._funcInt,
      "log":    this._funcLog,
      "log2":   this._funcLog2,
      "log10":  this._funcLog10,
      "ln":     this._funcLn,
      "max":    this._funcMax,
      "min":    this._funcMin,
      "rand":   this._funcRand,
      "real":   this._funcReal,
      "round":  this._funcRound,
      "sin":    this._funcSin,
      "sqrt":   this._funcSqrt,
      "string": this._funcString,
      "sum":    this._funcSum,
      "tan":    this._funcTan};
    this._rand = new math.Random(0);
  }

  Future loadParser() async {
    if (_parser == null) {
      Resource resource = const Resource('package:PatiteParserDart/src/Calculator/Calculator.txt');
      return resource.readAsString().then((String language) {
        _parser = new Parser.Parser.fromDefinition(language);
      });
    }
    return null;
  }

  void calculate(String input) {
    if (input.isEmpty) return;
    if (_parser == null) {
      this.pushStr('Error: The parser must have finished loading prior to calculating any input.');
      return;
    }
    Parser.Result result = _parser.parse(input);

    if (result.errors?.isNotEmpty ?? false) {
      this.pushStr('Errors in calculator input:\n' + result.errors.join('\n'));
      return;
    }

    try {
      result.tree.process(this._handles);
    } catch (err) {
      this.pushStr('Errors in calculator input:\n' + err.toString());
    }
  }

  String get results {
    if (this._stack.length <= 0) return 'no result';
    List<String> parts = new List<String>();
    for (Variant val in this._stack) parts.add('${val}');
    return parts.join('\n');
  }

  void addFunc(String name, CalcFunc hndl) => this._funcs[name] = hndl;
  
  void addConstant(String name, Variant value) => this._consts[name] = value;

  bool get stackEmpty => this._stack.isEmpty;

  void clear() => this._stack.clear();

  Variant pop() => this._stack.removeLast();

  void push(Variant value) => this._stack.add(value);
  
  void pushStr(String value)    => this.push(new Variant.Str(value));
  void pushInt(int value)       => this.push(new Variant.Int(value));
  void pushReal(double value)   => this.push(new Variant.Real(value));
  void pushBool(bool value)     => this.push(new Variant.Bool(value));
  void pushFunc(CalcFunc value) => this.push(new Variant.Func(value));

  void _handleAdd(ParseTree.TriggerArgs args) {
    Variant right = this.pop(), left  = this.pop();
    if (left.isStr && right.isStr) this.pushStr(left.asStr + right.asStr);
    else if (left.isFunc || right.isFunc || left.isStr || right.isStr) 
      throw new Exception('Can not Add $left to $right.');
    else if (left.isBool && right.isBool) this.pushBool(left.asBool || right.asBool);
    else if (left.isReal || right.isReal) this.pushReal(left.asReal + right.asReal);
    else this.pushInt(left.asInt + right.asInt);
  }

  void _handleAnd(ParseTree.TriggerArgs args) {
    Variant right = this.pop(), left  = this.pop();
    if (left.isInt && right.isInt) this.pushInt(left.asInt & right.asInt);
    else if (left.isBool && right.isBool) this.pushBool(left.asBool && right.asBool);
    else throw new Exception('Can not And $left with $right.');
  }

  void _handleBinary(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    text = text.substring(0, text.length-1); // remove 'b'
    this.pushInt(int.parse(text, radix: 2));
    args.tokens.clear();
  }

  void _handleCall(ParseTree.TriggerArgs args) {
    List<Variant> methodArgs = new List<Variant>();
    Variant val = this._stack.removeLast();
    while (!val.isFunc) {
      methodArgs.insert(0, val);
      val = this._stack.removeLast();
    }
    val.asFunc(methodArgs);
  }

  void _handleDecimal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    if (text.endsWith('d')) text = text.substring(0, text.length-1);
    this.pushInt(int.parse(text, radix: 10));
    args.tokens.clear();
  }

  void _handleDivide(ParseTree.TriggerArgs args) {
    Variant right = this.pop(), left  = this.pop();
    if (left.isFunc || right.isFunc || left.isStr || right.isStr || left.isBool || right.isBool)
      throw new Exception('Can not Divide $left and $right.');
    else if (left.isInt && right.isInt) this.pushInt(left.asInt ~/ right.asInt);
    else this.pushReal(left.asReal / right.asReal);
  }

  void _handleId(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    if (!this._consts.containsKey(text))
      throw new Exception('No constant called $text found.');
    this._stack.add(this._consts[text]);
    args.tokens.clear();
  }

  void _handleInvert(ParseTree.TriggerArgs args) {
    Variant top = this.pop();
    if (top.isInt) this.pushInt(~top.asInt);
    else throw new Exception('Can not Invert $top.');
  }

  void _handleHexadecimal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    text = text.substring(2); // remove '0x'
    this.pushInt(int.parse(text, radix: 16));
    args.tokens.clear();
  }

  void _handleMultiply(ParseTree.TriggerArgs args) {
    Variant right = this.pop(), left  = this.pop();
    if (left.isFunc || right.isFunc || left.isStr || right.isStr) 
      throw new Exception('Can not Multiply $left and $right.');
    else if (left.isBool && right.isBool) this.pushBool(left.asBool || right.asBool);
    else if (left.isReal || right.isReal) this.pushReal(left.asReal * right.asReal);
    else this.pushInt(left.asInt * right.asInt);
  }

  void _handleNegate(ParseTree.TriggerArgs args) {
    Variant top = this.pop();
    if (top.isInt) this.pushInt(-top.asInt);
    else if (top.isReal) this.pushReal(-top.asReal);
    else throw new Exception('Can not Negate $top.');
  }

  void _handleNot(ParseTree.TriggerArgs args) {
    Variant top = this.pop();
    if (top.isBool) this.pushBool(!top.asBool);
    else throw new Exception('Can not Not $top.');
  }

  void _handleOctal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    text = text.substring(0, text.length-1); // remove 'o'
    this.pushInt(int.parse(text, radix: 8));
    args.tokens.clear();
  }

  void _handleOr(ParseTree.TriggerArgs args) {
    Variant right = this.pop(), left  = this.pop();
    if (left.isInt && right.isInt) this.pushInt(left.asInt | right.asInt);
    else if (left.isBool && right.isBool) this.pushBool(left.asBool || right.asBool);
    else throw new Exception('Can not Or $left and $right.');
  }

  void _handlePower(ParseTree.TriggerArgs args) {
    Variant right = this.pop(), left  = this.pop();
    if (left.isFunc || right.isFunc || left.isStr || right.isStr) 
      throw new Exception('Can not Power $left and $right.');
    else if (left.isBool && right.isBool) this.pushBool(left.asBool ^ right.asBool);
    else if (left.isReal || right.isReal) this.pushReal(math.pow(left.asReal, right.asReal));
    else this.pushInt(left.asInt ^ right.asInt);
  }

  void _handleReal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    this.pushReal(double.parse(text));
    args.tokens.clear();
  }

  void _handleStartCall(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text.toLowerCase();
    if (!this._funcs.containsKey(text))
      throw new Exception('No function called $text found.');
    this.pushFunc(this._funcs[text]);
    args.tokens.clear();
  }

  void _handleSubtract(ParseTree.TriggerArgs args) {
    Variant right = this.pop(), left = this.pop();
    if (left.isFunc || right.isFunc || left.isStr || right.isStr) 
      throw new Exception('Can not Subtract $left from $right.');
    else if (left.isBool && right.isBool) this.pushBool(!left.asBool || right.asBool);
    else if (left.isReal || right.isReal) this.pushReal(left.asReal - right.asReal);
    else this.pushInt(left.asInt - right.asInt);
  }

  void _argCount(String name, List<Variant> args, int count) {
    if (args.length != count)
      throw new Exception('The function $name requires $count arguments but got ${args.length}.');
  }

  void _funcAbs(List<Variant> args) {
    this._argCount('abs', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Abs of $arg.');
    else if (arg.isInt) this.pushInt(args[0].asInt.abs());
    else this.pushReal(arg.asReal.abs());
  }

  void _funcAcos(List<Variant> args) {
    this._argCount('acos', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Acos of $arg.');
    else this.pushReal(math.acos(arg.asReal));
  }
  
  void _funcAsin(List<Variant> args) {
    this._argCount('asin', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Asin of $arg.');
    else this.pushReal(math.asin(arg.asReal));
  }

  void _funcAtan(List<Variant> args) {
    this._argCount('atan', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Atan of $arg.');
    else this.pushReal(math.tan(arg.asReal));
  }

  void _funcAtan2(List<Variant> args) {
    this._argCount('atan2', args, 2);
    Variant left = args[0], right = args[1];
    if (left.isFunc || right.isFunc || left.isStr || right.isStr || left.isBool || right.isBool)
      throw new Exception('Can not Atan2 $left with $right.');
    else this.pushReal(math.atan2(left.asReal, right.asReal));
  }

  void _funcAvg(List<Variant> args) {
    if (args.length <= 0)
      throw new Exception('The function Average requires at least one argument.');
    double sum = 0.0;
    for (Variant arg in args) {
      if (!arg.isInt && !arg.isReal) throw new Exception('Can not get the Average with $arg.');
      sum += arg.asReal;
    }
    this.pushReal(sum / args.length);
  }

  void _funcBool(List<Variant> args) {
    this._argCount('bool', args, 1);
    this.pushBool(args[0].asBool);
  }

  void _funcCeil(List<Variant> args) {
    this._argCount('ceil', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Ceiling of $arg.');
    else if (arg.isInt) this._stack.add(arg);
    else this.pushInt(arg.asReal.ceil());
  }

  void _funcCos(List<Variant> args) {
    this._argCount('cos', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Cos of $arg.');
    else this.pushReal(math.cos(arg.asReal));
  }

  void _funcFloor(List<Variant> args) {
    this._argCount('floor', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Floor of $arg.');
    else if (arg.isInt) this._stack.add(arg);
    else this.pushInt(arg.asReal.floor());
  }

  void _funcInt(List<Variant> args) {
    this._argCount('int', args, 1);
    this.pushInt(args[0].asInt);
  }

  void _funcLog(List<Variant> args) {
    this._argCount('log', args, 2);
    Variant left = args[0], right = args[1];
    if (left.isFunc || right.isFunc || left.isStr || right.isStr || left.isBool || right.isBool)
      throw new Exception('Can not Log $left with $right.');
    else this.pushReal(math.log(left.asReal)/math.log(right.asReal));
  }

  void _funcLog2(List<Variant> args) {
    this._argCount('log2', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Log2 of $arg.');
    else this.pushReal(math.log(arg.asReal)/math.ln2);
  }

  void _funcLog10(List<Variant> args) {
    this._argCount('log10', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Log10 of $arg.');
    else this.pushReal(math.log(arg.asReal)/math.ln10);
  }

  void _funcLn(List<Variant> args) {
    this._argCount('ln', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Ln of $arg.');
    else this.pushReal(math.log(arg.asReal));
  }

  void _funcMax(List<Variant> args) {
    if (args.length <= 0)
      throw new Exception('The function Maximum requires at least one argument.');
    bool allInt = true;
    for (Variant arg in args) {
      if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Maximum with $arg.');
      if (!arg.isInt) allInt = false;
    }

    if (allInt) {
      int value = args[0].asInt;
      for (Variant arg in args) value = math.max(value, arg.asInt);
      this.pushInt(value);
    } else {
      double value = args[0].asReal;
      for (Variant arg in args) value = math.max(value, arg.asReal);
      this.pushReal(value);
    }
  }

  void _funcMin(List<Variant> args) {
    if (args.length <= 0)
      throw new Exception('The function Minimum requires at least one argument.');
    bool allInt = true;
    for (Variant arg in args) {
      if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Minimum with $arg.');
      if (!arg.isInt) allInt = false;
    }

    if (allInt) {
      int value = args[0].asInt;
      for (Variant arg in args) value = math.min(value, arg.asInt);
      this.pushInt(value);
    } else {
      double value = args[0].asReal;
      for (Variant arg in args) value = math.min(value, arg.asReal);
      this.pushReal(value);
    }
  }

  void _funcRand(List<Variant> args) {
    this._argCount('rand', args, 0);
    this.pushReal(this._rand.nextDouble());
  }

  void _funcReal(List<Variant> args) {
    this._argCount('real', args, 1);
    this.pushReal(args[0].asReal);
  }

  void _funcRound(List<Variant> args) {
    this._argCount('round', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not Round $arg.');
    else if (arg.isInt) this._stack.add(arg);
    else this.pushInt(arg.asReal.round());
  }

  void _funcSin(List<Variant> args) {
    this._argCount('sin', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Sin of $arg.');
    else this.pushReal(math.sin(arg.asReal));
  }

  void _funcSqrt(List<Variant> args) {
    this._argCount('sqrt', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Sqrt of $arg.');
    else this.pushReal(math.sqrt(arg.asReal));
  }

  void _funcString(List<Variant> args) {
    this._argCount('string', args, 1);
    this.pushStr(args[0].asStr);
  }

  void _funcSum(List<Variant> args) {
    bool allInt = true;
    for (Variant arg in args) {
      if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Sum with $arg.');
      if (!arg.isInt) allInt = false;
    }

    if (allInt) {
      int value = 0;
      for (Variant arg in args) value += arg.asInt;
      this.pushInt(value);
    } else {
      double value = 0.0;
      for (Variant arg in args) value += arg.asReal;
      this.pushReal(value);
    }
  }

  void _funcTan(List<Variant> args) {
    this._argCount('tan', args, 1);
    Variant arg = args[0];
    if (arg.isStr || arg.isFunc || arg.isBool) throw new Exception('Can not get the Tan of $arg.');
    else this.pushReal(math.tan(arg.asReal));
  }
}
