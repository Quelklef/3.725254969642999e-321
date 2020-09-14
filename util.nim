proc top*[T](s: seq[T]): T =
  s[s.len - 1]

proc sign_bit*(n: uint64): uint64 =
  n shr 63

proc index_of*(str: string, substr: string): int =
  for i in 0 ..< str.len:
    if str[i ..< i + substr.len] == substr:
      return i
  raise ValueError.newException("String does not contain substring")
