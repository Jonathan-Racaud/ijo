import unittest

import std/strutils

import ijo/ijoStd
import ijo/interpreter
import ijo/parser
import ijo/scanner
import ijo/types
import ijo/value

proc eval(source: string): ijoValue =
    let environment = ijoEnv(record: globalRecord)
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