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

  /// Gets the string for debugging this table.
  String toString() {
    List<List<String>> grid = new List<List<String>>();

    // Add all the data into the table...
    int rowCount = this._values.length;
    int columnCount = this._values[0].length;
    for (int j = 0; j < columnCount; j++) {
      List<String> values = new List<String>();
      for (int i = 0; i < rowCount; i++) {
        values.add("${this._values[i][j]}");
      }
      grid.add(values);
    }
    
    // Make all the items in a column the same width...\
    for (int j = 0; j < columnCount; j++) {
      int maxWidth = 0;
      for (int i = 0; i < rowCount; i++)
        maxWidth = math.max(maxWidth, grid[i][j].length);
      for (int i = 0; i < rowCount; i++)
        grid[i][j] = grid[i][j].padLeft(maxWidth);
    }

    // Write the table...
    StringBuffer buf = new StringBuffer();
    for (int i = 0; i < rowCount; i++) {
      if (i > 0) buf.writeln();
      for (int j = 0; j < columnCount; j++) {
        if (j > 0) buf.write("|");
        buf.write(grid[i][j]);
      }
    }
    return buf.toString();
  }
}
