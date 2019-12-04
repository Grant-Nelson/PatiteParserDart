part of PatiteParserDart.Parser;

/// The runner performs a parse step by step as tokens are added.
class _Runner {
  final _Table _table;
  final int _errorCap;
  List<String> _errors;
  List<Object> _itemStack;
  List<int> _stateStack;
  bool _accepted;

  /// Creates a new runner, only the parser may create a runner.
  _Runner(this._table, this._errorCap) {
    this._errors = new List<String>();
    this._itemStack = [];
    this._stateStack = [0];
    this._accepted = false;
  }

  /// Gets the results from the runner.
  Result get result {
    if (this._errors.length > 0)
      return new Result(List.unmodifiable(this._errors), null);
    if (!this._accepted) {
      this._errors.add("unexpected end of input");
      return new Result(List.unmodifiable(this._errors), null);
    }
    return new Result(null, this._itemStack[0] as TreeNode);
  }

  /// Determines if the error limit has been reached.
  bool get _errorLimitReached =>
    (this._errorCap > 0) && (this._errors.length >= this._errorCap);

  /// Handles when a default error action has been reached.
  bool _nullAction(Token token) {
    this._errors.add("unexpected item: $token");
    if (this._errorLimitReached) return false;
    // Discard token and continue.
    return true;
  }

  /// Handles when a specified error action has been reached.
  bool _errorAction(_Error action) {
    this._errors.add(action.error);
    if (this._errorLimitReached) return false;
    // Discard token and continue.
    return true;
  }

  /// Handles when a shift action has been reached.
  bool _shiftAction(_Shift action, Token token) {
    this._itemStack.add(token);
    this._stateStack.add(action.state);
    return true;
  }
  
  /// Handles when a reduce action has been reached.
  bool _reduceAction(_Reduce action, Token token) {
    // Pop the items off the stack for this action.
    // Also check that the items match the expected rule.
    int count = action.items.length;
    List<Object> items = new List<Object>();
    for (int i = count - 1; i >= 0; i--) {
      this._stateStack.removeLast();
      Object item = this._itemStack.removeLast();
      items.insert(0, item);
    
      String itemStr;
      if (item is TreeNode) itemStr = item.term;
      else itemStr = (item as Token).name;

      String match = action.items[i];
      if (match != itemStr)
        throw new Exception("the action, $action, couldn't reduce item $i, $itemStr");
    }

    // Create a new item with the items for this rule in it
    // and put it onto the stack.
    TreeNode node = new TreeNode(action.term, items);
    this._itemStack.add(node);

    // Use the state reduced back to and the new item to seek,
    // via the goto table, the next state to continue from.
    int curState = this._stateStack.last;
    while (true) {
      _Action action = this._table.readGoto(curState, node.term);
      if (action == null) break;
      else if (action is _Goto) curState = action.state;
      else throw new Exception("unexpected goto type: $action");
    }
    this._stateStack.add(curState);

    // Continue with parsing the current token.
    return this.add(token);
  }

  /// Handles when an accept has been reached.
  bool _acceptAction(_Accept action) {
    this._accepted = true;
    return true;
  }

  /// Inserts the next look ahead token into the parser.
  bool add(Token token) {
    if (this._accepted) {
      this._errors.add("unexpected token after end: $token");
      return false;
    }

    int curState = this._stateStack.last;
    
    print(">> state:  $curState");
    print("   token:  $token");

    _Action action = this._table.readShift(curState, token.name);
    if (action == null) return this._nullAction(token);

    print("   action: $action");
    print("   items:  ${this._itemStack}");
    print("   stack:  ${this._stateStack}");

    if (action is _Shift)  return this._shiftAction(action, token);
    if (action is _Reduce) return this._reduceAction(action, token);
    if (action is _Accept) return this._acceptAction(action);
    if (action is _Error)  return this._errorAction(action);
    throw new Exception("unexpected action type: $action");
  }
}
