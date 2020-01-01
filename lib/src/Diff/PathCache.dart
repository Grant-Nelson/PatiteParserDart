part of Diff;

/*
/// The levenshtein path builder used for diffing 
class _PathCache {

  static const int NotSet     = -1;
  static const int MoveUp     =  1;
  static const int MoveLeft   =  2;
  static const int MoveUpLeft =  3;

  /// The source comparable to create the path for.
  _CostCache _costs;

  /// The container for the levenshtein costs.
  List<List<int>> _moves;

  /// Creates a new path builder.
  _PathCache(DiffComparable comp) {
    this._costs = new _CostCache(comp);
    this._moves = new List<List<int>>.generate(comp.aLength, (_) =>
      new List<int>.filled(comp.bLength, -1));
  }

  /// Gets the path with the lowest cost.
  /// See https://en.wikipedia.org/wiki/Levenshtein_distance
  _TraverseResult traverseLevenshteinDistance(int aIndex, int bIndex) {
    // base case when one of the inputs are empty
    if (aIndex <= 0) return new _TraverseResult(bIndex, new List<StepType>.filled(bIndex, StepType.Added, growable: true));
    if (bIndex <= 0) return new _TraverseResult(aIndex, new List<StepType>.filled(aIndex, StepType.Removed, growable: true));

	  // get the minimum of entry skip entry from a, skip entry from b, and skip entry from both
    int costA = this._costs.getCost(aIndex-1, bIndex);
    int costB = this._costs.getCost(aIndex,   bIndex-1);
    int costC = this._costs.getCost(aIndex-1, bIndex-1);
    int minCost = math.min(math.min(costA, costB), costC);
    
    // calculate the minimum path cost and set cost
    int minPathCost = minCost + 2;
    List<StepType> minPath = new List<StepType>();

    if (costA <= minCost) {
      // costA is minimum
      _TraverseResult result = traverseLevenshteinDistance(aIndex-1, bIndex);
      int cost = result.cost + 1;
      if (cost < minPathCost) {
        minPathCost = cost;
        minPath = result.path..add(StepType.Removed);
      }
    }

    if (costB <= minCost) {
      // costB is minimum
      _TraverseResult result = traverseLevenshteinDistance(aIndex, bIndex-1);
      int cost = result.cost + 1;
      if (cost < minPathCost) {
        minPathCost = cost;
        minPath = result.path..add(StepType.Added);
      }
    }

    if (costC <= minCost) {
      if (this._comp.equals(aIndex-1, bIndex-1)) {
        // costC is minimum and entries equal
        _TraverseResult result = traverseLevenshteinDistance(aIndex-1, bIndex-1);
        // Do not add to cost since the values are equal
        if (result.cost < minPathCost) {
          minPathCost = result.cost;
          minPath = result.path..add(StepType.Equal);
        }
      } else {
        // costC is minimum and entries different
        _TraverseResult result = traverseLevenshteinDistance(aIndex-1, bIndex-1);
        int cost = result.cost + 1;
        if (cost < minPathCost) {
          minPathCost = cost;
          minPath = result.path..add(StepType.Removed)..add(StepType.Added);
        }
      }
    }

    return new _TraverseResult(minPathCost, minPath);
  }
}
*/
