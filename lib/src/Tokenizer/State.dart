part of PetiteParserDart.Tokenizer;

/// A state in the tokenizer used as a character
/// point in the tokenizer state machine.
class State {
  Tokenizer _tokenizer;
  String _name;
  List<Transition> _trans;
  TokenState _token;

  /// Creates a new state for this given tokenizer.
  State._(Tokenizer this._tokenizer, String this._name) {
    this._trans = new List<Transition>();
    this._token = null;
  }

  /// Loads a matcher group from the given deserializer.
  void _deserializeGroup(Matcher.Group group, Simple.Deserializer data) {
    int matcherCount = data.readInt();
    for (int i = 0; i < matcherCount; i++) {
      switch (data.readInt()) {
        case 0:
          this._deserializeGroup(group.addNot(), data);
          break;
        case 1:
          Matcher.Group other = new Matcher.Group();
          this._deserializeGroup(other, data);
          group.add(other);
          break;
        case 2:
          group.addAll();
          break;
        case 3:
          group.add(new Matcher.Range.fromCodeUnits(data.readInt(), data.readInt()));
          break;
        case 4:
          group.addSet(data.readStr());
          break;
      }
    }
  }

  /// Loads a state from the given deserializer.
  void _deserialize(Simple.Deserializer data) {
    int transCount = data.readInt();
    for (int i = 0; i < transCount; i++) {
      String key = data.readStr();
      State target = this._tokenizer._states[key];
      Transition trans = new Transition._(target);
      trans._consume = data.readBool();
      this._deserializeGroup(trans, data);
      this._trans.add(trans);
    }

    if (data.readBool())
      this._token = this._tokenizer._token[data.readStr()];
  }

  /// Creates a serializer to represent the matcher group.
  void _serializeGroup(Simple.Serializer data, Matcher.Group group) {
    data.writeInt(group.matchers.length);
    for (Matcher.Matcher matcher in group.matchers) {
      if (matcher is Matcher.Not) {
        data.writeInt(0);
        this._serializeGroup(data, matcher);
      } else if (matcher is Matcher.Group) {
        data.writeInt(1);
        this._serializeGroup(data, matcher);
      } else if (matcher is Matcher.All) {
        data.writeInt(2);
      }  else if (matcher is Matcher.Range) {
        data.writeInt(3);
        data.writeInt(matcher.low);
        data.writeInt(matcher.high);
      } else if (matcher is Matcher.Set) {
        data.writeInt(4);
        data.writeStr(matcher.toString());
      } else throw new Exception("Unknown matcher: $matcher");
    }
  }

  /// Creates a serializer to represent the state.
  Simple.Serializer _serialize() {
    Simple.Serializer data = new Simple.Serializer();

    data.writeInt(this._trans.length);
    for (Transition trans in this._trans) {
      data.writeStr(trans._target._name);
      data.writeBool(trans._consume);
      this._serializeGroup(data, trans);
    }

    bool hasTokenState = this._token != null;
    data.writeBool(hasTokenState);
    if (hasTokenState)
      data.writeStr(this._token._name);
    return data;
  }

  /// Gets the name of the state.
  String get name => this._name;

  /// Gets the acceptance token for this state if this state
  /// accepts the input at this point.
  /// If this isn't an accepting state thie will return null.
  TokenState get token => this._token;

  /// Sets the acceptance token for this state to the token with
  /// the given [tokenName]. If no token by that name exists it
  /// will be created. The new token is returned.
  TokenState setToken(String tokenName) {
    this._token = this._tokenizer.token(tokenName);
    return this._token;
  }

  /// Joins this state to another state by the given [endStateName]
  /// with a new transition. If a trasnition already exists between
  /// these two states that transition is returned,
  /// otherise the new transition is returned.
  Transition join(String endStateName) {
    for (Transition trans in this._trans) {
      if (trans.target.name == endStateName) return trans;
    }
    State target = this._tokenizer.state(endStateName);
    Transition trans = new Transition._(target);
    this._trans.add(trans);
    return trans;
  }

  /// Finds the matching transition given a character.
  /// If no transition matches null is returned.
  Transition findTansition(int c) {
    for (Transition trans in this._trans) {
      if (trans.match(c)) return trans;
    }
    return null;
  }

  /// Gets the name for this state.
  String toString() => this._name;

  /// Gets the human readable debug string.
  String _toDebugString() {
    StringBuffer buf = new StringBuffer();
    buf.write("(${this._name})");
    if (this._token != null) {
      buf.write(" => [${this._token._name}]");
      if (this._tokenizer._consume.contains(this._token._name))
        buf.write(" (consume)");
      for (String text in this._token._replace.keys) {
        buf.writeln();
        String target = this._token._replace[text];
        buf.write("  -- ${text} => [$target]");
        if (this._tokenizer._consume.contains(target))
          buf.write(" (consume)");
      }
    }
    for (Transition trans in this._trans) {
        buf.writeln();
        buf.write("  -- ${trans.toString()}");
    }
    return buf.toString();
  }
}
