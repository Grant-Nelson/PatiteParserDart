part of PatiteParserDart.Grammar;

/// An item is part of a term rule.
abstract class Item {

  /// The name of the item.
  final String name;

  /// Creates a new item.
  Item._(String this.name);
  
  /// Gets the string for this item.
  String toString() => this.name;
}
