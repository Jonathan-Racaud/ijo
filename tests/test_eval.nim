import unittest

import std/strutils

import ijo/ijoStd
import ijo/interpreter
import ijo/parser
import ijo/scanner
import ijo/types
import ijo/value

proc eval(source: string): ijoValue =
    var environment = ijoEnv(record: globalRecord)
    var ijoScanner = ijoScannerNew(source)

    var ijoParser = parserNew(ijoScanner)

    let program = ijoParser.parse()

    result = ijoEval(program, environment)

test "print":
    let res = eval(dedent """
    print("Hello World!")
    """)
    
    check res.kind == ijoString
    check res.strVal == "Hello World!"

test "println":
    let res = eval(dedent """
    println("Hello World!")
    """)
    
    check res.kind == ijoString
    check res.strVal == "Hello World!\n"

test "conditional true":
    let res = eval(dedent """
    ?(true) { 42 }
    """)

    check res.kind == ijoInt
    check res.intVal == 42

test "conditional else":
    let res = eval(dedent """
    ?(false) { 42 } ?() { 60 }
    """)

    check res.kind == ijoInt
    check res.intVal == 60

test "conditional using constant result is true":
    let res = eval(dedent """
    #number = 42
    ?(number == 42) { 1 }
    """)

    check res.kind == ijoInt
    check res.intVal == 1

test "conditional using constant result is false":
    let res = eval(dedent """
    #number = 43
    ?(number == 42) { 
        1
    } ?() { 
        2 
    }
    """)

    check res.kind == ijoInt
    check res.intVal == 2

test "block expression":
    let res = eval(dedent """
    {
        42
    }
    """)

    check res.kind == ijoInt
    check res.intVal == 42

test "var expression":
    let res = eval(dedent """
    {
        $i = 42
        i
    }
    """)

    check res.kind == ijoInt
    check res.intVal == 42

test "const expression":
    let res = eval(dedent """
    #i = 42
    """)

    check res.kind == ijoInt
    check res.intVal == 42

test "define function":
    let res = eval(dedent """
    #add(a, b) { a + b }
    """)

    check res.kind == ijoFunc
    check res.funcName == "add"
    check res.funcParamCount == 2
    check res.builtInFunc == nil

test "call function":
    let res = eval(dedent """
    #add(a, b) { a + b }

    add(1, 5)
    """)

    check res.kind == ijoInt
    check res.intVal == 6

# test "loop form 2 return 5":
#     let res = eval(dedent """
#     {
#         $i = 0
#         ~(i < 5) {
#             i = i + 1
#             i 
#         }
#     }
#     """)

#     check res.kind == ijoInt
#     check res.intVal == 5

# test "loop form 3 return 5":
#     let res = eval(dedent """
#     {
#         $i = 0
#         ~(i < 5; i = i + 1) {
#             i 
#         }
#     }
#     """)

#     check res.kind == ijoInt
#     check res.intVal == 5

test "loop form 4 return 5":
    let res = eval("~($i = 0; i < 5; i = i + 1) { i }")

    check res.kind == ijoInt
    check res.intVal == 5