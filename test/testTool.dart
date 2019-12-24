part of PatiteParserDart.test;

/// The main tool for testing.
class TestTool {
  bool _failed;

  /// Creates a new testing tool.
  TestTool() {
    this._failed = false;
  }

  /// prints the results of all the tests.
  void printResult() =>
    print(this._failed? 'FAILED': 'PASSED');

  /// Runs a test given the test function.
  void run(Function(TestArgs args) test) {
    TestArgs args = new TestArgs();
    test(args);
    if (args.failed) {
      print('${args.toString()}Test failed');
      this._failed = true;
    }
  }
}
