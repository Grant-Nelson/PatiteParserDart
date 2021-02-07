part of Diff;

/// A simple interface for generic difference determination.
abstract class Comparable {

	/// The length of the first list being compared.
  int get aLength;

	/// The length of the second list being compared.
  int get bLength;

	/// Determines if the entries in the two given indices are equal.
  bool equals(int aIndex, int bIndex);

  /// Gives the cost to remove A at the given index.
  int removeCost(int aIndex) => -2;

  /// Gives the cost to add B at the given index.
  int addCost(int bIndex) => -2;

  /// Gives the substition cost for replacing A with B at the given indices.
  int substitionCost(int aIndex, int bIndex) =>
    this.equals(aIndex, bIndex)? 2: -1;

  /// Gets a generic debug string for this comparable.
  @override
  String toString() => 'Comparable($aLength, $bLength)';
}

/// A string list comparable to find the difference between them.
class _StringsComparable extends Comparable {
  final List<String> _aSource;
  final List<String> _bSource;

  /// Creates a new diff comparable for the two given strings.
  _StringsComparable(this._aSource, this._bSource);

	/// The length of the first list being compared.
  int get aLength => this._aSource.length;

	/// The length of the section list being compared.
  int get bLength => this._bSource.length;

	/// Determines if the entries in the two given indices are equal.
  bool equals(int aIndex, int bIndex) =>
    this._aSource[aIndex] == this._bSource[bIndex];
  
  /// Gets a generic debug string for this comparable.
  @override
  String toString() => 'Comparable(${_aSource.join('|')}, ${_bSource.join('|')})';
}
