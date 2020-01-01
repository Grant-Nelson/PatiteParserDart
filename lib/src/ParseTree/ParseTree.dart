library PatiteParserDart.ParseTree;

import 'package:PatiteParserDart/src/Grammar/Grammar.dart' as Grammar;
import 'package:PatiteParserDart/src/Tokenizer/Tokenizer.dart' as Tokenizer;

part 'RuleNode.dart';
part 'TokenNode.dart';
part 'TriggerNode.dart';

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes. 
abstract class TreeNode {

  /// Creates a new tree node.
  TreeNode._();
}
