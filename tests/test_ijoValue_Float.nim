# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import std/math

import ijo/types
import ijo/value

suite "ijoFloat tests":
  test "Float() returns ijoFloat":
    let value = Float(42)
    check value.kind == ijoFloat
    check value.floatVal == 42

  test "ijoFloat + ijoFloat returns sum of both":
    let a = Float(1)
    let b = Float(5)
    check (a + b).floatVal == 6

  test "ijoFloat - ijoFloat returns difference of both":
    let a = Float(1)
    let b = Float(5)
    check (a - b).floatVal == -4

  test "ijoFloat * ijoFloat returns multiplication of both":
    let a = Float(1)
    let b = Float(5)
    check (a * b).floatVal == 5

  test "ijoFloat / ijoFloat returns when both positive returns division of both":
    let a = Float(1)
    let b = Float(5)
    check (a / b).floatVal == 1 / 5

  test "ijoFloat / ijoFloat returns when b negative returns ijoUndefined":
    let a = Float(1)
    let b = Float(0)
    check (a / b).kind == ijoUndefined

  test "ijoFloat % ijoFloat returns when both positive returns modulo of both":
    let a = Float(1)
    let b = Float(5)
    let res = 1.0 mod 5.0
    check (a % b).floatVal == res

  test "ijoFloat % ijoFloat returns when b negative returns ijoUndefined":
    let a = Float(1)
    let b = Float(0)
    check (a % b).kind == ijoUndefined

  test "ijoFloat == ijoFloat when same value returns true":
    let a = Float(1)
    let b = Float(1)
    check (a == b).boolVal == true
  
  test "ijoFloat == ijoFloat when different value returns false":
    let a = Float(1)
    let b = Float(5)
    check (a == b).boolVal == false
