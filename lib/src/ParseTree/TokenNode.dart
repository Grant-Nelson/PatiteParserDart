part of PatiteParserDart.ParseTree;

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes. 
class TokenNode extends TreeNode {

  /// The token found at this point in the parse tree.
  final Tokenizer.Token token;

  /// Creates a new token parse tree node.
  TokenNode(Tokenizer.Token this.token): super._();
  
  /// Gets a string for this tree node.
  String toString() => '[${this.token.toString()}]';
}
