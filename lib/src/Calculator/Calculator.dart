library PatiteParserDart.Calculator;

import 'package:resource/resource.dart' show Resource;
import 'package:PatiteParserDart/src/Parser/Parser.dart' as Parser;
import 'package:PatiteParserDart/src/ParseTree/ParseTree.dart' as ParseTree;

import 'dart:math' as math;
import 'dart:async';

part 'CalcFuncs.dart';
part 'Variant.dart';

/// This is the signature for functions which can be called by the calculator.
///
/// DO NOT implement functions which my give access to gain control over a website or application.
typedef Object CalcFunc(List<Object> args);

/// An implementation of a simple calculator language.
///
/// This is useful for allowing a text field with higher mathematic control
/// without exposing exploits via a full language input.
///
/// This is also an example of how to use patite parser to construct
/// a simple interpreted language.
class Calculator {
  static Parser.Parser _parser;
  
  /// Loads the parser used by the calculator.
  ///
  /// This is done in a static method since to load the language
  /// from a file it has to be done asynchronously.
  static Future loadParser() async {
    if (_parser == null) {
      Resource resource = const Resource('package:PatiteParserDart/src/Calculator/Calculator.txt');
      return resource.readAsString().then((String language) {
        _parser = new Parser.Parser.fromDefinition(language);
      });
    }
    return null;
  }

  Map<String, ParseTree.TriggerHandle> _handles;
  List<Object> _stack;
  Map<String, Object> _consts;
  Map<String, Object> _vars;
  _CalcFuncs _funcs;

  // Creates a new calculator instance.
  Calculator() {
    this._handles = {
      'Add':          this._handleAdd,
      'And':          this._handleAnd,
      'Assign':       this._handleAssign,
      'Binary':       this._handleBinary,
      'Call':         this._handleCall,
      'Decimal':      this._handleDecimal,
      'Divide':       this._handleDivide,
      'Equal':        this._handleEqual,
      'GreaterEqual': this._handleGreaterEqual,
      'GreaterThan':  this._handleGreaterThan,
      'Hexadecimal':  this._handleHexadecimal,
      'Id':           this._handleId,
      'Invert':       this._handleInvert,
      'LessEqual':    this._handleLessEqual,
      'LessThan':     this._handleLessThan,
      'Multiply':     this._handleMultiply,
      'Negate':       this._handleNegate,
      'Not':          this._handleNot,
      'NotEqual':     this._handleNotEqual,
      'Octal':        this._handleOctal,
      'Or':           this._handleOr,
      'Power':        this._handlePower,
      'PushVar':      this._handlePushVar,
      'Real':         this._handleReal,
      'StartCall':    this._handleStartCall,
      'String':       this._handleString,
      'Subtract':     this._handleSubtract,
      'Xor':          this._handleXor};
    this._stack = new List<Object>();
    this._consts = {
      "pi":    math.pi,
      "e":     math.e,
      "true":  true,
      "false": false};
    this._vars = new Map<String, Object>();
    this._funcs = new _CalcFuncs();
  }

  /// This parses the given calculation input and
  /// puts the result on the top of the stack.
  void calculate(String input) {
    if (input.isEmpty) return;
    if (_parser == null) {
      this.push('Error: The parser must have finished loading prior to calculating any input.');
      return;
    }
    Parser.Result result = _parser.parse(input);

    if (result.errors?.isNotEmpty ?? false) {
      this.push('Errors in calculator input:\n' + result.errors.join('\n'));
      return;
    }

    try {
      result.tree.process(this._handles);
    } catch (err) {
      this.push('Errors in calculator input:\n' + err.toString());
    }
  }

  /// Get a string showing all the values in the stack.
  String get stackToString {
    if (this._stack.length <= 0) return 'no result';
    List<String> parts = new List<String>();
    for (Object val in this._stack) parts.add('${val}');
    return parts.join('\n');
  }

  /// Adds a new function that can be called by the language.
  /// Set to null to remove a function.
  void addFunc(String name, CalcFunc hndl) => this._funcs.addFunc(name, hndl);
  
  /// Adds a new constant value into the language.
  /// Set to null to remove the constant.
  void addConstant(String name, Object value) {
    if (value == null) this._consts.remove(name);
    else this._consts[name] = value;
  }

  /// Sets the value of a variable.
  /// Set to null to remove the variable.
  void setVar(String name, Object value) {
    if (value == null) this._vars.remove(name);
    else this._vars[name] = value;
  }

  /// Indicates if the stack is empty or not.
  bool get stackEmpty => this._stack.isEmpty;

