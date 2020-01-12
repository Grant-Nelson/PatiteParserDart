part of PatiteParserDart.Grammar;

/// A token is an item to represent a group of text
/// to the parser so it can match tokens to determine the
/// different rules to take while parsing.
/// This mirrors the `Tokenizer.Token` result object.
class TokenItem extends Item {

  /// Creates a new token.
  TokenItem(String name): super._(name);

  /// Gets the string for this token.
  String toString() => "[${this.name}]";
}
