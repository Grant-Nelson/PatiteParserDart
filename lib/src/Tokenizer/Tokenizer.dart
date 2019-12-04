library PatiteParserDart.Tokenizer;

import '../Matcher/Matcher.dart' as Matcher;

part 'State.dart';
part 'Token.dart';
part 'TokenState.dart';
part 'Transition.dart';

/// A tokenizer for breaking a string into tokens.
class Tokenizer {
  Map<String, State> _states;
  Map<String, TokenState> _token;
  State _start;

  /// Creates a new tokenizer.
  Tokenizer() {
    this._states = new Map<String, State>();
    this._token = new Map<String, TokenState>();
    this._start = null;
  }

  /// Sets the start state for the tokenizer to a state with the name [stateName].
  /// If that state doesn't exist it will be created.
  State start(String stateName) {
    this._start = this.state(stateName);
    return this._start;
  }

  /// Creates and adds a state by the given name [stateName].
  /// If a state aleady exists it is returned,
  /// otherwise the new state is returned.
  State state(String stateName) {
    State state = this._states[stateName];
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
    TokenState token = this._token[tokenName];
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

  /// Sets the token for the given state and returns the acceptance token.
  TokenState setToken(String stateName, String tokenName) =>
    this.state(stateName).setToken(tokenName);

  /// Tokenizes the given input string with the current configured
  /// tokenizer and returns the iterator of tokens for the input.
  /// This will throw an exception if the input is not tokenizable.
  Iterable<Token> tokenize(String input) => this.tokenizeChars(input.codeUnits.iterator);
  
  /// Tokenizes the given iterator of characters with the current configured
  /// tokenizer and returns the iterator of tokens for the input.
  /// This will throw an exception if the input is not tokenizable.
  Iterable<Token> tokenizeChars(Iterator<int> iterator) sync* {
    Token lastToken = null;
    State state = this._start;
    int index = 0;
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
      Transition trans = state.findTansition(c);
      if (trans == null) {
        // No transition found.
        if (lastToken == null) {
          // No previous found token state, therefore this part
          // of the input isn't tokenizable with this tokenizer.
          String text = new String.fromCharCodes(allInput);
          throw new Exception("Untokenizable string [state: ${state.name}, index $index]: \"$text\"");
        }

        // Reset to previous found token's state.
        Token resultToken = lastToken;
        index = lastLength;
        allInput.removeRange(0, lastLength);
        retoken.addAll(allInput);
        allInput = [];
        outText = [];
        lastToken = null;
        lastLength = 0;
        state = this._start;

        yield resultToken;
      } else {

        // Transition to the next state and check if it is an acceptance state.
        // Store acceptance state to return to if needed.
        if (!trans.consume) outText.add(c);
        state = trans.target;
        if (state.token != null) {
          String text = new String.fromCharCodes(outText);
          lastToken = state.token.getToken(text, index);
          lastLength = allInput.length;
        }
      }
    }

    if (lastToken != null) yield lastToken;
  }
}
