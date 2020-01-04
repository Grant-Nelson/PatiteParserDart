library PatiteParserDart.ParseTree;

import 'package:PatiteParserDart/src/Grammar/Grammar.dart' as Grammar;
import 'package:PatiteParserDart/src/Tokenizer/Tokenizer.dart' as Tokenizer;

part 'RuleNode.dart';
part 'TokenNode.dart';
part 'TriggerNode.dart';

/// The handler signature for a method to call for a specific trigger.
typedef void TriggerHandle(List<Tokenizer.Token> tokens);

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes. 
abstract class TreeNode {

  /// Creates a new tree node.
  TreeNode._();

  /// Processes this tree node with the given handles for the triggers to call.
  void process(Map<String, TriggerHandle> handles);
}
