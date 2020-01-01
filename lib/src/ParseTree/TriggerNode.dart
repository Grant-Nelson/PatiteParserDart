part of PatiteParserDart.ParseTree;

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes. 
class TriggerNode extends TreeNode {

  /// The token found at this point in the parse tree.
  final String trigger;

  /// Creates a new token parse tree node.
  TriggerNode(String this.trigger): super._();
  
  /// Gets a string for this tree node.
  String toString() => '{${this.trigger}}';
}
