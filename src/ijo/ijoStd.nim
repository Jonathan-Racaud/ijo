import std/strformat
import std/tables

import types
import value

proc print(params: seq[ijoValue]): ijoValue =
    for _, param in params:
        stdout.write &"{param.toString}"

    result = Undefined()

proc println(params: seq[ijoValue]): ijoValue =
    discard print(params)
    echo "\n"
    
    result = Undefined()

template globalRecord*: ijoRecord = newTable([
    ("@>", BuiltInFunction("@>", -1, print)),
    ("@>>", BuiltInFunction("@>>", -1, println)),
    ("+", BuiltInFunction("+", 2, ijoAdd)),
    ("-", BuiltInFunction("-", 2, ijoSub)),
    ("/", BuiltInFunction("/", 2, ijoDiv)),
    ("*", BuiltInFunction("*", 2, ijoMul)),
    ("%", BuiltInFunction("%", 2, ijoMod)),
])