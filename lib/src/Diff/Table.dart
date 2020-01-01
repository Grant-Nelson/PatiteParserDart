part of Diff;

/// A table for storing the data for the diff.
class _Table {
  List<List<int>> _values;

  /// Creates a new table for storing data.
  _Table(int width, int height, int defaultValue) {
    this._values = new List<List<int>>.generate(width, (_) =>
      new List<int>.filled(height, defaultValue));
  }

  /// This gets the one based indexed value.
  int getValue(int i, int j) => this._values[i-1][j-1];

  /// This sets the one based indexed value.
  void setValue(int i, int j, int value) => this._values[i-1][j-1] = value;
}
