part of PatiteParserDart.test;

class TestArgs {
  bool _failed;
  StringBuffer _buf;

  TestArgs() {
    this._failed = false;
    this._buf = new StringBuffer();
  }

  bool get failed => this._failed;
  String toString() => this._buf.toString();

  void log(String msg) =>
    this._buf.writeln(msg);

  void error(String msg) {
    this._buf.writeln('Error: '+msg);
    this._failed = true;
  }

  void checkTok(Tokenizer tok, String input, List<String> expected) {
    StringBuffer resultBuf = new StringBuffer();
    for (Token token in tok.tokenize(input))
      resultBuf.writeln(token.toString());
    String exp = expected.join('\n');
    String result = resultBuf.toString().trim();
    if (exp != result) {
      String diff = Diff.plusMinusLines(exp, result);
      diff = diff.trim().replaceAll('\n', '\n         ');
      this.error('The input did not match the expected results'+
        '\n  Input: $input'+
        '\n  Diff:  $diff');
    }
  }
  
  void checkParser(Parser parser, List<String> input, List<String> expected) {
    Result parseResult = parser.parse(input.join('\n'));
    String exp = expected.join('\n');
    String result = parseResult.toString();
    if (exp != result) {
      String diff = Diff.plusMinusLines(exp, result);
      diff = diff.trim().replaceAll('\n', '\n        ');
      this.error('The parsed input did not result in the expected result tree'+
        '\n  Diff: $diff');
    }
  }
}
