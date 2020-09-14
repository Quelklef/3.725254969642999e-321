import sequtils
import tables
import os

import util
import parse
import instrs

proc has_only_nans(stack: seq[uint64]): bool =
  stack.all(proc (item: uint64): bool = cast[float64](item).`$` == "nan")

proc execute*(stack: seq[uint64]): void =
  # make `var` copy of supplied stack
  var stack = stack[0 ..< stack.len]

  var instr_ptr = 0'u64
  while true:

    # Enforce stack being only nans
    if not stack.has_only_nans:
      abort "nan"

    # Error if instruction pointer is out of bounds
    if instr_ptr < 0 or instr_ptr.int >= stack.len:
      abort "nib"

    let instr_code = stack[instr_ptr]

    # Error if instruction is unknown
    if instr_code notin instr_impls_by_code:
      abort "nai"

    # Break if instruction is to terminate
    if instr_code == instr_codes_by_name["stop"]:
      break

    # Execute instruction
    let instr: Instr = instr_impls_by_code[instr_code]
    instr(stack, instr_ptr)

proc execute*(source: string): void =
  let instrs = parse(source)
  execute instrs

when isMainModule:
  if paramCount() != 1:
    abort "Expected exactly one command-line argument"

  let filename = paramStr(1)
  let source = filename.readFile
  execute source
