import sequtils
import strutils
import tables

import instrs

proc has_only_nans(stack: seq[uint64]): bool =
    stack.all(proc (item: uint64): bool = cast[float64](item).`$` == "nan")

proc execute(stack: seq[uint64]): void =
    # make `var` copy of supplied stack
    var stack = stack[0 ..< stack.len]

    var instr_ptr = 0'u64
    while true:

        # Error if instruction pointer is out of bounds
        if instr_ptr.int >= stack.len:
            raise ValueError.newException("nib")

        let instr_code = stack[instr_ptr]

        # Error if instruction is unknown
        if instr_code notin instr_code_to_impl:
            raise ValueError.newException("nai")

        # Break if instruction is to terminate
        if instr_code == instr_name_to_code["stop"]:
            break

        # Execute instruction
        let instr: Instr = instr_code_to_impl[instr_code]
        instr(stack, instr_ptr)

        # Enforce stack being only nans
        if not stack.has_only_nans:
            raise ValueError.newException("nan")

proc parse_bin(str: string): uint64 =
  for c in str:
    let v = if c == '0': 0 else: 1
    result = 2 * result + v.uint64

proc execute(instrs: string): void =
    let stack = instrs
        .split({'\n', ' '})
        .filterIt(it.strip != "")
        .mapIt(
          if '0' in it or '1' in it: it.parse_bin
          else: instr_name_to_code[it]
        )

    execute(stack)

execute("""

push 0111111111111000000000000000000000000000000000000000000001100001
char
stop

""")

echo "done"



