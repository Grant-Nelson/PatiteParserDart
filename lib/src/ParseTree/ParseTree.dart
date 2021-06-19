library PetiteParserDart.ParseTree;

import 'package:PetiteParserDart/src/Grammar/Grammar.dart' as Grammar;
import 'package:PetiteParserDart/src/Tokenizer/Tokenizer.dart' as Tokenizer;

part 'RuleNode.dart';
part 'TokenNode.dart';
part 'TriggerNode.dart';

/// The handler signature for a method to call for a specific trigger.
typedef void TriggerHandle(TriggerArgs args);

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes.
abstract class TreeNode {

  /// Creates a new tree node.
  TreeNode._();

  /// Processes this tree node with the given handles for the triggers to call.
  void process(Map<String, TriggerHandle> handles);
}

/// The argument passed into the trigger handler when it is being called.
class TriggerArgs {

  /// The list of recent tokens while processing a tree node.
  List<Tokenizer.Token> tokens = [];

  /// Creates a new trigger argument.
  TriggerArgs();

  /// Gets the recent token offset from most recent by the given index.
  Tokenizer.Token? recent(int index) =>
    ((index > 0) && (index <= tokens.length))? this.tokens[this.tokens.length-index]: null;
}
