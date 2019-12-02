part of PatiteParserDart.Parser;

/// The runner performs a parse step by step as tokens are added.
class _Runner {
  final _Table _table;
  final int _errorCap;
  List<String> _errors;
  List<Object> _itemStack;
  List<int> _stateStack;
  bool _accepted;


  _Runner(this._table, this._errorCap) {
    this._errors = new List<String>();
    this._itemStack = [];
    this._stateStack = [0];
    this._accepted = false;
  }

  Result get result {
    if (this._errors.length > 0)
      return new Result(List.unmodifiable(this._errors), null);
    if (!this._accepted) {
      this._errors.add("unexpected end of input");
      return new Result(List.unmodifiable(this._errors), null);
    }
    return new Result(null, this._itemStack[0] as TreeNode);
  }

  bool get _errorLimitReached =>
    (this._errorCap > 0) && (this._errors.length >= this._errorCap);

  /// Handles when a default error state has been reached.
  bool _nullAction(Token token) {
    this._errors.add("unexpected item: $token");
    if (this._errorLimitReached) return false;
    // Discard token and continue.
    return true;
  }

  bool _errorAction(_Error action) {
    this._errors.add(action.error);
    if (this._errorLimitReached) return false;
    // Discard token and continue.
    return true;
  }

  bool _shiftAction(_Shift action, Token token) {
    this._itemStack.add(token);
    this._stateStack.add(action.state);
    return true;
  }
  
  bool _reduceAction(_Reduce action, Token token) {
    int count = action.items.length;
    List<Object> items = new List<Object>();
    for (int i = 0; i < count; i++) {
      this._stateStack.removeLast();
      items.insert(0, this._itemStack.removeLast());
    }

    for (int i = 0; i < count; i++) {
      String match = action.items[i];
      Object item = items[i];

      String itemStr;
      if (item is TreeNode) itemStr = item.term;
      else itemStr = (items[i] as Token).name;

      if (match != itemStr)
        throw new Exception("the action, $action, couldn't reduce item $i, $itemStr");
    }

    TreeNode node = new TreeNode(action.term, items);
    this._itemStack.add(node);

    int curState = this._stateStack.last;
    while (true) {
      _Action action = this._table.readGoto(curState, node.term);
      if (action == null) break;
      else if (action is _Goto) curState = action.state;
      else throw new Exception("unexpected goto type: $action");
    }

    this._stateStack.add(curState);
    return this.add(token);
  }

  bool _acceptAction(_Accept action) {
    this._accepted = true;
    return true;
  }

  bool add(Token token) {
    if (this._accepted) {
      this._errors.add("unexpected token after end: $token");
      return false;
    }

    int curState = this._stateStack.last;
    _Action action = this._table.readShift(curState, token.name);
    if (action == null)    return this._nullAction(token);
    if (action is _Shift)  return this._shiftAction(action, token);
    if (action is _Reduce) return this._reduceAction(action, token);
    if (action is _Accept) return this._acceptAction(action);
    if (action is _Error)  return this._errorAction(action);
    throw new Exception("unexpected action type: $action");
  }
}
