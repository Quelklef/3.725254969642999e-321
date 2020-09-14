import strutils
import sequtils

import util

type ParsingException = object of CatchableError

const symbol_chars =
  "abcdefghijklmnopqrstuvwxyz0123456789<>()[]{}~!@#$%^&*-+_=?:;,.'\"\\/|`"

assert symbol_chars.len == 68

proc symbol_to_code*(symbol: string): uint64 =
  let symbol = symbol.to_lower_ascii

  # Using 9+ chars requires 52 or more bits, which overlaps with nannified bits
  # Thus, disallow symbols above 8 chars
  if symbol.len >= 9:
    raise ParsingException.newException("Symbol '" & symbol & "' is too large!")

  for ch in symbol:
    if ch notin symbol_chars:
      raise ParsingException.newException("Symbol '" & symbol & "' is invalid!")
    result = symbol_chars.len * result + symbol_chars.index_of(ch).uint64

  result = result.nannify

proc parse_numeral(source: string): uint64 =
  var source = source

  let nanned = source.starts_with("nan/")
  if nanned: source = source["nan/".len ..< source.len]

  let kind = source[0]
  source = source[1 ..< source.len]

  if source[0] != '\'':
    raise ParsingException.newException("Malformed numeral")
  source = source[1 ..< source.len]

  case kind

  of 'b':  # binary
    for c in source:
      if c notin "01":
        raise ParsingException.newException("Malformed numeral")
      result = 2 * result + cast[uint64](c) - cast[uint64]('0')

  of 'x':  # hex
    for c in source:
      if c notin "0123456789ABCDEFabcdef":
        raise ParsingException.newException("Malformed numeral")

      var val: uint64;  # case expr not working for some reason
      if c <= '9': val = cast[uint64](c) - cast[uint64]('0')
      elif c <= 'F': val = 10 + cast[uint64](c) - cast[uint64]('A')
      elif c <= 'f': val = 10 + cast[uint64](c) - cast[uint64]('a')

      result = 16 * result + val

  of 'a':  # ascii
    for c in source:
      result = 256 * result + cast[uint64](c)

  else:
    raise ParsingException.newException("Malformed numeral")

  if nanned:
    result = result.nannify

proc parse*(source: string): seq[uint64] =

  return source

    # Remove comments
    .split('\n')
    .mapIt(
      if "--" notin it: it
      else: it[0 ..< it.index_of("--")]
    )
    .join("\n")

    # Parse into codes
    .split({'\n', ' '})
    .filterIt(it.strip != "")
    .mapIt(if '\'' in it: parse_numeral(it) else: symbol_to_code(it))  # FIXME: disallows apostrophes in symbols
