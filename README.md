# iNaNe/3.725254969642999e-321

*3.725254969642999e-321*, also called *iNaNe*, is an esoteric programming language centered around the IEEE 754 standard for floating-point numbers.

## At a glance

Here's the elevator pitch:

- Stack-based
- Every value on the stack must encode a valid IEEE 754 NaN value, or the program will crash
- Extremely simple: lexical tokens translate 1-to-1 to interpreter instructions / runtime data
- Generally hard to use and not very useful

## Terms

- *the zero nan*: `0111111111111000000000000000000000000000000000000000000000000000`, perhaps the simplest valid 64-bit NaN value.

- *nannification* and *denannifiction*: *Nannification* is the process of taking a value and wrapping it into a NaN value. This is typically done by mapping `x` to `x | zero_nan`. *Denanification* is the reverse process, mapping `x` to `x & ~zero_nan`.

- a *signed* or *unsigned* float: A float is *signed* if the *sign bit* (leftmost bit) is 1; otherwise, it is *unsigned*.

## Syntax

The first thing to understand about iNaNe is that a program is entirely defined by a sequence of floating-point values, called its *stack*. The syntax acts only to give convenient names to certain floats, so that we may write this sequence more easily.

There are two ways to write a float in iNaNe:

1. As a numeral literal: `b'DIGITS` for binary, `x'DIGITS` for hexidecimal, and `a'DIGITS` for ascii. Prefix with `nan/` to nannify the value.
2. As a symbol: every float that can be executed by the interpreter gets its own symbol. There is a table of these below.

## Execution

Once the iNaNe code has been parsed into a stack, it may be executed. Before and after each instruction during execution, the stack must consist only of NaN values, or the program will crash.

The interpreter begins with the bottom value on the stack. Interpreting the value as an instruction, it performs the appropriate actions. Except for in certain cases, such as with the `}` instruction, the interpreter will now move onto the next instruction.

## Examples

#### Hello, world! #1

Relatively simple and uninteresting (#2 gets more fun)

`push X` pushes `X` onto the top of the stack. `show/char` converts the last 7 bits of the top float to a character and displays it. `stop` terminates the program.

```
push nan/a'H  show/char -- H
push nan/a'e  show/char -- e
push nan/a'l  show/char -- l
push nan/a'l  show/char -- l
push nan/a'o  show/char -- o
push nan/a',  show/char -- ,
push nan/x'20 show/char -- space
push nan/a'w  show/char -- w
push nan/a'o  show/char -- o
push nan/a'r  show/char -- r
push nan/a'l  show/char -- l
push nan/a'd  show/char -- d
push nan/a'!  show/char -- !
push nan/x'0A show/char -- newline
stop
```

#### Hello, world! #2

This is more interesting.

We've written our code, which is `show/char drop` repeated 14 times, followed by `stop`, followed by our data. This demonstrates that iNaNe code and data live on the stack together. Without the `stop` in this program, the interpreter would continue on to interpret the text as code.

```
show/char drop show/char drop show/char drop show/char drop show/char drop show/char drop show/char drop
show/char drop show/char drop show/char drop show/char drop show/char drop show/char drop show/char drop

stop

nan/x'0A -- newline
nan/a'!  -- !
nan/a'd  -- d
nan/a'l  -- l
nan/a'r  -- r
nan/a'o  -- o
nan/a'w  -- w
nan/x'20 -- space
nan/a',  -- ,
nan/a'o  -- o
nan/a'l  -- l
nan/a'l  -- l
nan/a'e  -- e
nan/a'H  -- H
```

## Instructions

- `stop`: terminate the program
- `{`: push the current instruction index onto the top of the stack, nannified
- `}`: pop the top value, denannify it, and set the instruction pointer to it

Together, `{` and `}` act as a kind of save/load mechanism. The most obvious application is for loops:

```
-- Loops forever, constantly printing 'x'
push nan/a'x { show/char }
```

- `[`: If the top value is signed, continue execution. If it is unsigned, advance to the matching `]` instruction.
- `]`: Noop

Together, `[` and `]` allow for conditional code:

- `push`: Push the succeeding float onto the top of the stack, and then advance to after the float. Thus `push X Y stop` is the same as `Y stop X`.
- `2`: Duplicate the top item on the stack
- `@`: Swap the top two values of the stack
- `drop`: Remove the top value from the stack
- `inct`: Increment the top value of the stack, treating it as an unsigned integer
- `dect`: Decrement the top value of the stack, treating it as an unsigned integer
- `rotr`: Rotate the bits of the top value of the stack to the right, wrapping
- `rotl`: Rotate the bits of the top value of the stack to the left, wrapping
- `read`: Read a character from stdin, nannify it, and push it onto the stack
- `show`: Display the top value of the stack
- `show/stack`: Display the entire stack
- `show/char`: Display the top value of the stack, denannified and as a character
- `show/bits`: Display the top value of the stack as a length-64 bitstring

#### Errors

If your program crashes, it will spit out an error code. This is what they mean:

- `NeN`: "not entirely NaNs"; you have introduced a non-NaN value onto the stack
- `NiB`: "not in bounds"; the instruction pointer has moved off the stack
- `NaI`: "not an instruction"; the given instruction is unknown
- `NpI`: "not paired instruction"; an `[` is unpaired
