part of PatiteParserDart.Parser;

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes. 
class TreeNode {

  /// The gammar term for this node.
  final String term;

  /// The list of items for this term.
  /// The items are `TreeNodes` and `Tokenizer.Token`s.
  final List<Object> items;

  /// Creates a new tree node.
  TreeNode(this.term, this.items);

  /// Helps construct the debugging output of the tree.
  void _toTree(StringBuffer buf, String indent, String first) {
    buf.write("$first--${this.term}");
    if (items.length > 0) {
      for (int i = 0; i < items.length-1; i++) {
        Object item = items[i];
        if (item is TreeNode) item._toTree(buf, "$indent  |", "\n$indent  |");
        else buf.write("\n$indent  |--$item");
      }
      Object item = items[items.length-1];
      if (item is TreeNode) item._toTree(buf, "$indent   ", "\n$indent  `");
      else buf.write("\n$indent  `--$item");
    }
  }

  /// Gets a string for the debugging the parser.
  String toString([bool verbose = false]) {
    StringBuffer buf = new StringBuffer();
    if (verbose) this._toTree(buf, "", "");
    else {
      buf.write("${this.term}(");
      for (int i = 0; i < items.length; i++) {
        if (i > 0) buf.write(", ");
        buf.write("$items[i]");
      }
      buf.write(")");
    } 
    return buf.toString();
  }
}
