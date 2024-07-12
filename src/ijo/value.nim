import std/math
import std/strformat

import types

proc Int*(value: int): ijoValue =
  result = ijoValue(kind: ijoInt, intVal: value)

proc Float*(value: float): ijoValue =
  result = ijoValue(kind: ijoFloat, floatVal: value)

proc String*(value: string): ijoValue =
  result = ijoValue(kind: ijoString, strVal: value)

proc Bool*(value: bool): ijoValue =
  result = ijoValue(kind: ijoBool, boolVal: value)

proc UserFunction*(
  name: string,
  paramCount: int, 
  params: seq[string],
  body: ijoExpr,
  env: ijoEnv): ijoValue =
  result = ijoValue(
    kind: ijoFunc,
    funcName: name,
    funcParamCount: paramCount,
    funcParams: params,
    funcBody: body,
    funcEnv: env,
    builtInFunc: nil
  )

proc BuiltInFunction*(
  name: string,
  paramCount: int,
  builtIn: ijoBuiltInFuncType): ijoValue =
  result = ijoValue(
    kind: ijoFunc,
    funcName: name,
    funcParamCount: paramCount,
    funcParams: @[],
    funcBody: nil,
    funcEnv: nil,
    builtInFunc: builtIn)

proc Struct*(name: string, record: ijoRecord): ijoValue =
  result = ijoValue(kind: ijoStruct, structName: name, structRecord: record)

proc Undefined*(): ijoValue =
  result = ijoValue(kind: ijoUndefined)

proc `+`*(a: ijoValue, b: ijoValue): ijoValue =
  if a.kind != b.kind:
    return Undefined()

  case a.kind
    of ijoInt: return Int(a.intVal + b.intVal)
    of ijoFloat: return Float(a.floatVal + b.floatVal)
    of ijoString: return String(&"{a.strVal}{b.strVal}")
    of ijoList, ijoBool, ijoFunc, ijoStruct, ijoUndefined: return Undefined()

proc ijoAdd*(params: seq[ijoValue]): ijoValue = 
  if params.len != 2: return Undefined()
  
  let a = params[0]
  let b = params[1]

  result = a + b

proc `-`*(a: ijoValue, b: ijoValue): ijoValue =
  if a.kind != b.kind:
    return Undefined()

  case a.kind
    of ijoInt: return Int(a.intVal - b.intVal)
    of ijoFloat: return Float(a.floatVal - b.floatVal)
    of ijoString, ijoList, ijoBool, ijoFunc, ijoStruct, ijoUndefined: return Undefined()

proc `-`*(a: ijoValue): ijoValue =
  case a.kind
    of ijoInt: return Int(-a.intVal)
    of ijoFloat: return Float(-a.floatVal)
    of ijoString, ijoList, ijoBool, ijoFunc, ijoStruct, ijoUndefined: return Undefined()

proc ijoSub*(params: seq[ijoValue]): ijoValue = 
  if params.len == 2: 
    let a = params[0]
    let b = params[1]
    
    return a - b

  if params.len == 1:
    let a = params[0]
    return -a

  return Undefined()

proc `*`*(a: ijoValue, b: ijoValue): ijoValue =
  if a.kind != b.kind:
    return Undefined()

  case a.kind
    of ijoInt: return Int(a.intVal * b.intVal)
    of ijoFloat: return Float(a.floatVal * b.floatVal)
    of ijoString, ijoList, ijoBool, ijoFunc, ijoStruct, ijoUndefined: return Undefined()

proc ijoMul*(params: seq[ijoValue]): ijoValue = 
  if params.len != 2: return Undefined()
  
  let a = params[0]
  let b = params[1]

  result = a * b

proc `/`*(a: ijoValue, b: ijoValue): ijoValue =
  if a.kind != b.kind:
    return Undefined()

  case a.kind
    of ijoInt:
      if b.intVal == 0: return Undefined() 
      return Int(a.intVal div b.intVal)
    of ijoFloat:
      if b.floatVal == 0: return Undefined()
      return Float(a.floatVal / b.floatVal)
    of ijoString, ijoList, ijoBool, ijoFunc, ijoStruct, ijoUndefined: return Undefined()

proc ijoDiv*(params: seq[ijoValue]): ijoValue = 
  if params.len != 2: return Undefined()
  
  let a = params[0]
  let b = params[1]

  result = a / b

proc `%`*(a: ijoValue, b: ijoValue): ijoValue =
  if a.kind != b.kind:
    return Undefined()

  case a.kind
    of ijoInt:
      if b.intVal == 0: return Undefined() 
      return Int(a.intVal mod b.intVal)
    of ijoFloat:
      if b.floatVal == 0: return Undefined()
      return Float(a.floatVal mod b.floatVal)
    of ijoString, ijoList, ijoBool, ijoFunc, ijoStruct, ijoUndefined: return Undefined()

proc ijoMod*(params: seq[ijoValue]): ijoValue = 
  if params.len != 2: return Undefined()
  
  let a = params[0]
  let b = params[1]

  result = a % b

