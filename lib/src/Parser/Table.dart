part of PatiteParserDart.Parser;

class _Table {
  Set<Object> _columns;
  List<Map<Object, _Action>> _data;

  /// Creates a new parse table.
  _Table() {
    this._columns = new Set<Object>();
    this._data    = new List<Map<Object, _Action>>();
  }

  /// Reads a value from the table,
  /// returns null if no value set.
  _Action read(int row, Object column) {
    if ((row >= 0) && (row < this._data.length)) {
      Map<Object, _Action> rowData = this._data[row];
      if (rowData.containsKey(column))
        return rowData[column];
    }
    return null;
  }
  
  /// Writes a new value to the table.
  void write(int row, Object column, _Action value) {
    if (row < 0) throw new ArgumentError("row must be zero or more");

    Map<Object, _Action> rowData;
    if (row < this._data.length)
      rowData = this._data[row];
    else {
      while (row >= this._data.length) {
        rowData = new Map<Object, _Action>();
        this._data.add(rowData);
      }
    }

    if (!rowData.containsKey(column))
      this._columns.add(column);
    rowData[column] = value;
  }

  /// Compares two items for sorting outputting.
  int itemCompare(Object a, Object b) {
    if (a is Term) {
      if (b is! Term) return 1;
    } else if (b is Term) return -1;
    return a.toString().compareTo(b.toString());
  }

  /// Gets a string output of the table for debugging.
  String toString() {
    List<Object> columns = this._columns.toList();
    columns.sort(this.itemCompare);

    List<List<String>> grid = new List<List<String>>();
    List<String> columnLabels = new List<String>()
      ..add(""); // blank space for row labels
    for (int j = 0; j < columns.length; j++)
      columnLabels.add(columns[j].toString());
    grid.add(columnLabels);

    for (int row = 0; row < this._data.length; row++) {
      List<String> values = new List<String>()..add("$row");
      for (int i = 0; i < columns.length; i++) {
        _Action action = this.read(row, columns[i]);
        if (action == null) values.add("-");
        else values.add(action.toString());
      }
      grid.add(values);
    }
    
    for (int j = 0; j < columns.length+1; j++) {
      int maxWidth = 0;
      for (int i = 0; i < this._data.length+1; i++)
        maxWidth = math.max(maxWidth, grid[i][j].length);
      for (int i = 0; i < this._data.length+1; i++)
        grid[i][j] = grid[i][j].padRight(maxWidth);
    }

    StringBuffer buf = new StringBuffer();
    for (int i = 0; i < this._data.length+1; i++) {
      if (i > 0) buf.writeln();
      for (int j = 0; j < columns.length+1; j++) {
        if (j > 0) buf.write("|");
        buf.write(grid[i][j]);
      }
    }
    return buf.toString();
  }
}