  /// Clears all the values from the stack.
  void clear() => this._stack.clear();

  /// Removes the top value from the stack.
  Object pop() => this._stack.removeLast();

  /// Pushes a value onto the stack.
  void push(Object value) => this._stack.add(value);

  /// Handles calculating the sum of the top two items off of the stack.
  void _handleAdd(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitInt  && right.implicitInt)  this.push(left.asInt  + right.asInt);
    else if (left.implicitReal && right.implicitReal) this.push(left.asReal + right.asReal);
    else if (left.implicitStr  && right.implicitStr)  this.push(left.asStr  + right.asStr);
    else throw new Exception('Can not Add $left to $right.');
  }

  /// Handles AND-ing the top two items off the stack.
  void _handleAnd(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitBool && right.implicitBool) this.push(left.asBool && right.asBool);
    else if (left.implicitInt  && right.implicitInt)  this.push(left.asInt  &  right.asInt);
    else throw new Exception('Can not And $left with $right.');
  }

  /// Handles assigning an variable to the top value off of the stack.
  void _handleAssign(ParseTree.TriggerArgs args) {
    Object right = this.pop();
    Variant left = new Variant(this.pop());
    if (!left.isStr) throw new Exception('Can not Assign $right to $left.');
    String text = left.asStr;
    if (this._consts.containsKey(text))
      throw new Exception('Can not Assign $right to the constant $left.');
    this._vars[text] = right;
  }

  /// Handles adding a binary integer value from the input tokens.
  void _handleBinary(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    args.tokens.clear();
    text = text.substring(0, text.length-1); // remove 'b'
    this.push(int.parse(text, radix: 2));
  }

  /// Handles calling a function, taking it's parameters off the stack.
  void _handleCall(ParseTree.TriggerArgs args) {
    List<Object> methodArgs = new List<Object>();
    Object val = this.pop();
    while (val is! CalcFunc) {
      methodArgs.insert(0, val);
      val = this.pop();
    }
    this.push((val as CalcFunc)(methodArgs));
  }

  /// Handles adding a decimal integer value from the input tokens.
  void _handleDecimal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    args.tokens.clear();
    if (text.endsWith('d')) text = text.substring(0, text.length-1);
    this.push(int.parse(text, radix: 10));
  }

  /// Handles dividing the top two items on the stack.
  void _handleDivide(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitInt  && right.implicitInt)  this.push(left.asInt ~/ right.asInt);
    else if (left.implicitReal && right.implicitReal) this.push(left.asReal / right.asReal);
    else throw new Exception('Can not Divide $left with $right.');
  }
  
  /// Handles checking if the two top items on the stack are equal.
  void _handleEqual(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitBool && right.implicitBool) this.push(left.asBool == right.asBool);
    else if (left.implicitInt  && right.implicitInt)  this.push(left.asInt  == right.asInt);
    else if (left.implicitReal && right.implicitReal) this.push(left.asReal == right.asReal);
    else if (left.implicitStr  && right.implicitStr)  this.push(left.asStr  == right.asStr);
    else throw new Exception('Can not Equals $left and $right.');
  }

  /// Handles checking if the two top items on the stack are greater than or equal.
  void _handleGreaterEqual(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitInt  && right.implicitInt)  this.push(left.asInt  >= right.asInt);
    else if (left.implicitReal && right.implicitReal) this.push(left.asReal >= right.asReal);
    else throw new Exception('Can not Greater Than or Equals $left and $right.');
  }

  /// Handles checking if the two top items on the stack are greater than.
  void _handleGreaterThan(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitInt  && right.implicitInt)  this.push(left.asInt  > right.asInt);
    else if (left.implicitReal && right.implicitReal) this.push(left.asReal > right.asReal);
    else throw new Exception('Can not Greater Than $left and $right.');
  }

  /// Handles looking up a constant or variable value.
  void _handleId(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    args.tokens.clear();
    if (this._consts.containsKey(text)) {
      this._stack.add(this._consts[text]);
      return;
    }
    if (this._vars.containsKey(text)) {
      this._stack.add(this._vars[text]);
      return;
    }
    throw new Exception('No constant called $text found.');
  }

  /// Handles inverting the top value on the stack.
  void _handleInvert(ParseTree.TriggerArgs args) {
    Variant top = new Variant(this.pop());
    if (top.isInt) this.push(~top.asInt);
    else throw new Exception('Can not Invert $top.');
  }

  /// Handles checking if the two top items on the stack are less than or equal.
  void _handleLessEqual(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitInt  && right.implicitInt)  this.push(left.asInt  <= right.asInt);
    else if (left.implicitReal && right.implicitReal) this.push(left.asReal <= right.asReal);
    else throw new Exception('Can not Not Equals $left and $right.');
  }

  /// Handles checking if the two top items on the stack are less than.
  void _handleLessThan(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitInt  && right.implicitInt)  this.push(left.asInt  < right.asInt);
    else if (left.implicitReal && right.implicitReal) this.push(left.asReal < right.asReal);
    else throw new Exception('Can not Not Equals $left and $right.');
  }

  /// Handles adding a hexadecimal integer value from the input tokens.
  void _handleHexadecimal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    args.tokens.clear();
    text = text.substring(2); // remove '0x'
    this.push(int.parse(text, radix: 16));
  }

  /// Handles calculating the multiplies of the top two items off of the stack.
  void _handleMultiply(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitInt  && right.implicitInt)  this.push(left.asInt  * right.asInt);
    else if (left.implicitReal && right.implicitReal) this.push(left.asReal * right.asReal);
    else throw new Exception('Can not Multiply $left to $right.');
  }

  /// Handles negating the an integer or real value.
  void _handleNegate(ParseTree.TriggerArgs args) {
    Variant top = new Variant(this.pop());
    if      (top.isInt)  this.push(-top.asInt);
    else if (top.isReal) this.push(-top.asReal);
    else throw new Exception('Can not Negate $top.');
  }

  /// Handles NOT-ing the boolean values at the top of the the stack.
  void _handleNot(ParseTree.TriggerArgs args) {
    Variant top = new Variant(this.pop());
    if (top.isBool) this.push(!top.asBool);
    else throw new Exception('Can not Not $top.');
  }

  /// Handles checking if the two top items on the stack are not equal.
  void _handleNotEqual(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitBool && right.implicitBool) this.push(left.asBool == right.asBool);
    else if (left.implicitInt  && right.implicitInt)  this.push(left.asInt  == right.asInt);
    else if (left.implicitReal && right.implicitReal) this.push(left.asReal == right.asReal);
    else if (left.implicitStr  && right.implicitStr)  this.push(left.asStr  == right.asStr);
    else throw new Exception('Can not Not Equals $left and $right.');
  }

  /// Handles adding a octal integer value from the input tokens.
  void _handleOctal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    args.tokens.clear();
    text = text.substring(0, text.length-1); // remove 'o'
    this.push(int.parse(text, radix: 8));
  }

  /// Handles OR-ing the boolean values at the top of the the stack.
  void _handleOr(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitBool && right.implicitBool) this.push(left.asBool || right.asBool);
    else if (left.implicitInt  && right.implicitInt)  this.push(left.asInt  |  right.asInt);
    else throw new Exception('Can not Or $left to $right.');
  }

  /// Handles calculating the power of the top two values on the stack.
  void _handlePower(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if (left.implicitReal && right.implicitReal) this.push(math.pow(left.asReal, right.asReal));
    else throw new Exception('Can not Power $left and $right.');
  }

  /// Handles push an ID value from the input tokens
  /// which will be used later as a variable name.
  void _handlePushVar(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    args.tokens.clear();
    this.push(text);
  }
  
  /// Handles adding a real value from the input tokens.
  void _handleReal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    args.tokens.clear();
    this.push(double.parse(text));
  }

  /// Handles starting a function call.
  void _handleStartCall(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text.toLowerCase();
    args.tokens.clear();
    CalcFunc func = this._funcs.findFunc(text);
    if (func == null) throw new Exception('No function called $text found.');
    this.push(func);
  }

  /// Handles adding a string value from the input tokens.
  void _handleString(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    args.tokens.clear();
    this.push(Parser.Loader.unescapeString(text));
  }

  /// Handles calculating the difference of the top two items off of the stack.
  void _handleSubtract(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if      (left.implicitInt  && right.implicitInt)  this.push(left.asInt  - right.asInt);
    else if (left.implicitReal && right.implicitReal) this.push(left.asReal - right.asReal);
    else throw new Exception('Can not Subtract $left to $right.');
  }

  /// Handles XOR-ing the boolean values at the top of the the stack.
  void _handleXor(ParseTree.TriggerArgs args) {
    Variant right = new Variant(this.pop());
    Variant left  = new Variant(this.pop());
    if (left.implicitInt && right.implicitInt) this.push(left.asInt ^ right.asInt);
    else throw new Exception('Can not Multiply $left to $right.');
  }
}
