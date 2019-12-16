part of PatiteParserDart.Parser;

/// This is a table to define the actions to take when
/// a new token is added to the parse.
class _Table {
  Set<String> _shiftColumns;
  Set<String> _gotoColumns;
  List<Map<String, _Action>> _shiftTable;
  List<Map<String, _Action>> _gotoTable;

  /// Creates a new parse table.
  _Table() {
    this._shiftColumns = new Set<String>();
    this._gotoColumns  = new Set<String>();
    this._shiftTable   = new List<Map<String, _Action>>();
    this._gotoTable    = new List<Map<String, _Action>>();
  }
  
  /// Deserializes the given serialized data into this table.
  factory _Table.deserialize(Simple.Deserializer data) {
    _Table table = new _Table();
    table._shiftColumns = new Set<String>.from(data.readStrList());
    table._gotoColumns = new Set<String>.from(data.readStrList());

    int shiftCount = data.readInt();
    for (int i = 0; i < shiftCount; i++) {
      Map<String, _Action> shiftMap = new Map<String, _Action>();
      int keysCount = data.readInt();
      for (int j = 0; j < keysCount; j++) {
        String key = data.readStr();
        _Action action = table._deserializeAction(data);
        shiftMap[key] = action;
      }
      table._shiftTable.add(shiftMap);
    }

    int gotoCount = data.readInt();
    for (int i = 0; i < gotoCount; i++) {
      Map<String, _Action> gotoMap = new Map<String, _Action>();
      int keysCount = data.readInt();
      for (int j = 0; j < keysCount; j++) {
        String key = data.readStr();
        _Action action = table._deserializeAction(data);
        gotoMap[key] = action;
      }
      table._shiftTable.add(gotoMap);
    }

    return table;
  }

  /// Creates an action from the given data. 
  _Action _deserializeAction(Simple.Deserializer data) {
    switch (data.readInt()) {
      case 1: return new _Shift(data.readInt());
      case 2: return new _Goto(data.readInt());
      case 3: return new _Reduce(data.readStr(), data.readStrList());
      case 4: return new _Accept();
      case 5: return new _Error(data.readStr());
    }
    return null;
  }

  /// Serializes the table.
  Simple.Serializer serialize() {
    Simple.Serializer data = new Simple.Serializer();
    data.writeStrList(this._shiftColumns.toList());
    data.writeStrList(this._gotoColumns.toList());

    data.writeInt(this._shiftTable.length);
    for (Map<String, _Action> shiftMap in this._shiftTable) {
      data.writeInt(shiftMap.keys.length);
      for (String key in shiftMap.keys) {
        data.writeStr(key);
        this._serializeAction(data, shiftMap[key]);
      }
    }
    
    data.writeInt(this._gotoTable.length);
    for (Map<String, _Action> gotoMap in this._gotoTable) {
      data.writeInt(gotoMap.keys.length);
      for (String key in gotoMap.keys) {
        data.writeStr(key);
        this._serializeAction(data, gotoMap[key]);
      }
    }

    return data;
  }

  /// Sets up the data for serializing an action. 
  void _serializeAction(Simple.Serializer data, _Action action) {
    if (action is _Shift) {
      data.writeInt(1);
      data.writeInt(action.state);
    } else if (action is _Goto) {
      data.writeInt(2);
      data.writeInt(action.state);
    } else if (action is _Reduce) {
      data.writeInt(3);
      data.writeStr(action.term);
      data.writeStrList(action.items);
    } else if (action is _Accept) {
      data.writeInt(4);
    } else if (action is _Error) {
      data.writeInt(5);
      data.writeStr(action.error);
    }
  }

  /// Reads an action from the table,
  /// returns null if no action set.
  _Action _read(int row, String column, List<Map<String, _Action>> table) {
    if ((row >= 0) && (row < table.length)) {
      Map<String, _Action> rowData = table[row];
      if (rowData.containsKey(column))
        return rowData[column];
    }
    return null;
  }

  /// Reads a shift action from the table,
  /// returns null if no action set.
  _Action readShift(int row, String column) =>
    this._read(row, column, this._shiftTable);

  /// Reads a goto action from the table,
  /// returns null if no action set.
  _Action readGoto(int row, String column) =>
    this._read(row, column, this._gotoTable);
    
  
  /// Writes a new action to the table.
  void _write(int row, String column, _Action value,
    Set<String> columns, List<Map<String, _Action>> table) {
    if (row < 0) throw new ArgumentError("row must be zero or more");

    Map<String, _Action> rowData;
    if (row < table.length)
      rowData = table[row];
    else {
      while (row >= table.length) {
        rowData = new Map<String, _Action>();
        table.add(rowData);
      }
    }

    if (!rowData.containsKey(column))
      columns.add(column);
    rowData[column] = value;
  }
  
  /// Writes a new shift action to the table.
  void writeShift(int row, String column, _Action value) =>
    this._write(row, column, value, this._shiftColumns, this._shiftTable);
  
  /// Writes a new goto action to the table.
  void writeGoto(int row, String column, _Action value) =>
    this._write(row, column, value, this._gotoColumns, this._gotoTable);

  /// Gets a string output of the table for debugging.
  String toString() {
    List<String> shiftColumns = this._shiftColumns.toList();
    List<String> gotoColumns = this._gotoColumns.toList();
    shiftColumns.sort();
    gotoColumns.sort();

    List<List<String>> grid = new List<List<String>>();
    List<String> columnLabels = new List<String>()
      ..add(""); // blank space for row labels
    for (int j = 0; j < shiftColumns.length; j++)
      columnLabels.add(shiftColumns[j].toString());
    for (int j = 0; j < gotoColumns.length; j++)
      columnLabels.add(gotoColumns[j].toString());
    grid.add(columnLabels);

    for (int row = 0; row < shiftColumns.length; row++) {
      List<String> values = new List<String>()..add("$row");
      for (int i = 0; i < shiftColumns.length; i++) {
        _Action action = this.readShift(row, shiftColumns[i]);
        if (action == null) values.add("-");
        else values.add(action.toString());
      }
      for (int i = 0; i < gotoColumns.length; i++) {
        _Action action = this.readGoto(row, gotoColumns[i]);
        if (action == null) values.add("-");
        else values.add(action.toString());
      }
      grid.add(values);
    }
    
    int colCount = shiftColumns.length + gotoColumns.length + 1;
    int rowCount = grid.length;
    for (int j = 0; j < colCount; j++) {
      int maxWidth = 0;
      for (int i = 0; i < rowCount; i++)
        maxWidth = math.max(maxWidth, grid[i][j].length);
      for (int i = 0; i < rowCount; i++)
        grid[i][j] = grid[i][j].padRight(maxWidth);
    }

    StringBuffer buf = new StringBuffer();
    for (int i = 0; i < rowCount; i++) {
      if (i > 0) buf.writeln();
      for (int j = 0; j < colCount; j++) {
        if (j > 0) buf.write("|");
        buf.write(grid[i][j]);
      }
    }
    return buf.toString();
  }
}
