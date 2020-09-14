proc top*[T](s: seq[T]): T =
      s[s.len - 1]

proc sign_bit*(n: uint64): uint64 =
    n shr 63

