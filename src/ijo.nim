import std/strutils

import ijo/ijoStd
import ijo/interpreter
import ijo/parser
import ijo/scanner
import ijo/types
import ijo/value

when isMainModule:
    let source = dedent """
    #number = 42

    ?(number == 42) { print("yes") } ?() { print("false") }
    """

    let environment = ijoEnv(record: globalRecord)
    var ijoScanner = ijoScannerNew(source)

    var ijoParser = parserNew(ijoScanner)

    let program = ijoParser.parse()

    discard ijoEval(program, environment)