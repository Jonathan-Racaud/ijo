import std/strutils

import ijo/expression
import ijo/ijoStd
import ijo/interpreter
import ijo/parser
import ijo/scanner
import ijo/types
import ijo/value

when isMainModule:    
    # let program = @[
    #     functionDefinitionExpr("greet", @["name"], 
    #         functionCallExpr("@>>", @[stringExpr("Hello "), getIdentifierExpr("name"), stringExpr("!")])
    #     ),
    #     constExpr("x", intExpr(5)),
    #     constExpr("y", intExpr(4)),
    #     functionCallExpr("@>>", @[getIdentifierExpr("x"), stringExpr(", "), getIdentifierExpr("y")]),
    #     functionCallExpr("greet", @[stringExpr("Bob")]),
    #     structDefinitionExpr("Person", @[varExpr("name", stringExpr("")), varExpr("age", intExpr(0))])
    # ]

    let source = dedent """
        #greet(name) { 
            @>>("Hello ", name, "!")
        }

        #x = 5
        #y = 4

        @>>(x, ", ", y)
        greet("Bob")
    """

    let environment = ijoEnv(record: globalRecord)
    let ijoScanner = ijoScanner()
    ijoScanner.init(source)

    var ijoParser = parserNew(ijoScanner)

    let program = ijoParser.parse()

    discard ijoEval(program, environment)