part of Diff;

/// The levenshtein/Hirschberg path builder used for diffing two comparable sources.
/// See https://en.wikipedia.org/wiki/Levenshtein_distance
/// And https://en.wikipedia.org/wiki/Hirschberg%27s_algorithm
class _Path {

  /// The source comparable to create the path for.
  Comparable _baseComp;

  /// The score vector at the front of the score calculation.
  List<int> _scoreFront;

  /// The score vector at the back of the score calculation.
  List<int> _scoreBack;

  /// The score vector to store off a result vector to.
  List<int> _scoreOther;

  /// Creates a new path builder.
  _Path(Comparable this._baseComp) {
    final int len = this._baseComp.bLength + 1;
    this._scoreFront = new List<int>.filled(len, 0, growable: false);
    this._scoreBack = new List<int>.filled(len, 0, growable: false);
    this._scoreOther = new List<int>.filled(len, 0, growable: false);
  }

  /// Swaps the front and back score vectors.
  void _swapScores() {
    List<int> temp = this._scoreFront;
    this._scoreFront = this._scoreBack;
    this._scoreBack = temp;
  }

  /// Swaps the back and other score vectors.
  void _storeScore() {
    List<int> temp = this._scoreBack;
    this._scoreBack = this._scoreOther;
    this._scoreOther = temp;
  }

  /// Gets the maximum value of the three given values.
  int _max(int a, int b, int c) => math.max(a, math.max(b, c));

  /// Calculate the Needleman-Wunsch score.
  /// At the end of this calculation the score is in the front vector.
  void _calculateScore(_Container comp) {
    final int aLen = comp.aLength;
    final int bLen = comp.bLength;

    this._scoreBack[0] = 0;
    for (int j = 1; j <= bLen; ++j) {
      this._scoreBack[j] = this._scoreBack[j-1] + comp.addCost(j-1);
    }

    for (int i = 1; i <= aLen; ++i) {
      this._scoreFront[0] = this._scoreBack[0] + comp.removeCost(i-1);
      for (int j = 1; j <= bLen; ++j) {
        this._scoreFront[j] = this._max(
          this._scoreBack[j-1]  + comp.substitionCost(i-1, j-1),
          this._scoreBack[j]    + comp.removeCost(i-1),
          this._scoreFront[j-1] + comp.addCost(j-1));
      }

      this._swapScores();
    }
  }

  /// Finds the pivot between the other score and the reverse of the back score.
  int _findPivot(int bLength) {
    int index = 0;
    int max = this._scoreOther[0] + this._scoreBack[bLength];
    for (int j = 1; j <= bLength; ++j) {
      int value = this._scoreOther[j] + this._scoreBack[bLength - j];
      if (value > max) {
        max = value;
        index = j;
      }
    }
    return index;
  }

  Iterable<Step> _aEdge(_Container comp) sync* {
    final int aLen = comp.aLength;
    final int bLen = comp.bLength;
    
    if (aLen <= 0) {
      if (bLen > 0)
        yield new Step(StepType.Added, bLen);
      return;
    }

    int split = -1;
    for (int j = 0; j < bLen; j++) {
      if (comp.equals(0, j)) {
        split = j;
        break;
      }
    }

    if (split < 0) {
      yield new Step(StepType.Removed, 1);
      yield new Step(StepType.Added, bLen);
    } else {
      if (split > 0)
        yield new Step(StepType.Added, split);
      yield new Step(StepType.Equal, 1);
      if (split < bLen-1)
        yield new Step(StepType.Added, bLen-split-1);
    }
  }

  Iterable<Step> _bEdge(_Container comp) sync* {
    final int aLen = comp.aLength;
    final int bLen = comp.bLength;
    
    if (bLen <= 0) {
      if (aLen > 0)
        yield new Step(StepType.Removed, aLen);
      return;
    }
    
    int split = -1;
    for (int i = 0; i < aLen; i++) {
      if (comp.equals(i, 0)) {
        split = i;
        break;
      }
    }

    if (split < 0) {
      yield new Step(StepType.Removed, aLen);
      yield new Step(StepType.Added, 1);
    } else {
      if (split > 0)
        yield new Step(StepType.Removed, split);
      yield new Step(StepType.Equal, 1);
      if (split < aLen-1)
        yield new Step(StepType.Removed, aLen-split-1);
    }
  }

  /// This performs the Hirschberg divide and concore and returns the path.
  Iterable<Step> _breakupPath(_Container comp, [String indent = ""]) sync* {
    final int aLen = comp.aLength;
    final int bLen = comp.bLength;
    print('$indent$comp');
    
    if (aLen <= 1) {
      yield* this._aEdge(comp);
      return;
    }
    
    if (bLen <= 1) {
      yield* this._bEdge(comp);
      return;
    }

    final int aMid = aLen~/2;
    this._calculateScore(comp.sub(0, aMid, 0, bLen));
    this._storeScore();
    this._calculateScore(comp.rev(aMid, aLen, 0, bLen));
    final int bMid = this._findPivot(bLen);

    yield* this._breakupPath(comp.sub(0, aMid, 0, bMid), indent+"|  ");
    yield* this._breakupPath(comp.sub(aMid, aLen, bMid, bLen), indent+"|  ");
  }

  /// Iterates through the diff path for the comparer this path was setup for.
  Iterable<Step> iteratePath() sync* {
    _Container cont = new _Container.Full(this._baseComp);
    yield* this._breakupPath(cont);

    /*
    int removedCount = 0;
    int addedCount = 0;
    int equalCount = 0;

    _Container cont = new _Container.Full(this._baseComp);
    for (Step step in this._breakupPath(cont)) {
      switch(step.type) {
        case StepType.Added:
          if (equalCount > 0) {
            yield new Step(StepType.Equal, equalCount);
            equalCount = 0;
          }
          addedCount += step.count;
          break;
        case StepType.Removed:
          if (equalCount > 0) {
            yield new Step(StepType.Equal, equalCount);
            equalCount = 0;
          }
          removedCount += step.count;
          break;
        case StepType.Equal:
          if (removedCount > 0) {
            yield new Step(StepType.Removed, removedCount);
            removedCount = 0;
          }
          if (addedCount > 0) {
            yield new Step(StepType.Added, addedCount);
            addedCount = 0;
          }
          equalCount += step.count;
          break;
      }
    }
    if (removedCount > 0) {
      yield new Step(StepType.Removed, removedCount);
      removedCount = 0;
    }
    if (addedCount > 0) {
      yield new Step(StepType.Added, addedCount);
      addedCount = 0;
    }
    if (equalCount > 0) {
      yield new Step(StepType.Equal, equalCount);
      equalCount = 0;
    }
    */
  }
}
