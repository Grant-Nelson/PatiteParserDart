part of PatiteParserDart.ParseTree;

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes. 
class RuleNode extends TreeNode {

  /// The grammar rule for this node.
  final Grammar.Rule rule;

  /// The list of items for this rule.
  /// The items are `TreeNodes` and `Tokenizer.Token`s.
  final List<TreeNode> items;

  /// Creates a new tree node.
  RuleNode(this.rule, this.items): super._();

  /// Helps construct the debugging output of the tree.
  void _toTree(StringBuffer buf, String indent, String first) {
    buf.write("$first--${this.rule.term.name}");
    if (items.length > 0) {
      for (int i = 0; i < items.length-1; i++) {
        TreeNode item = items[i];
        if (item is RuleNode) item._toTree(buf, "$indent  |", "\n$indent  |");
        else buf.write("\n$indent  |--$item");
      }
      TreeNode item = items[items.length-1];
      if (item is RuleNode) item._toTree(buf, "$indent   ", "\n$indent  `");
      else buf.write("\n$indent  `--$item");
    }
  }

  /// Gets a string for the tree node.
  String toString() {
    StringBuffer buf = new StringBuffer();
    this._toTree(buf, "", "");
    return buf.toString();
  }
}
