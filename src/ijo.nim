import std/strutils

import ijo/ijoStd
import ijo/interpreter
import ijo/parser
import ijo/scanner
import ijo/types
import ijo/value

when isMainModule:
    let source = dedent """
    ~($i = 0; i < 5; i = i + 1) { i }
    """

    let environment = ijoEnv(record: globalRecord)
    var ijoScanner = ijoScannerNew(source)

    var ijoParser = parserNew(ijoScanner)

    let program = ijoParser.parse()

    discard ijoEval(program, environment)