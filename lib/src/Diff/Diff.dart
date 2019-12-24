library Diff;

import 'dart:math' as math;

part 'DiffComparable.dart';
part 'Path.dart';

/// This is the steps of the levenshtein path.
enum StepType {
  
  /// Indicates A and B entries are equal.
  Equal,
  
  /// Indicates A was added.
  Added,

  /// Indicates A was removed.
  Removed
}

/// Gets the difference path for the sources as defined by the given comparable.
List<StepType> diffPath(DiffComparable comp) =>
  new _Path(comp).createPath();

/// Gets the difference path for the two given string lists.
List<StepType> stringListPath(List<String> aSource, List<String> bSource) =>
  diffPath(new _StringListComparable(aSource, bSource));

/// Gets the difference path for the lines in the given strings.
List<StepType> linesPath(String aSource, String bSource) =>
  stringListPath(aSource.split('\n'), bSource.split('\n'));

/// Gets the labelled difference between the two list of lines.
/// It formats the results by prepending a "+" to new lines in `bSource`,
/// a "-" for any to removed strings from `aSource`, and space if the strings are the same.
String plusMinusLines(String aSource, String bSource) {
	StringBuffer result = new StringBuffer();
	int aIndex = 0, bIndex = 0;
  List<String> aLines = aSource.split('\n');
  List<String> bLines = bSource.split('\n');
	List<StepType> path = stringListPath(aLines, bLines);
	for (StepType step in path) {
		switch (step) {
      case StepType.Equal:
        result.writeln(' '+aLines[aIndex]);
        aIndex++;
        bIndex++;
        break;
      case StepType.Added:
        result.writeln('+'+bLines[bIndex]);
        bIndex++;
        break;
      case StepType.Removed:
        result.writeln('-'+aLines[aIndex]);
        aIndex++;
        break;
		}
	}
	return result.toString();
}

/// Gets the labelled difference between the two list of lines
/// using a similar output to the git merge differences output.
String mergeLines(String aSource, String bSource) {
	StringBuffer result = new StringBuffer();
	int aIndex = 0, bIndex = 0;
  List<String> aLines = aSource.split('\n');
  List<String> bLines = bSource.split('\n');
	List<StepType> path = stringListPath(aLines, bLines);

	const String startChange = '<<<<<<<<';
	const String middleChange = '========';
	const String endChange = '>>>>>>>>';

	StepType prevState = StepType.Equal;
	for (StepType step in path) {
		switch (step) {
      case StepType.Equal:
        switch (prevState) {
          case StepType.Equal:
            break;
          case StepType.Added:
            result.writeln(endChange);
            break;
          case StepType.Removed:
            result.writeln(middleChange);
            result.writeln(endChange);
            break;
        }
        result.writeln(aLines[aIndex]);
        aIndex++;
        bIndex++;
        break;

      case StepType.Added:
        switch (prevState) {
          case StepType.Equal:
            result.writeln(startChange);
            result.writeln(middleChange);
            break;
          case StepType.Added:
            break;
          case StepType.Removed:
            result.writeln(middleChange);
            break;
        }
        result.writeln(bLines[bIndex]);
        bIndex++;
        break;

      case StepType.Removed:
        switch (prevState) {
          case StepType.Equal:
            result.writeln(startChange);
            break;
          case StepType.Added:
            result.writeln(middleChange);
            break;
          case StepType.Removed:
            break;
        }
        result.writeln(aLines[aIndex]);
        aIndex++;
        break;
      }
      prevState = step;
    }

  switch (prevState) {
    case StepType.Equal:
      break;
    case StepType.Added:
      result.writeln(endChange);
      break;
    case StepType.Removed:
      result.writeln(middleChange);
      result.writeln(endChange);
      break;
  }
	return result.toString();
}
