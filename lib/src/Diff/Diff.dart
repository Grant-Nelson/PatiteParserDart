library Diff;

import 'dart:math' as math;

part 'Comparable.dart';
part 'Container.dart';
part 'Path.dart';

/// A continuous group of step types.
class Step {

  /// The type for this group.
  final StepType type;

  /// The number of the given type in the group.
  final int count;

  /// Creates a new step group.
  Step(this.type, this.count);

  /// Gets the string for this group.
  String toString() => '$type $count';
}

/// This is the steps of the Levenshtein path.
enum StepType {

  /// Indicates A and B entries are equal.
  Equal,

  /// Indicates A was added.
  Added,

  /// Indicates A was removed.
  Removed
}

/// Gets the difference path for the sources as defined by the given comparable.
Iterable<Step> diffPath(Comparable comp) =>
  new _Path(comp).iteratePath();

/// Gets the difference path for the two given string lists.
Iterable<Step> stringListPath(List<String> aSource, List<String> bSource) =>
  diffPath(new _StringsComparable(aSource, bSource));

/// Gets the difference path for the lines in the given strings.
Iterable<Step> linesPath(String aSource, String bSource) =>
  stringListPath(aSource.split('\n'), bSource.split('\n'));

/// Gets the labelled difference between the two list of lines.
/// It formats the results by prepending a "+" to new lines in `bSource`,
/// a "-" for any to removed strings from `aSource`, and space if the strings are the same.
String plusMinusLines(String aSource, String bSource) =>
	plusMinusParts(aSource.split('\n'), bSource.split('\n')).join('\n');

/// Gets the labelled difference between the two list of lines.
/// It formats the results by prepending a "+" to new lines in `bSource`,
/// a "-" for any to removed strings from `aSource`, and space if the strings are the same.
List<String> plusMinusParts(List<String> aSource, List<String> bSource) {
	List<String> result = new List<String>();
	int aIndex = 0, bIndex = 0;
	for (Step step in stringListPath(aSource, bSource)) {
		switch (step.type) {
      case StepType.Equal:
        for (int i = step.count-1; i >= 0; i--) {
          result.add(' '+aSource[aIndex]);
          aIndex++;
          bIndex++;
        }
        break;
      case StepType.Added:
        for (int i = step.count-1; i >= 0; i--) {
          result.add('+'+bSource[bIndex]);
          bIndex++;
        }
        break;
      case StepType.Removed:
        for (int i = step.count-1; i >= 0; i--) {
          result.add('-'+aSource[aIndex]);
          aIndex++;
        }
        break;
		}
	}
	return result;
}
