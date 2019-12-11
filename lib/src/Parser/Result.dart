part of PatiteParserDart.Parser;

/// This is the result from a parse of a stream of tokens.
class Result {

  /// Any errors which occurred during the parse.
  final List<String> errors;

  /// The tree of the parsed tokens into grammar rules.
  /// This will be null if there are any errors.
  final TreeNode tree;

  /// Creates a new parser result.
  Result(this.errors, this.tree);

  /// Gets the human-readable debug string for these results.
  String toString() {
    StringBuffer buf = new StringBuffer();
    if (this.errors != null) {
      for (String error in this.errors) {
        if (buf.isNotEmpty) buf.writeln();
        buf.write(error);
      }
    }
    if (tree != null) buf.write(tree.toString(true));
    return buf.toString();
  }
}
