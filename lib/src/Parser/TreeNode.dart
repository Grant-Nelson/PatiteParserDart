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

  /// Gets a string for the debugging the parser.
  String toString() {
    StringBuffer buf = new StringBuffer();
    buf.write("${this.term}->[");
    for (int i = 0; i < items.length; i++) {
      if (i > 0) buf.write(" ");
      buf.write(items[i]);
    }
    buf.write("]");
    return buf.toString();
  }
}
