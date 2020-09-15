# 3.725254969642999e-321

*3.725254969642999e-321* is an esoteric programming language centered around the IEEE 754 standard for floating-point numbers.

## At a glance

- Stack-based
- Code and data both live on the same
  - This isn't really used in any interesting way, though
- The stack must always consist only of valid IEEE 754 64-bit NaN values, or the program will crash
- Generally hard to use and not very useful

## Terms

- *the zero nan*: `0111111111111000000000000000000000000000000000000000000000000000`, perhaps the simplest valid 64-bit NaN value.

- *nannification* and *denannifiction*: *Nannification* is the process of taking a value and wrapping it into a NaN value. This is typically done by mapping `x` to `x | zero_nan`. *Denanification* is the reverse process, mapping `x` to `x & ~zero_nan`.

- a *signed* or *unsigned* float: A float is *signed* if the *sign bit* (leftmost bit) is 1; otherwise, it is *unsigned*.

## Syntax

The first thing to understand about *3.725254969642999e-321* is that a program is entirely defined by a sequence of floating-point values, called its *stack*. Both the program code *and* its data are stored on the stack.

A *3.725254969642999e-321* program is written as a sequence of words, but each word maps directly to a floating-point value:
- A symbol, which is a sequence of characters from `abcdefghijklmnopqrstuvwxyz0123456789<>()[]{}~!@#$%^&*-+_=?:;,.'"`\/|``, is converted to an integer by interpretering the symbol as a number where the above characters are digits. This value is then nannified and then casted to a float. Uppercase letters are also allowed but are normalized to lowercase. Symbols may not be more than 8 characters long; above this, the data would overlap with the `1`s required for nannification.
- A numeral, which is either `b'DIGITS`, `x'DIGITS`, or `a'CHARS`, optionally prefixed with `nan/`, designates a float more directly: the digits are converted either from `b`inary, he`x`adecimal, or `a`scii (padded to 8 bits), nannified if the numeral begins with `nan/`, and casted to a float.

## Execution

Once the code has been parsed into a stack, it may be executed. Before and after each instruction during execution, the stack must consist only of valid IEEE 754 NaN values, or the program will crash.

The interpreter keeps track of the current instruction with an 'instruction pointer', which starts at `0`. It repeatedly gets the instruction at the location in the stack given by the instruction pointer and performs the associated action. Except for in certain cases, such as those of loops, the instruction pointer is then incremented.

## Examples

See `examples/`

## Instructions

|Syntax|Semantics|
|-|-|
|`stop`|Terminate the program|
|`{`|Push the current value of the instruction pointer onto the top of the stack, nannified|
|`}`|Pop the top value, denannify it, and set the instruction pointer to it|
|`[`|If the top value is signed, noop. If it is unsigned, advance the instruction pointer to the matching `]`.|
|`]`|Noop|
|`push`|Push the value after this instruction onto the top of the stack, and then advance to after the value|
|`dup`|Duplicate the top item on the stack|
|`swap`|Swap the top two values of the stack|
|`drop`|Remove the top value from the stack|
|`++`|Increment the top value of the stack, treating it as an unsigned integer|
|`--`|Decrement the top value of the stack, treating it as an unsigned integer|
|`neg`|Toggle the sign bit on the top value of the stack|
|`rotr`|Rotate the bits of the top value of the stack to the right, wrapping|
|`rotl`|Rotate the bits of the top value of the stack to the left, wrapping|
|`get/char`|Read a character from stdin, nannify it, and push it onto the stack. If stdin is empty, it is read as `\0`.|
|`put`|Display the top value of the stack|
|`put/all`|Display the entire stack|
|`put/char`|Display the top value of the stack, denannified and as a character|
|`put/bits`|Display the top value of the stack as a length-64 bitstring|

## Errors

If your program crashes, it will spit out an error code.

|Error|Type|Stands for|Meaning|
|-|-|-|-|
|`NvS`|Parsing|"not valid symbol"|A symbol is invalid|
|`NvN`|Parsing|"not valid numeral"|A numeral is invalid|
|`NeN`|Runtime|"not entirely NaNs"|You have introduced a non-NaN value onto the stack|
|`NiB`|Runtime|"not in bounds"|The instruction pointer has moved off the stack|
|`NaI`|Runtime|"not an instruction"|Unknown instruction encountered|
|`NpI`|Runtime|"not paired instruction"|An `{` or `[` is unpaired|

