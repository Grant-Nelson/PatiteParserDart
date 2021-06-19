part of PetiteParserDart.Tokenizer;

/// A token state is added to a state to indicate that
/// the state is acceptance for a token.
class TokenState {
  Tokenizer _tokenizer;
  String _name;
  Map<String, String> _replace = {};

  /// Creates a new token state for the given tokenizer.
  TokenState._(Tokenizer this._tokenizer, String this._name);

  /// Gets the name of this token.
  String get name => this._name;

  /// Adds a replacement which replaces this token's name with the given
  /// [tokenName] when the accepted text is the same as any of the given [text].
  void replace(String tokenName, Iterable<String> text) {
    for (String t in text) this._replace[t] = tokenName;
  }

  /// Indicates that tokens with this name should not be emitted
  /// but quietly consumed.
  void consume() => this._tokenizer.consume([this._name]);

  /// Creates a token for this token state and the given [text].
  /// If the text matches a replacement's text the
  /// replacement token is used instead.
  Token getToken(String text, int index) =>
    new Token(this._replace[text] ?? this._name, text, index);

  /// Gets the name for this token.
  String toString() => this._name;
}
