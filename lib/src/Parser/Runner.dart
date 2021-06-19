part of PetiteParserDart.Parser;

/// The runner performs a parse step by step as tokens are added.
class _Runner {
  final _Table _table;
  final int _errorCap;
  List<String> _errors = [];
  List<ParseTree.TreeNode> _itemStack = [];
  List<int> _stateStack = [];
  bool _accepted = false;
  bool _verbose = false;

  /// Creates a new runner, only the parser may create a runner.
  _Runner(this._table, this._errorCap);

  /// Gets the results from the runner.
  Result get result {
    if (this._errors.length > 0)
      return new Result(List.unmodifiable(this._errors), null);
    if (!this._accepted) {
      this._errors.add('Unexpected end of input.');
      return new Result(List.unmodifiable(this._errors), null);
    }
    return new Result([], this._itemStack[0]);
  }

  /// Determines if the error limit has been reached.
  bool get _errorLimitReached =>
    (this._errorCap > 0) && (this._errors.length >= this._errorCap);

  /// Handles when a default error action has been reached.
  bool _nullAction(int curState, Tokenizer.Token token, String indent) {
    if (this._verbose) print('${indent}null error');
    List<String> tokens = this._table.getAllTokens(curState);
    this._errors.add('Unexpected item, $token, in state $curState. Expected: ${tokens.join(', ')}.');
    if (this._errorLimitReached) return false;
    // Discard token and continue.
    return true;
  }

  /// Handles when a specified error action has been reached.
  bool _errorAction(_Error action, String indent) {
    if (this._verbose) print('${indent}error');
    this._errors.add(action.error);
    if (this._errorLimitReached) return false;
    // Discard token and continue.
    return true;
  }

  /// Handles when a shift action has been reached.
  bool _shiftAction(_Shift action, Tokenizer.Token token, String indent) {
    if (this._verbose) print('${indent}shift ${action.state} on $token');
    this._itemStack.add(new ParseTree.TokenNode(token));
    this._stateStack.add(action.state);
    return true;
  }

  /// Handles when a reduce action has been reached.
  bool _reduceAction(_Reduce action, Tokenizer.Token token, String indent) {
    // Pop the items off the stack for this action.
    // Also check that the items match the expected rule.
    int count = action.rule.items.length;
    List<ParseTree.TreeNode> items = [];
    for (int i = count - 1; i >= 0; i--) {
      Grammar.Item ruleItem = action.rule.items[i];
      if (ruleItem is Grammar.Trigger) {
        items.insert(0, new ParseTree.TriggerNode(ruleItem.name));

      } else {
        this._stateStack.removeLast();
        ParseTree.TreeNode item = this._itemStack.removeLast();
        items.insert(0, item);

        if (ruleItem is Grammar.Term) {
          if (item is ParseTree.RuleNode) {
            if (ruleItem.name != item.rule.term?.name)
              throw new Exception('The action, $action, could not reduce item $i, $item: the term names did not match.');
          } else throw new Exception('The action, $action, could not reduce item $i, $item: the item is not a rule node.');
        } else { // if (ruleItem is Grammar.TokenItem) {
          if (item is ParseTree.TokenNode) {
            if (ruleItem.name != item.token.name)
              throw new Exception('The action, $action, could not reduce item $i, $item: the token names did not match.');
          } else throw new Exception('The action, $action, could not reduce item $i, $item: the item is not a token node.');
        }
      }
    }

    // Create a new item with the items for this rule in it
    // and put it onto the stack.
    ParseTree.RuleNode node = new ParseTree.RuleNode(action.rule, items);
    this._itemStack.add(node);
    if (this._verbose) print('${indent}reduce ${action.rule}');

    // Use the state reduced back to and the new item to seek,
    // via the goto table, the next state to continue from.
    int curState = this._stateStack.last;
    while (true) {
      _Action? action = this._table.readGoto(curState, node.rule.term?.name ?? '');
      if (action == null) break;
      else if (action is _Goto) {
        curState = action.state;
        if (this._verbose) print('${indent}goto ${curState}');
      }
      else throw new Exception('Unexpected goto type: $action');
    }
    this._stateStack.add(curState);

    // Continue with parsing the current token.
    return this._addToken(token, indent+'  ');
  }

  /// Handles when an accept has been reached.
  bool _acceptAction(_Accept action, String indent) {
    if (this._verbose) print('${indent}accept');
    this._accepted = true;
    return true;
  }

  /// Inserts the next look ahead token into the parser.
  bool add(Tokenizer.Token token) {
    if (this._accepted) {
      this._errors.add('unexpected token after end: $token');
      return false;
    }
    return this._addToken(token, '');
  }

  /// Inserts the next look ahead token into the parser.
  /// This is the internal method for `add` which can be called recursively.
  bool _addToken(Tokenizer.Token token, String indent) {
    if (this._verbose) print('$indent$token =>');

    int curState = this._stateStack.last;
    _Action? action = this._table.readShift(curState, token.name);

    bool result;
    if (action == null)         result = this._nullAction(curState, token, indent);
    else if (action is _Shift)  result = this._shiftAction(action, token, indent);
    else if (action is _Reduce) result = this._reduceAction(action, token, indent);
    else if (action is _Accept) result = this._acceptAction(action, indent);
    else if (action is _Error)  result = this._errorAction(action, indent);
    else throw new Exception('Unexpected action type: $action');

    if (this._verbose) print('$indent=> ${this._stackToString()}');
    return result;
  }

  /// Gets a string for the current parser stack.
  String _stackToString() {
    StringBuffer buf = new StringBuffer();
    int max = math.max(this._itemStack.length, this._stateStack.length);
    for (int i = 0; i < max; ++i) {
      if (i != 0) buf.write(', ');
      bool hasState = false;
      if (i < this._stateStack.length) {
        buf.write('${this._stateStack[i]}');
        hasState = true;
      }
      if (i < this._itemStack.length) {
        if (hasState) buf.write(':');
        ParseTree.TreeNode item = this._itemStack[i];
        if (item is ParseTree.RuleNode)         buf.write('<${item.rule.term?.name ?? ''}>');
        else if (item is ParseTree.TokenNode)   buf.write('[${item.token.name}]');
        else if (item is ParseTree.TriggerNode) buf.write('{${item.trigger}}');
      }
    }
    return buf.toString();
  }
}
