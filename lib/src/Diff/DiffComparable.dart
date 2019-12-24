part of Diff;

/// A simple interface for generic difference determination.
abstract class DiffComparable {
  
	// The length of the first list being compared.
  int get aLength;
  
	// The length of the secton list being compared.
  int get bLength;
  
	// Determines if the entries in the two given indices are equal.
  bool equals(aIndex, bIndex);
}

/// A string list comparabler to find the difference between them.
class _StringListComparable implements DiffComparable {
  final List<String> _aSource;
  final List<String> _bSource;

  /// Creates a new diff comparable for the two given strings.
  _StringListComparable(this._aSource, this._bSource);
  
	// The length of the first list being compared.
  int get aLength => this._aSource.length;
  
	// The length of the secton list being compared.
  int get bLength => this._bSource.length;
  
	// Determines if the entries in the two given indices are equal.
  bool equals(aIndex, bIndex) => this._aSource[aIndex] == this._bSource[bIndex];
}
