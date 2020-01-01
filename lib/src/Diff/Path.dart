part of Diff;

/// The results from a traversal through the cost matrix.
class _TraverseResult {
  /// The cost to take this path.
  int cost;

  /// The path through the cost matrix.
  List<StepType> path;

  /// Creates a new traverse result.
  _TraverseResult(this.cost, this.path);
}

/// The levenshtein path builder used for diffing 
class _Path {
  static const int NotSet     = -1;
  static const int MoveUp     =  1;
  static const int MoveLeft   =  2;
  static const int MoveUpLeft =  3;
  static const int MoveEqual  =  4;
  
  /// The source comparable to create the path for.
  DiffComparable _comp;

  /// The container for the levenshtein costs.
  _Table _costs;

  /// The container for the levenshtein costs.
  _Table _moves;

  _Table _costSum;

  /// Creates a new path builder.
  _Path(DiffComparable this._comp) {
    final int aLen = this._comp.aLength;
    final int bLen = this._comp.bLength;
    this._costs   = new _Table(aLen, bLen, -1);
    this._moves   = new _Table(aLen, bLen, NotSet);
    this._costSum = new _Table(aLen, bLen, 0);
  }

  /// Path gets the difference path for the two given items.
  /// Gets the path with the lowest cost.
  /// See https://en.wikipedia.org/wiki/Levenshtein_distance
  List<StepGroup> createPath() {
    List<StepGroup> result = new List<StepGroup>();
    this._setMovement(this._comp.aLength, this._comp.bLength);

    int addRun = 0;
    Function() insertAdd = () {
      if (addRun > 0) {
        result.add(new StepGroup(StepType.Added, addRun));    
        addRun = 0;
      }
    };
    
    int removeRun = 0;
    Function() insertRemove = () {
      if (removeRun > 0) {
        result.add(new StepGroup(StepType.Removed, removeRun));    
        removeRun = 0;
      }
    };
    
    int equalRun = 0;
    Function() insertEqual = () {
      if (equalRun > 0) {
        result.add(new StepGroup(StepType.Equal, equalRun));    
        equalRun = 0;
      }
    };

    for (StepType step in this.traverseBackwards()) {
      switch (step) {
        case StepType.Equal:
          insertAdd();
          insertRemove();
          equalRun++;
          break;
        case StepType.Added:
          insertEqual();
          addRun++;
          break;
        case StepType.Removed:
          insertEqual();
          removeRun++;
          break;
      }
    }
  
    insertAdd();
    insertRemove();
    insertEqual();
    return new List<StepGroup>.from(result.reversed);
  }

  /// Checks if the comparer is equal.
  bool isEqual(int aIndex, int bIndex) =>
    this._comp.equals(aIndex-1, bIndex-1);
  
  /// Gets the cost at a path point.
  int getCost(int aIndex, int bIndex) {
    if (aIndex <= 0) return bIndex;
    if (bIndex <= 0) return aIndex;
    int cost = this._costs.getValue(aIndex, bIndex);
    if (cost < 0) cost = this.setCost(aIndex, bIndex);
    return cost;
  }

  /// Sets the cost of a path point.
  int setCost(int aIndex, int bIndex) {
    // get the minimum of entry skip entry from a, skip entry from b, and skip entry from both
    int costA = this.getCost(aIndex-1, bIndex);
    int costB = this.getCost(aIndex,   bIndex-1);
    int minCost = math.min(costA, costB);
    
    int costC = this.getCost(aIndex-1, bIndex-1);
    if (costC <= minCost) {
      // skips any cost for equal values in the inputs
      int skipCost = this.isEqual(aIndex, bIndex)? -1: 0;
      minCost = costC + skipCost;
    }

    // calculate the minimum path cost and set cost
    minCost++;
    this._costs.setValue(aIndex, bIndex, minCost);
    return minCost;
  }

  int _setMovement(int aIndex, int bIndex) {
    // base case when one of the inputs are empty
    if (aIndex <= 0) return bIndex;
    if (bIndex <= 0) return aIndex;

    // Check if this subpath has already been solved.
    if (this._moves.getValue(aIndex, bIndex) != NotSet)
      return this._costSum.getValue(aIndex, bIndex);

	  // get the minimum of entry skip entry from a, skip entry from b, and skip entry from both
    int costA = this.getCost(aIndex-1, bIndex);
    int costB = this.getCost(aIndex,   bIndex-1);
    int costC = this.getCost(aIndex-1, bIndex-1);
    int minCost = math.min(math.min(costA, costB), costC);
    
    // calculate the minimum path cost and set movements
    int minPathCost = minCost + 2;
    int minMove = NotSet;

    if (costA <= minCost) {
      // costA is minimum
      int cost = this._setMovement(aIndex-1, bIndex) + 1;
      if (cost < minPathCost) {
        minPathCost = cost;
        minMove = MoveLeft;
      }
    }

    if (costB <= minCost) {
      // costB is minimum
      int cost = this._setMovement(aIndex, bIndex-1) + 1;
      if (cost < minPathCost) {
        minPathCost = cost;
        minMove = MoveUp;
      }
    }

    if (costC <= minCost) {
      int cost = this._setMovement(aIndex-1, bIndex-1);
      if (this.isEqual(aIndex, bIndex)) {
        if (cost < minPathCost) {
          minPathCost = cost;
          minMove = MoveEqual;
        }
      } else {
        cost++;
        if (cost < minPathCost) {
          minPathCost = cost;
          minMove = MoveUpLeft;
        }
      }
    }

    this._moves.setValue(aIndex, bIndex, minMove);
    this._costSum.setValue(aIndex, bIndex, minPathCost);
    return minPathCost;
  }
  
  Iterable<StepType> traverseBackwards() sync* {
    int aIndex = this._comp.aLength;
    int bIndex = this._comp.bLength;
    while (true) {
      if (aIndex <= 0) {
        for (int i = 0; i < bIndex; i++)
          yield StepType.Added;
        return;
      }

      if (bIndex <= 0) {
        for (int i = 0; i < aIndex; i++)
          yield StepType.Removed;
        return;
      }

      switch (this._moves.getValue(aIndex, bIndex)) {
        case MoveLeft:
          aIndex--;
          yield StepType.Removed;
          break;
        case MoveUp:
          bIndex--;
          yield StepType.Added;
          break;
        case MoveEqual:
          aIndex--;
          bIndex--;
          yield StepType.Equal;
          break;
        case MoveUpLeft:
          aIndex--;
          bIndex--;
          yield StepType.Added;
          yield StepType.Removed;
          break;
        case NotSet:
          throw new Exception('Hit not set at ($aIndex, $bIndex).');
      }
    }
  }
}
