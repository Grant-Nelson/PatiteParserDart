part of PatiteParserDart.Simple;

/// Deserializes a previous serialized string of data.
class Deserializer {
  int _index;
  String _data;

  /// Creates a new deserializer with the given data.
  Deserializer(String data) {
    this._index = 0;
    this._data = data;
  }
  
  /// Gets the serialized string of data.
  String toString() =>
    this._data.substring(0, this._index) +
      "•" + this._data.substring(this._index);

  /// Indicates if the deserializer has reached the end.
  bool get hasMore => this._index < this._data.length;

  /// Checks if the end of the data has been reached.
  void _eofException() {
    if (!this.hasMore)
      throw new Exception("Unexpected end of serialized data");
  }

  /// Reads a boolean from the data.
  bool readBool() {
    this._eofException();
    String c = this._data[this._index];
    this._index++;
    if (c == "T") return true;
    if (c == "F") return false;
    throw new Exception("Expected T or F but got $c");
  }

  /// Reads an integer from the data.
  int readInt() {
    this._eofException();
    int start = this._index;
    for (; this._index < this._data.length; this._index++) {
      if (this._data[this._index] == " ") break;
    }
    this._index++;
    String value = this._data.substring(start, this._index-1);
    return int.parse(value);
  }

  /// Reads a string from the data.
  String readStr() {
    int length = this.readInt();
    int start = this._index;
    this._index += length;
    return this._data.substring(start, start+length);
  }

  /// Reads a serialization from the data.
  Deserializer readSer() {
    String data = this.readStr();
    return new Deserializer(data);
  }
  
  /// Reads a list of integers from the data.
  List<int> readIntList() {
    int count = this.readInt();
    List<int> list = new List<int>();
    for (int i = 0; i < count; i++)
      list.add(this.readInt());
    return list;
  }
  
  /// Reads a list of strings from the data.
  List<String> readStrList() {
    int count = this.readInt();
    List<String> list = new List<String>();
    for (int i = 0; i < count; i++)
      list.add(this.readStr());
    return list;
  }

  /// Reads a map of strings to strings from the data.
  Map<String, String> readStringStringMap() {
    Map<String, String> map = new Map<String, String>();
    int count = this.readInt();
    for (int i = 0; i < count; i++) {
      String key = this.readStr();
      String value = this.readStr();
      map[key] = value;
    }
    return map;
  }
}
