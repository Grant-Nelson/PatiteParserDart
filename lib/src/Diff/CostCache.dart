part of Diff;

/// The levenshtein path builder used for diffing 
class _CostCache {
  
  /// The source comparable to create the path for.
  DiffComparable _comp;

  /// The container for the levenshtein costs.
  List<List<int>> _costs;

  /// Creates a new path builder.
  _CostCache(DiffComparable this._comp) {
    final int aLength = this._comp.aLength;
    final int bLength = this._comp.bLength;
    this._costs = new List<List<int>>.generate(aLength, (_) =>
      new List<int>.filled(bLength, -1));
  }
  
  /// Gets the cost at a path point.
  int getCost(int aIndex, int bIndex) {
    if (aIndex <= 0) return bIndex;
    if (bIndex <= 0) return aIndex;
    int cost = this._costs[aIndex-1][bIndex-1];
    if (cost < 0) cost = this.setCost(aIndex, bIndex);
    return cost;
  }

  /// Checks if the comparer is equal.
  bool isEqual(int aIndex, int bIndex) =>
    this._comp.equals(aIndex-1, bIndex-1);

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
    this._costs[aIndex-1][bIndex-1] = minCost;
    return minCost;
  }
}
