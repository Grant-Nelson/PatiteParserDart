part of Diff;

/// A subset string list comparable to find the difference between them.
class _Container {
  final Comparable _comp;
  final int _aOffset;
  final int _aLength;
  final int _bOffset;
  final int _bLength;
  final bool _reverse;

  _Container(this._comp, this._aOffset, this._aLength, this._bOffset, this._bLength, this._reverse) {
    //print("_Container($this): (${_comp.aLength}, ${_comp.bLength})");
    if ((this._aOffset+this._aLength > this._comp.aLength) ||
      (this._bOffset+this._bLength > this._comp.bLength))
      throw new Exception("Out-of-bounds");
  }

  factory _Container.Full(Comparable comp) =>
    new _Container(comp, 0, comp.aLength, 0, comp.bLength, false);

  _Container sub(int aLow, int aHigh, int bLow, int bHigh, [bool reverse = false]) {
    //print("Sub => $this [$aLow..$aHigh), [$bLow..$bHigh), $reverse");
    int a2Low = this._aAdjust(aLow), a2High = this._aAdjust(aHigh);
    int b2Low = this._bAdjust(bLow), b2High = this._bAdjust(bHigh);
    if (this._reverse)
      return new _Container(this._comp, a2High, a2Low-a2High, b2High, b2Low-b2High, !reverse);
    return new _Container(this._comp, a2Low, a2High-a2Low, b2Low, b2High-b2Low, reverse);
  }
  
  _Container rev(int aLow, int aHigh, int bLow, int bHigh) =>
    sub(aLow, aHigh, bLow, bHigh, true);

	/// The length of the first list being compared.
  int get aLength => this._aLength;

	/// The length of the section list being compared.
  int get bLength => this._bLength;

  /// Gets the A index adjusted by the container's condition.
  int _aAdjust(int aIndex) { 
    int adj = (this._reverse) ?
      (this._aLength-1-aIndex+this._aOffset) :
      (aIndex+this._aOffset);
    //print("   aIndex: $aIndex => $adj [$_aOffset..${_aOffset+_aLength}) ${_comp.aLength}");
    return adj;
  }

  /// Gets the B index adjusted by the container's condition.
  int _bAdjust(int bIndex) {
    int adj = (this._reverse) ?
      (this._bLength-1-bIndex+this._bOffset) :
      (bIndex+this._bOffset);
    //print("   bIndex: $bIndex => $adj [$_bOffset..${_bOffset+_bLength}) ${_comp.bLength}");
    return adj;
  }

	/// Determines if the entries in the two given indices are equal.
  bool equals(int aIndex, int bIndex) =>
    this._comp.equals(this._aAdjust(aIndex), this._bAdjust(bIndex));

  /// Gives the cost to remove A at the given index.
  int removeCost(int aIndex) =>
    this._comp.removeCost(this._aAdjust(aIndex));

  /// Gives the cost to add B at the given index.
  int addCost(int bIndex) =>
    this._comp.addCost(this._bAdjust(bIndex));

  /// Gives the substition cost for replacing A with B at the given indices.
  int substitionCost(int aIndex, int bIndex) =>
    this._comp.substitionCost(this._aAdjust(aIndex), this._bAdjust(bIndex));

  /// Gets the debug string for this container.
  @override
  String toString() {
    String aValues = '', bValues = '';
    if (this._comp is _StringsComparable) {
      _StringsComparable cmp = this._comp as _StringsComparable;

      List<String> aParts = new List<String>();
      for (int i = 0; i < this._aLength; ++i)
        aParts.add(cmp._aSource[this._aAdjust(i)]);
      aValues = ' [${aParts.join("|")}]';

      List<String> bParts = new List<String>();
      for (int j = 0; j < this._bLength; ++j) 
        bParts.add(cmp._bSource[this._bAdjust(j)]);
      bValues = ' [${bParts.join("|")}]';
    }

    return '([$_aOffset..${_aOffset+_aLength}) $_aLength$aValues'+
      ', [$_bOffset..${_bOffset+_bLength}) $_bLength$bValues'+
      ', $_reverse)';
  }
}
