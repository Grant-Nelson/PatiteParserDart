part of PetiteParserDart.test;

/// The main tool for testing.
class TestTool {
  bool _failed;
  bool _buffered;

  /// Creates a new testing tool.
  TestTool({bool buffered = true}) {
    this._failed = false;
    this._buffered = buffered;
  }

  /// prints the results of all the tests.
  void printResult() =>
    print(this._failed? 'FAILED': 'PASSED');

  /// Runs a test given the test function.
  void run(Function(TestArgs args) test) {
    TestArgs args = new TestArgs(this._buffered);
    test(args);
    if (args.failed) {
      print('${args.toString()}Test failed');
      this._failed = true;
    }
  }
}
