part of PatiteParserDart.test;

void diff00(TestArgs args) {
  args.log('diff00');

  String diff = Diff.plusMinusLines("a\nb\nc", "a\nd\nb\nc");
  args.error(diff.replaceAll('\n', '|'));
}