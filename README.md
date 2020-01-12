# PatiteParserDart

Patite Parser is a simple parsing tool which can be
configured to read different languages and structures.

This can be used to read complex data files, interpret scripts,
or even translate a file into another (basic compile).

This library contains several tools for reading and processing text files:
diff, parser, simple, and tokenizer. The diff tool takes two sources text
and indicates the difference between them. The parser is a tool for
reading a complicated noncontextual language, such as a programming language.
The simple tool is used for serializing and deserializing quickly from
in a simple hard defined order. The tokenizer is part of the parser but can
be used by itself for breaking up text for something like text coloring.

## Installing

- Clone this repo locally
- Install [Dart 2.0](https://webdev.dartlang.org/)
- Run `pub get`

## Run unit-tests

- Run `pub run test/test.dart`

## Run the calculator example

- Run `pub run example/example.dart`
- See [Calculator Documentation](./lib/src/Calculator/Calculator.md)
