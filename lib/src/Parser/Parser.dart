library PatiteParserDart.Parser;

// import '../Matcher/Matcher.dart' as Matcher;
// import '../Tokenizer/Tokenizer.dart' as Tokenizer;

part 'Rule.dart';
part 'Term.dart';

class Parser {
  List<Term> _ruleSets;
  Term _start;
  
  Parser() {
    this._ruleSets = new List<Term>();
    this._start = null;
  }

  Term start(String termName) {
    this._start = this.term(termName);
    return this._start;
  }
  
  Term _findTerm(String termName) {
    for (Term term in this._ruleSets) {
      if (term.name == termName) return term;
    }
    return null;
  }

  Term term(String termName) {
    Term nt = this._findTerm(termName);
    if (nt == null) {
      nt = new Term._(this, termName);
      this._ruleSets.add(nt);
    }
    return nt;
  }
  
  Rule newRule(String termName) =>
    this.term(termName).newRule();

  void calculate() {
    for (Term term in this._ruleSets)
      term._calculate();
    
    print("Firsts:");
    for (Term term in this._ruleSets)
      print("   "+term.toString()+": "+term.firsts.join(", "));
  }

  String toString() {
    StringBuffer buf = new StringBuffer();
    if (this._start != null)
      buf.writeln("> "+this._start.name);
    for (Term term in this._ruleSets) {
      for (Rule rule in term.rules)
       buf.writeln(rule);
    }
    return buf.toString();
  }
}
