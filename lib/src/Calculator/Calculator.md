# Patite Parser Calculator

The calculator uses the patite parser to create a simple mathmatical language.

## Example Input

- `10 * 4 + 6` > `int(46)`
- `cos(1.5*pi)` > `real(-1.8369701987210297e-16)`
- `min(4, 8, 15, 16, 23, 42)` > `int(4)`
- `0x00FF & 0xAAAA` > `int(170)`
- `int(string(12) + string(34))` > `int(1234)`

## Literals

- Binary numbers are made up of `0` and `1`'s followed by a `b`. For example `1011b`.
- Octal numbers are made up of `0` to `7`'s followed by a `o`. For example `137o`.
- Decimal numbers are made up of `0` to `9`'s, optionally followed by a `d`. For example `42`.
- Hexadecimal numbers are made up of `0` to `9` and `a` to `f`'s preceded by a `0x`. For example `0x00FF`.
- Boolean is either `true` and `false`.
- Real numbers are decimals numbers with either a decimal point or exponent in it.
  For example `0.01`, `12e-3`, and `1.1e2`.

## Constants

These are the built-in constants. Additional constants may be added as needed.

- `pi`: This is a real with the value for pi.
- `e`: This is a real with the value for e.
- `true`: This is a boolen for true.
- `false`: This is a boolean for false.

## Functions

These are the built-in functions. Additional functions may be added as needed.

- `abs`: Works on one number to get the absolute value. Example `abs(5)`.
- `acos`: Works on one number to get the arc cosine.
- `asin`: Works on one number to get the arc sine.
- `atan`: Works on one number to get the arc tangent.
- `atan2`: Works on two numbers to get the arc tangent given `y` and `x` as `atan(y/x)`.
- `avg`: Works on one or more numbers to get the average of all the numbers.
    If all the numbers are integers then the result will be an integer. Example `avg(4.5, 3.3, 12.0)`.
- `bool`: Converts the value to boolean. Example `bool(1)`.
- `ceil`: Works on one real to get the ceiling (rounded up) value. Returns integers unchanged.
- `cos`: Works on one number to get the cosine.
- `floor`: Works on one real to get the floor (rounded down) value. Returns integers unchanged.
- `int`: Converts the value to integer. Example `int(123)`.
- `log`: Works on two numbers to get the log given `a` and `b` as `log(a)/log(b)`.
- `log2`: Works on one number to get the log base 2.
- `log10`: Works on one number to get the log base 10.
- `ln`: Works on one number to get the natural log.
- `max`: Works on one or more numbers to get the maximum of all the numbers.
    If all the numbers are integers then the result will be an integer. Example `max(4.5, 3.3, 12.0)`.
- `min`: Works on one or more numbers to get the minimum of all the numbers.
    If all the numbers are integers then the result will be an integer. Example `max(4.5, 3.3, 12.0)`.
- `rand`: Takes no arguments and will return a random real number between 0 and 1.
- `real`: Converts the value to real. Example `real(123)`.
- `round`: Works on one real to round the value. Returns integers unchanged.
- `sin`: Works on one number to get the sine.
- `sqrt`: Works on one number to get the square root.
- `string`: Converts the value to string. Example `string(123)`.
- `sum`: Works on one or more numbers to get the sumation of all the numbers.
    If all the numbers are integers then the result will be an integer. Example `sum(4.5, 3.3, 12.0)`.
- `tan`: Works on one number to get the tangent.

## Operators

- `+`: This can be used as an unary or binary operator. As a unary it has no effect.
    As a binary between two numbers it will add them together. If both numbers are integers then an integer
    is returned. It can also be used between two strings to concatinate them. If used between two booleans it will OR them.
    Example `+1`, `2+4`, and `string(5)+string(4)`.
- `-`: This can be used as an unary or binary operator. As a unary for a number it will negate the number.
    As a binary between two numbers it will subtract the right from the left. If both numbers are integers then an integer
    is returned. If used between two booleans it will imply (`!a|b`) them. Example `-4` and `45-11`.
- `*`: This is a binary operator between two numbers for multiplying the numbers together.
    If both numbers are integers then an integer is returned. 
- `/`: This is a binary operator between two numbers for dividing the left number from the right number.
    If both numbers are integers then a truncated integer is returned. 
- `&`: This is a binary operator between two integers or two booleans for bitwise AND-ing the values.
- `|`: This is a binary operator between two integers or two booleans for bitwise OR-ing the values.
- `^`: This is a binary operator between two reals for getting the power of the left raised to the right.
    If between two integers or two booleans for bitwise XOR-ing the values.
- `~`: This is an unary operator for an integer to bitwise NOT the value.
- `!`: This is an unary operator for a boolean to NOT the value.

## Order of Operators

- `+`, `-`, `|`: Binary add, binary subtract, and binary OR.
- `*`, `/`, `&`: Binary multiplication, binary division, and binary AND.
- `^`, `()`, `-`, `+`, `!`, `~`: Binary XOR, parentheses and method calls,
    unary negation, unary assertion, and unary NOT and bitwise NOT.
