part of PatiteParserDart.examples;

void runCalculatorExample() async {
  print("Enter in an equation and press enter to calculate the result.");
  print("See documentation for more information.");
  io.stdout.write("> ");
  String input = io.stdin.readLineSync();

  Calculator calc = new Calculator();
  await calc.loadParser();
  calc.calculate(input);
  print(calc.result);
}

enum _ValueType {
  String,
  Integer,
  Real,
  Tag
}

class _Value {
  final _ValueType type;
  final Object value;

  _Value(this.type, this.value);

  bool get isStr => this.type == _ValueType.String;
  bool get isInt => this.type == _ValueType.Integer;
  bool get isReal => this.type == _ValueType.Real;
  bool get isTag => this.type == _ValueType.Tag;

  String get asStr {
    if (isStr || isTag) return this.value as String;
    else if (isInt) return (this.value as int).toString();
    else return (this.value as double).toString();
  }

  int get asInt {
    if (isStr || isTag) return int.parse(value as String);
    else if (isInt) return this.value as int;
    else return (this.value as double).toInt();
  }

  double get asReal {
    if (isStr || isTag) return double.parse(value as String);
    else if (isInt) return (this.value as int).toDouble();
    else return this.value as double;
  }
}

typedef void _CalcFunc(List<_Value> args);

class Calculator {
  Parser.Parser _parser;
  Map<String, ParseTree.TriggerHandle> _handles;
  List<_Value> _stack;
  Map<String, _Value> _consts;
  Map<String, _CalcFunc> _funcs;

