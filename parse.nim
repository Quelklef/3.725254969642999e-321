import strutils
import sequtils
import tables

import instrs

proc parse_bin(str: string): uint64 =
  for c in str:
    let v = if c == '0': 0 else: 1
    result = 2 * result + v.uint64

proc parse*(source: string): seq[uint64] =
  return source
    .split({'\n', ' '})
    .filterIt(it.strip != "")
    .mapIt(
      if '0' in it or '1' in it: it.parse_bin
      else: instr_codes_by_name[it]
    )
