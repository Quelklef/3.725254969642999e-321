import bitops

# The bitstring representing nan that has the most zeroes and then the most contiguous ones
const nan_zero* = 0b0111111111111000000000000000000000000000000000000000000000000000'u64

proc nannify*(v: uint64): uint64 =
  v.bitor nan_zero

proc denannify*(v: uint64): uint64 =
  v.bitand: bitnot(nan_zero)

proc top*[T](s: seq[T]): T =
  s[s.len - 1]

proc sign_bit*(n: uint64): uint64 =
  n shr 63

proc index_of*(str: string, substr: string): int =
  for i in 0 ..< str.len:
    if str[i ..< i + substr.len] == substr:
      return i
  raise ValueError.newException("String does not contain substring")

proc to_binary*(n: uint64): string =
  for i in countdown(63, 0):
    let c = cast[char](cast[uint64]('0') + (n shr i).bitand(1))
    result &= c

proc abort*(msg: string): void =
  echo msg
  quit(1)
