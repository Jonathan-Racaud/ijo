# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import ijo/types
import ijo/value

suite "ijoInt tests":
  test "Int() returns ijoInt":
    let value = Int(42)
    check value.kind == ijoInt
    check value.intVal == 42

  test "ijoInt + ijoInt returns sum of both":
    let a = Int(1)
    let b = Int(5)
    check (a + b).intVal == 6

  test "ijoInt - ijoInt returns difference of both":
    let a = Int(1)
    let b = Int(5)
    check (a - b).intVal == -4

  test "ijoInt * ijoInt returns multiplication of both":
    let a = Int(1)
    let b = Int(5)
    check (a * b).intVal == 5

  test "ijoInt / ijoInt returns when both positive returns division of both":
    let a = Int(1)
    let b = Int(5)
    check (a / b).intVal == 1 div 5

  test "ijoInt / ijoInt returns when b negative returns ijoUndefined":
    let a = Int(1)
    let b = Int(0)
    check (a / b).kind == ijoUndefined

  test "ijoInt % ijoInt returns when both positive returns modulo of both":
    let a = Int(1)
    let b = Int(5)
    check (a % b).intVal == 1 mod 5

  test "ijoInt % ijoInt returns when b negative returns ijoUndefined":
    let a = Int(1)
    let b = Int(0)
    check (a % b).kind == ijoUndefined

  test "ijoInt == ijoInt when same value returns true":
    let a = Int(1)
    let b = Int(1)
    check (a == b).boolVal == true
  
  test "ijoInt == ijoInt when different value returns false":
    let a = Int(1)
    let b = Int(5)
    check (a == b).boolVal == false
  
suite "ijoUndefined tests":
  test "Undefined() returns ijoUndefined":
    check (Undefined().kind == ijoUndefined)
