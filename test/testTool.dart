part of PatiteParserDart.test;

class TestTool {
  bool _failed;

  void printResult() =>
    print(this._failed? 'FAILED': 'PASSED');

  void run(Function(TestArgs args) test) {
    TestArgs args = new TestArgs();
    test(args);
    if (args.failed) {
      print('${args.toString()}Test failed');
      this._failed = true;
    }
  }
}
