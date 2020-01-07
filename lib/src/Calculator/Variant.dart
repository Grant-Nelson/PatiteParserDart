part of PatiteParserDart.Calculator;

enum VariantType {
  Str,
  Int,
  Real,
  Bool,
  Func
}

String valueTypeToString(VariantType type) {
  switch (type) {
    case VariantType.Str:  return "str";
    case VariantType.Int:  return "int";
    case VariantType.Real: return "real";
    case VariantType.Bool: return "bool";
    case VariantType.Func: return "func";
    default:               return "unknown";
  }
}

typedef void CalcFunc(List<Variant> args);

class Variant {
  final VariantType type;
  final Object value;

  Variant(this.type, this.value);
  factory Variant.Str(String value)    => new Variant(VariantType.Str,  value);
  factory Variant.Int(int value)       => new Variant(VariantType.Int,  value);
  factory Variant.Real(double value)   => new Variant(VariantType.Real, value);
  factory Variant.Bool(bool value)     => new Variant(VariantType.Bool, value);
  factory Variant.Func(CalcFunc value) => new Variant(VariantType.Func, value);

  bool get isStr  => this.type == VariantType.Str;
  bool get isInt  => this.type == VariantType.Int;
  bool get isReal => this.type == VariantType.Real;
  bool get isBool => this.type == VariantType.Bool;
  bool get isFunc => this.type == VariantType.Func;

  String get asStr {
    if (isFunc) throw new Exception('May not cast a function to a string.');
    if (isStr)  return this.value as String;
    if (isInt)  return (this.value as int).toString();
    if (isReal) return (this.value as double).toString();
    if (isBool) return (this.value as bool).toString();
    throw new Exception('May not cast unexpected value type to string: $type');
  }

  int get asInt {
    if (isFunc) throw new Exception('May not cast a function to an integer.');
    if (isStr)  return int.parse(this.value as String);
    if (isInt)  return this.value as int;
    if (isReal) return (this.value as double).toInt();
    if (isBool) return (this.value as bool)? 1: 0;
    throw new Exception('May not cast unexpected value type to int: $type');
  }

  bool get asBool {
    if (isFunc) throw new Exception('May not cast a function to a boolean.');
    if (isStr) {
      String val = (this.value as String).toLowerCase();
      return (val.length > 0) && (val != '0') && (val != 'false');
    }
    if (isInt)  return (this.value as int) != 0;
    if (isReal) return (this.value as double) != 0;
    if (isBool) return this.value as bool;
    throw new Exception('May not cast unexpected value type to boolean: $type');
  }

  double get asReal {
    if (isFunc) throw new Exception('May not cast a function to a double.');
    if (isStr)  return double.parse(value as String);
    if (isInt)  return (this.value as int).toDouble();
    if (isReal) return this.value as double;
    if (isBool) return (this.value as bool)? 1.0: 0.0;
    throw new Exception('May not cast unexpected value type to double: $type');
  }
  
  CalcFunc get asFunc {
    if (isFunc) return this.value as CalcFunc;
    throw new Exception('May not cast type to calculator function: $type');
  }

  String toString() => valueTypeToString(this.type)+"(${this.value})";
}