proc `not`*(a: ijoValue, b: ijoValue): ijoValue =
  if a.kind != b.kind:
    return Undefined()

  case a.kind
    of ijoInt: return Bool(a.intVal != b.intVal)
    of ijoFloat: return Bool(a.floatVal != b.floatVal)
    of ijoString: return Bool(a.strVal != b.strVal)
    of ijoList: return Bool(a.listVal != b.listVal)
    of ijoBool: return Bool(a.boolVal != b.boolVal)
    of ijoFunc: return Bool(true)
    of ijoUndefined: return Bool(true)
    of ijoStruct: return Bool(true)

proc `==`*(a: ijoValue, b: ijoValue): ijoValue =
  if a.kind != b.kind:
    return Undefined()

  case a.kind
    of ijoInt: return Bool(a.intVal == b.intVal)
    of ijoFloat: return Bool(a.floatVal == b.floatVal)
    of ijoString: return Bool(a.strVal == b.strVal)
    of ijoList: return Bool(a.listVal == b.listVal)
    of ijoBool: return Bool(a.boolVal == b.boolVal)
    of ijoFunc: return Bool(false)
    of ijoUndefined: return Bool(true)
    of ijoStruct: return Bool(false)

proc ijoEq*(params: seq[ijoValue]): ijoValue = 
  if params.len != 2: return Undefined()
  
  let a = params[0]
  let b = params[1]

  result = a == b

proc `==`*(a: ijoValue, b: bool): ijoValue =
  if a.kind != ijoBool:
    return Bool(false)

  return Bool(a.boolVal == b)

proc `!=`*(a: ijoValue, b: ijoValue): ijoValue =
  result = (a == b)

  if result.kind == ijoUndefined: return

  result.boolVal = if result.boolVal: false else: true

proc ijoDiff*(params: seq[ijoValue]): ijoValue = 
  if params.len != 2: return Undefined()
  
  let a = params[0]
  let b = params[1]

  result = a != b

proc `!=`*(a: ijoValue, b: bool): ijoValue =
  if a.kind != ijoBool:
    return Bool(true)

  return Bool(not a.boolVal == b)

proc `>`*(a: ijoValue, b: ijoValue): ijoValue =
  if a.kind != b.kind:
    return Undefined()

  case a.kind
    of ijoInt: return Bool(a.intVal > b.intVal)
    of ijoFloat: return Bool(a.floatVal > b.floatVal)
    of ijoString, ijoList, ijoBool, ijoFunc, ijoStruct, ijoUndefined: return Undefined()

proc ijoGreater*(params: seq[ijoValue]): ijoValue = 
  if params.len != 2: return Undefined()
  
  let a = params[0]
  let b = params[1]

  result = a > b

proc `>=`*(a: ijoValue, b: ijoValue): ijoValue =
  if a.kind != b.kind:
    return Undefined()

  case a.kind
    of ijoInt: return Bool(a.intVal >= b.intVal)
    of ijoFloat: return Bool(a.floatVal >= b.floatVal)
    of ijoString, ijoList, ijoBool, ijoFunc, ijoStruct, ijoUndefined: return Undefined()

proc ijoGreaterEq*(params: seq[ijoValue]): ijoValue = 
  if params.len != 2: return Undefined()
  
  let a = params[0]
  let b = params[1]

  result = a >= b

proc `<`*(a: ijoValue, b: ijoValue): ijoValue =
  if a.kind != b.kind:
    return Undefined()

  case a.kind
    of ijoInt: return Bool(a.intVal < b.intVal)
    of ijoFloat: return Bool(a.floatVal < b.floatVal)
    of ijoString, ijoList, ijoBool, ijoFunc, ijoStruct, ijoUndefined: return Undefined()

proc ijoLess*(params: seq[ijoValue]): ijoValue = 
  if params.len != 2: return Undefined()
  
  let a = params[0]
  let b = params[1]

  result = a < b

proc `<=`*(a: ijoValue, b: ijoValue): ijoValue =
  if a.kind != b.kind:
    return Undefined()

  case a.kind
    of ijoInt: return Bool(a.intVal <= b.intVal)
    of ijoFloat: return Bool(a.floatVal <= b.floatVal)
    of ijoString, ijoList, ijoBool, ijoFunc, ijoStruct, ijoUndefined: return Undefined()

proc ijoLessEq*(params: seq[ijoValue]): ijoValue = 
  if params.len != 2: return Undefined()
  
  let a = params[0]
  let b = params[1]

  result = a <= b

proc toString*(value: ijoValue): string =
  result = case value.kind
    of ijoInt: &"{value.intVal}"
    of ijoFloat: &"{value.floatVal}"
    of ijoBool: &"{value.boolVal}"
    of ijoString: value.strVal
    of ijoList: &"List<>"
    of ijoFunc: &"Func<{value.funcName}>"
    of ijoUndefined: "undefined"
    of ijoStruct: &"Struct<{value.structName}>"