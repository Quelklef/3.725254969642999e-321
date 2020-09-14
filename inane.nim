import bitops
import tables
import sequtils
import strutils

proc top[T](s: seq[T]): T =
    s[s.len - 1]

proc sign_bit(n: uint64): uint64 =
    n shr 63

const nan_zero = 0b0111111111111000000000000000000000000000000000000000000000000000'u64

type Instr = proc(stack: var seq[uint64], instr_ptr: var uint64): void

var instr_name_to_code = newTable[string, uint64]()
var instr_code_to_impl = newTable[uint64, Instr]()

var code_counter = 0'u64

proc next_code(): uint64 =
    result = code_counter.bitor nan_zero
    code_counter.inc

proc instr(name: string, impl: Instr): void =
    let code = next_code();
    instr_name_to_code[name] = code
    instr_code_to_impl[code] = impl

# End the program (no implementation, handled specially)
instr "stop", nil

# Open a while loop to the corresponding close
instr "here", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
    stack.insert(instr_ptr.bitor nan_zero, 0)
    instr_ptr += 2

# Close a while loop
instr "back", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
    if stack.top.sign_bit == 1:
        instr_ptr = (stack[0] - 1).bitand(nan_zero.bitnot)
    stack.delete(0)

# Push 0b0111111111111000000000000000000000000000000000000000000000000000 onto the stack
instr "push", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
    stack.add 0b0111111111111000000000000000000000000000000000000000000000000000'u64
    instr_ptr += 1

# Increment the top item
instr "inct", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
    stack.add: stack.pop + 1
    instr_ptr += 1

# Decrement the top item
instr "dect", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
    stack.add: stack.pop - 1
    instr_ptr += 1

# Pop the top item
instr "drop", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
    discard stack.pop
    instr_ptr += 1

# Print the top item
instr "show", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
    echo cast[float64](stack.top).`$`
    instr_ptr += 1

# Print the top item as asn ascii character, according to the first 7 bits
instr "char", proc(stack: var seq[uint64], instr_ptr: var uint64): void =
    echo stack.top.bitand(0b1111111).char
    instr_ptr += 1

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

proc execute(instrs: string): void =
    let stack = instrs
        .split({'\n', ' '})
        .filterIt(it.strip != "")
        .mapIt(instr_name_to_code[it])

    execute(stack)

# 0b01111111111100000000000000x0000000000000000000000000000000000000

execute("""

push
inct inct inct inct inct inct inct inct inct inct
inct inct inct inct inct inct inct inct inct inct
inct inct inct inct inct inct inct inct inct inct
inct inct inct inct inct inct inct inct inct inct
inct inct inct inct inct inct inct inct inct inct
inct inct inct inct inct inct inct inct inct inct
inct inct inct inct inct inct inct inct inct inct
inct inct inct inct inct inct inct inct inct inct
inct inct inct inct inct inct inct inct inct inct
inct inct inct inct inct inct inct inct
char
stop

""")

echo "done"

echo cast[float64](754)
