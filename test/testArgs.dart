part of PetiteParserDart.test;

/// The arguments passed into a test.
class TestArgs {
  bool _failed;
  StringBuffer _buf;

  /// Creates a new test argument.
  TestArgs() {
    this._failed = false;
    this._buf = new StringBuffer();
  }

  /// Indicates if the test has failed or not.
  bool get failed => this._failed;

  /// Gets the buffered log for this test.
  String toString() => this._buf.toString();

  /// Writes an output to the test log.
  void log(String msg) =>
    this._buf.writeln(msg);

  /// Indicates an error occurred.
  void error(String msg) {
    this._buf.writeln('Error: '+msg);
    this._failed = true;
  }

  /// Checks if the given rule's string method.
  void checkRuleString(Grammar.Rule rule, int index, String exp) {
    String result = rule.toString(index);
    if (exp != result) {
      this.error('The rule did not return the expected string:'+
        '\n  Index:    $index'+
        '\n  Expected: $exp'+
        '\n  Result:   $result');
    }
  }

  /// Checks if the given lines diff as expected.
  void checkDiff(List<String> a, List<String> b, List<String> exp) {
    String result = Diff.plusMinusParts(a, b).join('|');
    String expStr = exp.join('|');
    if (expStr != result) {
      this.error('The diff did not return the expected result:'+
        '\n  A Input:  ${a.join("|")}'+
        '\n  B Input:  ${b.join("|")}'+
        '\n  Expected: $expStr'+
        '\n  Result:   $result');
    }
  }

  /// Checks the grammar results.
  void checkGrammar(Grammar.Grammar grammar, List<String> expected) {
    String exp = expected.join('\n');
    String result = grammar.toString().trim();
    if (exp != result) {
      String diff = Diff.plusMinusLines(exp, result);
      diff = diff.trimRight().replaceAll('\n', '\n        ');
      this.error('The grammar string did not match the expected results:'+
        '\n  Diff: $diff');
    }
  }

  /// Checks the grammar term's first tokens results.
  void checkTermFirst(Grammar.Grammar grammar, String token, List<String> expected) {
    String exp = expected.join('\n');
    List<Grammar.TokenItem> firsts = grammar.term(token).determineFirsts();
    String result = firsts.join('\n');
    if (exp != result) {
      String diff = Diff.plusMinusLines(exp, result);
      diff = diff.trimRight().replaceAll('\n', '\n         ');
      this.error('The grammar term firsts did not match the expected results:'+
        '\n  Token: $token'
        '\n  Diff:  $diff');
    }
  }

  /// Checks the grammar term's follow tokens results.
  void checkTermFollow(Grammar.Grammar grammar, String token, List<String> expected) {
    String exp = expected.join('\n');
    List<Grammar.TokenItem> firsts = grammar.term(token).determineFollows();
    String result = firsts.join('\n');
    if (exp != result) {
      String diff = Diff.plusMinusLines(exp, result);
      diff = diff.trimRight().replaceAll('\n', '\n         ');
      this.error('The grammar term follows did not match the expected results:'+
        '\n  Token: $token'
        '\n  Diff:  $diff');
    }
  }

  /// Checks the tokenizer results.
  void checkTok(Tokenizer.Tokenizer tok, String input, List<String> expected) {
    StringBuffer resultBuf = new StringBuffer();
    for (Tokenizer.Token token in tok.tokenize(input))
      resultBuf.writeln(token.toString());
    String exp = expected.join('\n');
    String result = resultBuf.toString().trim();
    if (exp != result) {
      String diff = Diff.plusMinusLines(exp, result);
      diff = diff.trimRight().replaceAll('\n', '\n         ');
      this.error('The input did not match the expected results:'+
        '\n  Input: $input'+
        '\n  Diff:  $diff');
    }
  }

  /// Checks the parser will parse the given input.
  void checkParser(Parser.Parser parser, List<String> input, List<String> expected) {
    Parser.Result parseResult = parser.parse(input.join('\n'));
    String exp = expected.join('\n');
    String result = parseResult.toString();
    if (exp != result) {
      String diff = Diff.plusMinusLines(exp, result);
      diff = diff.trimRight().replaceAll('\n', '\n        ');
      this.error('The parsed input did not result in the expected result tree:'+
        '\n  Diff: $diff');
    }
  }

  /// Checks that an expected error from the parser builder.
  void checkParserBuildError(Grammar.Grammar grammar, Tokenizer.Tokenizer tokenizer, List<String> expected) {
    String exp = expected.join('\n');
    try {
      new Parser.Parser.fromGrammar(grammar, tokenizer);
      this.error('Expected an exception from parser builder but got none:'+
          '\n  Expected: $exp');
    } catch (err) {
      String result = '$err'.trimRight();
      if (exp != result) {
        String diff = Diff.plusMinusLines(exp, result);
        diff = diff.trimRight().replaceAll('\n', '\n        ');
        this.error('Got a different error from the parser builder than expected:'+
          '\n  Diff: $diff');
      }
    }
  }

  /// Checks that the given input to the given calculator will result in the expected lines on the stack.
  void checkCalc(Calculator.Calculator calc, String input, List<String> expected) {
    calc.clear();
    calc.calculate(input);
    String result = calc.stackToString;
    String exp = expected.join('\n');
    if (exp != result) {
        String diff = Diff.plusMinusLines(exp, result);
        diff = diff.trimRight().replaceAll('\n', '\n        ');
        this.error('Got a different result from the calculator than expected:'+
          '\n  Diff: $diff');
    }
  }
}
