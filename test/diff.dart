part of PetiteParserDart.test;

void diff00(TestArgs args) {
  args.log('diff00');

  args.checkDiff(
		['cat'],
		['cat'],
		[' cat']);

  args.checkDiff(
		['cat'],
		['dog'],
		['-cat', '+dog']);

  args.checkDiff(
		['A', 'G', 'T', 'A', 'C', 'G', 'C', 'A'],
    ['T', 'A', 'T', 'G', 'C'],
    ['-A', '-G', ' T', ' A', '-C', '+T', ' G', ' C', '-A']);

  args.checkDiff(
		['cat', 'dog'],
		['cat', 'horse'],
		[' cat', '-dog', '+horse']);

  args.checkDiff(
		['cat', 'dog'],
		['cat', 'horse', 'dog'],
		[' cat', '+horse', ' dog']);

  args.checkDiff(
		['cat', 'dog', 'pig'],
		['cat', 'horse', 'dog'],
		[' cat', '+horse', ' dog', '-pig']);

	args.checkDiff(
		['mike', 'ted', 'mark', 'jim'],
		['ted', 'mark', 'bob', 'bill'],
		['-mike', ' ted', ' mark', '-jim', '+bob', '+bill']);

	args.checkDiff(
		['k', 'i', 't', 't', 'e', 'n'],
		['s', 'i', 't', 't', 'i', 'n', 'g'],
		['-k', '+s', ' i', ' t', ' t', '-e', '+i', ' n', '+g']);

	args.checkDiff(
		['s', 'a', 't', 'u', 'r', 'd', 'a', 'y'],
		['s', 'u', 'n', 'd', 'a', 'y'],
		[' s', '-a', '-t', ' u', '-r', '+n', ' d', ' a', ' y']);

	args.checkDiff(
		['s', 'a', 't', 'x', 'r', 'd', 'a', 'y'],
		['s', 'u', 'n', 'd', 'a', 'y'],
		[' s', '-a', '-t', '-x', '-r', '+u', '+n', ' d', ' a', ' y']);

	args.checkDiff(
		['func A() int {',
     '  return 10',
     '}',
     '',
     'func C() int {',
     '  return 12',
     '}'],
		['func A() int {',
     '  return 10',
     '}',
     '',
     'func B() int {',
     '  return 11',
     '}',
     '',
     'func C() int {',
     '  return 12',
     '}'],
		[' func A() int {',
     '   return 10',
     ' }',
     ' ',
     '+func B() int {',
     '+  return 11',
     '+}',
     '+',
     ' func C() int {',
     '   return 12',
     ' }']);
}
