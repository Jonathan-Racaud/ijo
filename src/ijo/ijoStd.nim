import std/strformat
import std/tables

import types
import value

proc joinValuesAsString(values: seq[ijoValue]): string =
    var finalStr: string
    for _, value in values:
        finalStr &= &"{value.toString}"
    
    result = finalStr

proc print(params: seq[ijoValue]): ijoValue =
    let str = joinValuesAsString(params)
    stdout.write(str)

    result = String(str)

proc println(params: seq[ijoValue]): ijoValue =
    var str = joinValuesAsString(params)
    str &= "\n"

    stdout.write(str)
    
    result = String(str)

template globalRecord*: ijoRecord = newTable([
    ("print", BuiltInFunction("print", -1, print)),
    ("println", BuiltInFunction("println", -1, println)),
    ("+", BuiltInFunction("+", 2, ijoAdd)),
    ("-", BuiltInFunction("-", 2, ijoSub)),
    ("/", BuiltInFunction("/", 2, ijoDiv)),
    ("*", BuiltInFunction("*", 2, ijoMul)),
    ("%", BuiltInFunction("%", 2, ijoMod)),
])