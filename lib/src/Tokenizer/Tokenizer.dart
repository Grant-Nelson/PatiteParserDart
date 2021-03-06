library PetiteParserDart.Tokenizer;

import 'package:PetiteParserDart/src/Simple/Simple.dart' as Simple;
import 'package:PetiteParserDart/src/Matcher/Matcher.dart' as Matcher;

part 'State.dart';
part 'Token.dart';
part 'TokenState.dart';
part 'Transition.dart';

/// A tokenizer for breaking a string into tokens.
class Tokenizer {
  Map<String, State?> _states = {};
  Map<String, TokenState?> _token = {};
  Set<String> _consume = Set();
  State? _start = null;

  /// Creates a new tokenizer.
  Tokenizer();

  /// Loads a whole tokenizer from the given deserializer.
  factory Tokenizer.deserialize(Simple.Deserializer data) {
    int version = data.readInt();
    if (version != 1)
      throw new Exception('Unknown version, $version, for tokenizer serialization.');

    Tokenizer tokenizer = new Tokenizer();

    int tokenCount = data.readInt();
    for (int i = 0; i < tokenCount; i++) {
      String key = data.readStr();
      TokenState token = new TokenState._(tokenizer, key);
      token._replace = data.readStringStringMap();
      tokenizer._token[key] = token;
    }

    int stateCount = data.readInt();
    List<String> keys = [];
    for (int i = 0; i < stateCount; i++) {
      String key = data.readStr();
      tokenizer._states[key] = new State._(tokenizer, key);
      keys.add(key);
    }
    for (String key in keys)
      tokenizer._states[key]?._deserialize(data.readSer());

    tokenizer._consume = new Set.from(data.readStrList());
    if (data.readBool())
      tokenizer._start = tokenizer._states[data.readStr()];
    return tokenizer;
  }

  /// Creates a serializer to represent the whole tokenizer.
  Simple.Serializer serialize() {
    Simple.Serializer data = new Simple.Serializer();
    data.writeInt(1); // Version 1

    data.writeInt(this._token.length);
    for (String key in this._token.keys) {
      data.writeStr(key);
      data.writeStringStringMap(this._token[key]?._replace ?? {});
    }

    data.writeInt(this._states.length);
    for (String key in this._states.keys)
      data.writeStr(key);
    for (String key in this._states.keys)
      data.writeSer(this._states[key]?._serialize());

    data.writeStrList(this._consume.toList());

    bool hasStart = this._start != null;
    data.writeBool(hasStart);
    if (hasStart) data.writeStr(this._start?._name ?? '');
    return data;
  }

  /// Sets the start state for the tokenizer to a state with the name [stateName].
  /// If that state doesn't exist it will be created.
  State start(String stateName) =>
    this._start = this.state(stateName);

  /// Creates and adds a state by the given name [stateName].
  /// If a state already exists it is returned,
  /// otherwise the new state is returned.
  State state(String stateName) {
    State? state = this._states[stateName];
    if (state == null) {
      state = new State._(this, stateName);
      this._states[stateName] = state;
    }
    return state;
  }

  /// Creates and add an acceptance token with the given name [tokenName].
  /// A new acceptance token is not connected to any state.
  /// If a token by that name already exists it will be returned,
  /// otherwise the new token is returned.
  TokenState token(String tokenName) {
    TokenState? token = this._token[tokenName];
    if (token == null) {
      token = new TokenState._(this, tokenName);
      this._token[tokenName] = token;
    }
    return token;
  }

  /// Joins the two given states and returns the new or
  /// already existing transition.
  Transition join(String startStateName, String endStateName) =>
    this.state(startStateName).join(endStateName);

  /// This is short hand for a join and setToken
  /// where the state name and token name are the same.
  Transition joinToToken(String startStateName, String endStateName) {
    this.state(endStateName).setToken(endStateName);
    return this.state(startStateName).join(endStateName);
  }

  /// Sets the token for the given state and returns the acceptance token.
  TokenState setToken(String stateName, String tokenName) =>
    this.state(stateName).setToken(tokenName);

  /// Sets which tokens should be consumed and not emitted.
  void consume(Iterable<String> tokens) => this._consume.addAll(tokens);

  /// Tokenizes the given input string with the current configured
  /// tokenizer and returns the iterator of tokens for the input.
  /// This will throw an exception if the input is not tokenizable.
  Iterable<Token> tokenize(String input) => this.tokenizeChars(input.codeUnits.iterator);

  /// Tokenizes the given iterator of characters with the current configured
  /// tokenizer and returns the iterator of tokens for the input.
  /// This will throw an exception if the input is not tokenizable.
  Iterable<Token> tokenizeChars(Iterator<int> iterator) sync* {
    Token? lastToken = null;
    State? state = this._start;
    int index = 0;
    int lastIndex = 0;
    int lastLength = 0;
    List<int> outText  = [];
    List<int> allInput = [];
    List<int> retoken  = [];

    while (true) {
      int c;
      if (retoken.isNotEmpty) {
        c = retoken.removeAt(0);
      } else {
        if (!iterator.moveNext()) break;
        c = iterator.current;
      }
      allInput.add(c);
      index++;

      // Transition to the next state with the current character.
      Transition? trans = state?.findTansition(c);
      if (trans == null) {
        // No transition found.
        if (lastToken == null) {
          // No previous found token state, therefore this part
          // of the input isn't tokenizable with this tokenizer.
          String text = new String.fromCharCodes(allInput);
          throw new Exception('Untokenizable string [state: ${state?.name}, index $index]: "$text"');
        }

        // Reset to previous found token's state.
        Token resultToken = lastToken;
        index = lastIndex;
        allInput.removeRange(0, lastLength);
        retoken.addAll(allInput);
        allInput = [];
        outText = [];
        lastToken = null;
        lastLength = 0;
        state = this._start;

        if (!this._consume.contains(resultToken.name))
          yield resultToken;
      } else {

        // Transition to the next state and check if it is an acceptance state.
        // Store acceptance state to return to if needed.
        if (!trans.consume) outText.add(c);
        state = trans.target;
        if (state?.token != null) {
          String text = new String.fromCharCodes(outText);
          lastToken = state?.token?.getToken(text, index);
          lastLength = allInput.length;
          lastIndex = index;
        }
      }
    }

    if ((lastToken != null) && (!this._consume.contains(lastToken.name)))
      yield lastToken;
  }

  /// Gets the human readable debug string.
  String toString() {
    StringBuffer buf = new StringBuffer();
    if (this._start != null) buf.writeln(this._start?._toDebugString());
    for (State? state in this._states.values) {
      if (state != this._start) buf.writeln(state?._toDebugString());
    }
    return buf.toString();
  }
}
