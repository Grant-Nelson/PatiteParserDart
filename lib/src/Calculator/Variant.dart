part of PetiteParserDart.Calculator;

/// Variant is a wrapper of values off the stack with helper methods
/// for casting and testing the implicit casting of a value.
class Variant {

  /// This is the wrapped value.
  final Object value;

  /// Wraps the given value into a new Variant.
  Variant(Object this.value);

  /// Gets the string for this value.
  String toString() => '${value.runtimeType}($value)';

  /// Indicates if this value is a Boolean value.
  bool get isBool => value is bool;

  /// Indicates if this value is an integer value.
  bool get isInt => value is int;

  /// Indicates if this value is a real value.
  bool get isReal => value is double;

  /// Indicates if this value is a string value.
  bool get isStr => value is String;

  /// Indicates if the given value can be implicitly cast to a Boolean value.
  bool get implicitBool => isBool;

  /// Indicates if the given value can be implicitly cast to an integer value.
  bool get implicitInt => isBool || isInt;

  /// Indicates if the given value can be implicitly cast to a real value.
  bool get implicitReal => isBool || isInt || isReal;

  /// Indicates if the given value can be implicitly cast to a string value.
  bool get implicitStr => isStr;

  /// Casts this value to a Boolean.
  bool get asBool {
    if (isStr) {
      String val = (value as String).toLowerCase();
      return (val.length > 0) && (val != '0') && (val != 'false');
    }
    if (isInt)  return (value as int) != 0;
    if (isReal) return (value as double) != 0;
    if (isBool) return value as bool;
    throw new Exception('May not cast ${value} to Boolean.');
  }

  /// Casts this value to an integer.
  int get asInt {
    if (isStr)  return int.parse(value as String);
    if (isInt)  return value as int;
    if (isReal) return (value as double).toInt();
    if (isBool) return (value as bool)? 1: 0;
    throw new Exception('May not cast ${value} to int.');
  }

  /// Casts this value to a real.
  double get asReal {
    if (isStr)  return double.parse(value as String);
    if (isInt)  return (value as int).toDouble();
    if (isReal) return value as double;
    if (isBool) return (value as bool)? 1.0: 0.0;
    throw new Exception('May not cast ${value} to real.');
  }

  /// Casts this value to a string.
  String get asStr {
    if (isStr)  return value as String;
    if (isInt)  return (value as int).toString();
    if (isReal) return (value as double).toString();
    if (isBool) return (value as bool).toString();
    throw new Exception('May not cast ${value} to string.');
  }
}