  Calculator() {
    this._parser = null;
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
      'Octal':       this._handleOctal,
      'Or':          this._handleOr,
      'Power':       this._handlePower,
      'Real':        this._handleReal,
      'StartCall':   this._handleStartCall,
      'Subtract':    this._handleSubtract};
    this._stack = new List<_Value>();
    this._consts = {
      "pi": new _Value(_ValueType.Real, 3.14159265358979323846),
      "e":  new _Value(_ValueType.Real, 2.71828182845904523536)};
    this._funcs = {
      "min":    this._funcMin,
      "max":    this._funcMax,
      "avg":    this._funcAvg,
      "atan2":  this._funcAtan2,
      "sin":    this._funcSin,
      "cos":    this._funcCos,
      "tan":    this._funcTan,
      "sqrt":   this._funcSqrt,
      "ln":     this._funcLn,
      "log":    this._funcLog,
      "log10":  this._funcLog10,
      "floor":  this._funcFloor,
      "ceil":   this._funcCeil,
      "xor":    this._funcXor,
      "real":   this._funcReal,
      "int":    this._funcInt,
      "string": this._funcString};
  }

  void loadParser() async {
    String language = await new io.File('examples/calculator.txt').readAsString();
    this._parser = new Parser.Parser.fromDefinition(language);
  }

  void calculate(String input) {
    if (input.isEmpty) return;
    Parser.Result result = this._parser.parse(input);

    if (result.errors?.isNotEmpty ?? false) {
      this._stack.add(new _Value(_ValueType.String,
        'Errors in calculator input:\n' + result.errors.join('\n')));
      return;
    }

    // try {
      result.tree.process(this._handles);
    // } catch (err) {
    //   this._stack.add(new _Value(_ValueType.String,
    //     'Errors in calculator input:\n' + err.toString()));
    // }
  }

  String get result {
    if (this._stack.length <= 0) return 'no result';
    List<String> parts = new List<String>();
    for (_Value val in this._stack) parts.add('${val.value}');
    return parts.join('\n');
  }

  _Value pop() => this._stack.removeLast();

  void pushStr(String value) => this._stack.add(new _Value(_ValueType.String, value));

  void pushInt(int value) => this._stack.add(new _Value(_ValueType.Integer, value));
  
  void pushReal(double value) => this._stack.add(new _Value(_ValueType.Real, value));

  void pushTag(String value) => this._stack.add(new _Value(_ValueType.Tag, value));

  void _handleAdd(ParseTree.TriggerArgs args) {
    _Value right = this.pop(), left  = this.pop();
    if (left.isTag || right.isTag) 
      throw new Exception('Can not Add "${left.value}" to "${right.value}".');
    else if (left.isStr && right.isStr) this.pushStr(left.asStr + right.asStr);
    else if (left.isStr || right.isStr) 
      throw new Exception('Can not Add "${left.value}" to "${right.value}".');
    else if (left.isReal || right.isReal) this.pushReal(left.asReal + right.asReal);
    else this.pushInt(left.asInt + right.asInt);
  }

  void _handleAnd(ParseTree.TriggerArgs args) {
    _Value right = this.pop(), left  = this.pop();
    if (left.isInt && right.isInt) this.pushInt(left.asInt & right.asInt);
    else throw new Exception('Can not And "${left.value}" with "${right.value}".');
  }

  void _handleBinary(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    this.pushInt(int.parse(text, radix: 2));
    args.tokens.clear();
  }

  void _handleCall(ParseTree.TriggerArgs args) {
    // TODO: Implement
  }

  void _handleDecimal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    this.pushInt(int.parse(text, radix: 10));
    args.tokens.clear();
  }

  void _handleDivide(ParseTree.TriggerArgs args) {
    _Value right = this.pop(), left  = this.pop();
    if (left.isStr || left.isTag || right.isStr || right.isTag) 
      throw new Exception('Can not Divide "${left.value}" and "${right.value}".');
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
    _Value top = this.pop();
    if (top.isInt) this.pushInt(~top.asInt);
    else throw new Exception('Can not Invert "${top.value}".');
  }

  void _handleHexadecimal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    this.pushInt(int.parse(text, radix: 16));
    args.tokens.clear();
  }

  void _handleMultiply(ParseTree.TriggerArgs args) {
    _Value right = this.pop(), left  = this.pop();
    if (left.isStr || left.isTag || right.isStr || right.isTag) 
      throw new Exception('Can not Multiply "${left.value}" to "${right.value}".');
    else if (left.isReal || right.isReal) this.pushReal(left.asReal * right.asReal);
    else this.pushInt(left.asInt * right.asInt);
  }

  void _handleNegate(ParseTree.TriggerArgs args) {
    _Value top = this.pop();
    if (top.isInt) this.pushInt(-top.asInt);
    else if (top.isReal) this.pushReal(-top.asReal);
    else throw new Exception('Can not Negate "${top.value}".');
  }

  void _handleOctal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    this.pushInt(int.parse(text, radix: 8));
    args.tokens.clear();
  }

  void _handleOr(ParseTree.TriggerArgs args) {
    _Value right = this.pop(), left  = this.pop();
    if (left.isInt && right.isInt) this.pushInt(left.asInt | right.asInt);
    else throw new Exception('Can not Or "${left.value}" to "${right.value}".');
  }

  void _handlePower(ParseTree.TriggerArgs args) {
    _Value right = this.pop(), left  = this.pop();
    if (left.isStr || left.isTag || right.isStr || right.isTag) 
      throw new Exception('Can not Subtract "${left.value}" from "${right.value}".');
    else if (left.isReal || right.isReal) this.pushReal(math.pow(left.asReal, right.asReal));
    else this.pushInt(left.asInt ^ right.asInt);
  }

  void _handleReal(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    this.pushReal(double.parse(text));
    args.tokens.clear();
  }

  void _handleStartCall(ParseTree.TriggerArgs args) {
    String text = args.recent(1).text;
    this.pushTag(text);
    args.tokens.clear();
  }

  void _handleSubtract(ParseTree.TriggerArgs args) {
    _Value right = this.pop(), left  = this.pop();
    if (left.isStr || left.isTag || right.isStr || right.isTag) 
      throw new Exception('Can not Subtract "${left.value}" from "${right.value}".');
    else if (left.isReal || right.isReal) this.pushReal(left.asReal - right.asReal);
    else this.pushInt(left.asInt - right.asInt);
  }

  void _funcMin(List<_Value> args) {
    // TODO: Implement
  }

  void _funcMax(List<_Value> args) {
    // TODO: Implement
  }

  void _funcAvg(List<_Value> args) {
    // TODO: Implement
  }

  void _funcAtan2(List<_Value> args) {
    // TODO: Implement
  }

  void _funcSin(List<_Value> args) {
    // TODO: Implement
  }

  void _funcCos(List<_Value> args) {
    // TODO: Implement
  }

  void _funcTan(List<_Value> args) {
    // TODO: Implement
  }

  void _funcSqrt(List<_Value> args) {
    // TODO: Implement
  }

  void _funcLn(List<_Value> args) {
    // TODO: Implement
  }

  void _funcLog(List<_Value> args) {
    // TODO: Implement
  }

  void _funcLog10(List<_Value> args) {
    // TODO: Implement
  }

  void _funcFloor(List<_Value> args) {
    // TODO: Implement
  }

  void _funcCeil(List<_Value> args) {
    // TODO: Implement
  }

  void _funcXor(List<_Value> args) {
    // TODO: Implement
  }

  void _funcReal(List<_Value> args) {
    // TODO: Implement
  }

  void _funcInt(List<_Value> args) {
    // TODO: Implement
  }

  void _funcString(List<_Value> args) {
    // TODO: Implement
  }
}
