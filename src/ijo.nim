import std/strutils

import ijo/ijoStd
import ijo/interpreter
import ijo/parser
import ijo/scanner
import ijo/types
import ijo/value

when isMainModule:
    let source = dedent """
        #greet(name) { 
            println("Hello ", name, "!")
        }

        #x = 5
        #y = 4

        println(x, ", ", y)
        greet("Bob")
    """

    let environment = ijoEnv(record: globalRecord)
    var ijoScanner = ijoScannerNew(source)

    var ijoParser = parserNew(ijoScanner)

    let program = ijoParser.parse()

    discard ijoEval(program, environment)