part of PetiteParserDart.Simple;

/// This is a simple serializer designed for fast serialization and deserialization.
class Serializer {
  StringBuffer _data;

  /// Creates a new serializer.
  Serializer() {
    this._data = new StringBuffer();
  }

  /// Gets the serialized string of data.
  String toString() => this._data.toString();

  /// Writes a boolean to the data.
  void writeBool(bool value) =>
    this._data.write(value? "T": "F");

  /// Writes an integer to the data.
  void writeInt(int value) =>
    this._data.write("$value ");

  /// Writes a string to the data.
  void writeStr(String value) =>
    this._data.write("${value.length} $value");

  /// Writes another serializer to the data.
  void writeSer(Serializer value) =>
    this.writeStr(value._data.toString());

  /// Writes a list of integers to the data.
  void writeIntList(List<int> value) {
    this.writeInt(value.length);
    for (int intVal in value)
      this.writeInt(intVal);
  }

  /// Writes a list of strings to the data.
  void writeStrList(List<String> value) {
    this.writeInt(value.length);
    for (String strVal in value)
      this.writeStr(strVal);
  }

  /// Writes a map of strings to strings to the data.
  void writeStringStringMap(Map<String, String> value) {
    this.writeInt(value.length);
    for (String key in value.keys) {
      this.writeStr(key);
      this.writeStr(value[key]);
    }
  }
}
