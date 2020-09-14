import sequtils
import strutils
import tables
import os

import parse
import instrs

proc has_only_nans(stack: seq[uint64]): bool =
    stack.all(proc (item: uint64): bool = cast[float64](item).`$` == "nan")

proc execute*(stack: seq[uint64]): void =
    # make `var` copy of supplied stack
    var stack = stack[0 ..< stack.len]

    var instr_ptr = 0'u64
    while true:

        # Error if instruction pointer is out of bounds
        if instr_ptr.int >= stack.len:
            raise ValueError.newException("nib")

        let instr_code = stack[instr_ptr]

        # Error if instruction is unknown
        if instr_code notin instr_impls_by_code:
            raise ValueError.newException("nai")

        # Break if instruction is to terminate
        if instr_code == instr_codes_by_name["stop"]:
            break

        # Execute instruction
        let instr: Instr = instr_impls_by_code[instr_code]
        instr(stack, instr_ptr)

        # Enforce stack being only nans
        if not stack.has_only_nans:
            raise ValueError.newException("nan")

proc execute*(source: string): void =
  let instrs = parse(source)
  execute instrs

when isMainModule:
  if paramCount() != 1:
    echo "Expected exactly one command-line argument"
    quit(1)

  let filename = paramStr(1)
  let source = filename.readFile
  execute source
