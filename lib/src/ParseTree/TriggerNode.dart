part of PetiteParserDart.ParseTree;

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes.
class TriggerNode extends TreeNode {

  /// The token found at this point in the parse tree.
  final String trigger;

  /// Creates a new token parse tree node.
  TriggerNode(String this.trigger): super._();

  /// Processes this tree node with the given handles for the triggers to call.
  void process(Map<String, TriggerHandle> handles) {
    if (!handles.containsKey(this.trigger))
      throw new Exception('Failed to find the handle for the trigger, ${this.trigger}');
    handles[this.trigger]?.call(new TriggerArgs());
  }

  /// Gets a string for this tree node.
  String toString() => '{${this.trigger}}';
}
