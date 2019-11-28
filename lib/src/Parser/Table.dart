part of PatiteParserDart.Parser;

class _Table {
  Set<int> _rows;
  Set<Object> _columns;
  Map<int, Map<Object, _Action>> _data;

  _Table() {
    this._rows    = new Set<int>();
    this._columns = new Set<Object>();
    this._data    = new Map<int, Map<Object, _Action>>();
  }

  _Action read(int row, Object column) {
    if (this._data.containsKey(row)) {
      Map<Object, _Action> rowData = this._data[row];
      if (rowData.containsKey(column))
        return rowData[column];
    }
    return null;
  }
  
  void write(int row, Object column, _Action value) {
    Map<Object, _Action> rowData;
    if (this._data.containsKey(row))
      rowData = this._data[row];
    else {
      rowData = new Map<Object, _Action>();
      this._data[row] = rowData;
      this._rows.add(row);
    }
    if (!rowData.containsKey(column))
      this._columns.add(column);
    rowData[column] = value;
  }

  String toString() {
    List<int> rows = this._rows.toList();
    List<Object> columns = this._columns.toList();

    List<List<String>> grid = new List<List<String>>();
    List<String> columnLabels = new List<String>()
      ..add(""); // blank space for row labels
    for (int j = 0; j < columns.length; j++)
      columnLabels.add(columns[j].toString());
    grid.add(columnLabels);

    for (int i = 0; i < rows.length; i++) {
      List<String> values = new List<String>()
        ..add(rows[i].toString());
      for (int j = 0; j < columns.length; j++) {
        _Action action = this.read(rows[i], columns[j]);
        if (action == null) values.add("-");
        else values.add(action.toString());
      }
      grid.add(values);
    }
    
    for (int j = 0; j < columns.length+1; j++) {
      int maxWidth = 0;
      for (int i = 0; i < rows.length+1; i++)
        maxWidth = math.max(maxWidth, grid[i][j].length);
      for (int i = 0; i < rows.length+1; i++)
        grid[i][j] = grid[i][j].padRight(maxWidth);
    }

    StringBuffer buf = new StringBuffer();
    for (int i = 0; i < rows.length+1; i++) {
      if (i > 0) buf.writeln();
      for (int j = 0; j < columns.length+1; j++) {
        if (j > 0) buf.write("|");
        buf.write(grid[i][j]);
      }
    }
    return buf.toString();
  }
}
