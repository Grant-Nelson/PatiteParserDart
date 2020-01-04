part of PatiteParserDart.ParseTree;

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes. 
class RuleNode extends TreeNode {

  static const String _charStart  = '─';
  static const String _charBar    = '  │';
  static const String _charBranch = '  ├─';
  static const String _charSpace  = '   ';
  static const String _charLeaf   = '  └─';

  /// The grammar rule for this node.
  final Grammar.Rule rule;

  /// The list of items for this rule.
  /// The items are `TreeNodes` and `Tokenizer.Token`s.
  final List<TreeNode> items;

  /// Creates a new tree node.
  RuleNode(this.rule, this.items): super._();

  /// Helps construct the debugging output of the tree.
  void _toTree(StringBuffer buf, String indent, String first) {
    buf.write(first+'<'+this.rule.term.name+'>');
    if (items.length > 0) {
      for (int i = 0; i < items.length-1; i++) {
        TreeNode item = items[i];
        if (item is RuleNode) item._toTree(buf, indent+_charBar, '\n'+indent+_charBranch);
        else buf.write('\n'+indent+_charBranch+item.toString());
      }
      TreeNode item = items[items.length-1];
      if (item is RuleNode) item._toTree(buf, indent+_charSpace, '\n'+indent+_charLeaf);
      else buf.write('\n'+indent+_charLeaf+item.toString());
    }
  }

  /// Processes this tree node with the given handles for the triggers to call.
  void process(Map<String, TriggerHandle> handles) {
    List<TreeNode> stack = new List<TreeNode>();
    stack.add(this);
    List<Tokenizer.Token> tokens = new List<Tokenizer.Token>();
    while (stack.isNotEmpty) {
      TreeNode node = stack.removeLast();
      if (node is RuleNode) stack.addAll(items);
      else if (node is TokenNode) tokens.add(node.token);
      else if (node is TriggerNode) {
        if (!handles.containsKey(node.trigger))
          throw new Exception('Failed to find the handle for the trigger, ${node.trigger}');
        handles[node.trigger](tokens);
      }
    }
  }

  /// Gets a string for the tree node.
  String toString() {
    StringBuffer buf = new StringBuffer();
    this._toTree(buf, '', _charStart);
    return buf.toString();
  }
}
