import tables
import bitops
import sugar
import sequtils
import strutils

import util
import parse

type Instr* = proc(stack: var seq[uint64], instr_ptr: var uint64): void

var instr_impls_by_code* = newTable[uint64, Instr]()

proc instr(name: string, impl: Instr): void =
  let code = symbol_to_code(name);
  instr_impls_by_code[code] = impl


# == Control Flow == #

# End the program (no implementation, handled specially)
instr "stop", nil

# Push the instruction pointer, nannified
instr "{", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  stack.add: instr_ptr.nannify
  instr_ptr += 1

# Pop the top value, denannify it, and set the instruction pointer to it
instr "}", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  instr_ptr = stack.pop.denannify

# If the top value is unsigned, advance to the matching `fi`.
# Otherwise, do nothing.
instr "[", proc(stack: var seq[uint64], instr_ptr: var uint64): void =

  if stack.top.sign_bit == 1:
    instr_ptr += 1

  else:
    var depth = 0
    for idx in instr_ptr ..< stack.len.uint64:
      let instr_code = stack[idx]
      if instr_code == symbol_to_code("["):
        depth += 1
      elif instr_code == symbol_to_code("]"):
        depth -= 1
      if depth == 0:
        instr_ptr = idx
        return
    abort "NpI"

# Noop
instr "]", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  instr_ptr += 1


# == Value Shuffling == #

# Move the next item onto the top of the stack
instr "push", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  stack.add stack[instr_ptr + 1]
  instr_ptr += 2

# Duplicate the top item of the stack
instr "2", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  stack.add: stack.top
  instr_ptr += 1

# Swap the top two values
instr "@", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  stack.add: [stack.pop, stack.pop]  # An obfuscated but cool implementation!
  instr_ptr += 1

# Pop the top item
instr "drop", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  discard stack.pop
  instr_ptr += 1


# == Value Manipulation == #

# Increment the top item
instr "inct", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  stack.add: stack.pop + 1
  instr_ptr += 1

# Decrement the top item
instr "dect", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  stack.add: stack.pop - 1
  instr_ptr += 1

# Flip the sign bit of the top item
instr "neg", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  let top = stack.pop

  if top.sign_bit == 1:
    stack.add: top.bitand(bitnot(1'u64 shl 63))
  else:
    stack.add: top.bitor(1'u64 shl 63)

  instr_ptr += 1

# Rotate the top item one to the right, wrapping
instr "rotr", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  let top = stack.pop
  stack.add: (top shl 63).bitor(top shr 1)
  instr_ptr += 1

# Rotate the top item one to the left, wrapping
instr "rotl", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  let top = stack.pop
  stack.add: (top shl 1).bitor(top shr 63)
  instr_ptr += 1


# == IO == #

# Read a character from stdin
instr "get", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  var chr: char
  try:
    chr = stdin.read_char
  except EOFError:
    chr = '\0'

  stack.add: cast[uint64](chr).nannify
  instr_ptr += 1

# Print the top item
instr "put", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  echo cast[float64](stack.top).`$`
  instr_ptr += 1

# Print the entire stack
# Useful for debugging ;)
instr "put/all", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  echo "[" & stack.map(val => cast[float64](val).`$`).join(", ") & "]"
  instr_ptr += 1

# Print the top item as asn ascii character, according to the first 7 bits
instr "put/char", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  stdout.write stack.top.bitand(0b1111111).char
  instr_ptr += 1

# Print the top item as a bitvector
instr "put/bits", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
  var chars = ""
  for i in countdown(63, 0):
    chars &= (stack.top shr i).bitand(1).`$`
  echo chars
  instr_ptr += 1
