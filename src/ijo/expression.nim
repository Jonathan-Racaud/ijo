import std/options

import types

proc constExpr*(name: string, value: ijoExpr): ijoExpr =
  result = ijoExpr(kind: ijoConstExpr, constName: name, constVal: value)

proc varExpr*(name: string, value: ijoExpr): ijoExpr =
  result = ijoExpr(kind: ijoVarExpr, varName: name, varVal: value)

proc intExpr*(value: int): ijoExpr =
  result = ijoExpr(kind: ijoIntExpr, intVal: value) 

proc floatExpr*(value: float): ijoExpr =
  result = ijoExpr(kind: ijoFloatExpr, floatVal: value)

proc stringExpr*(value: string): ijoExpr =
  result = ijoExpr(kind: ijoStringExpr, strVal: value)

proc boolExpr*(value: bool): ijoExpr =
  result = ijoExpr(kind: ijoBoolExpr, boolVal: value)

proc functionCallExpr*(name: string, params: seq[ijoExpr]): ijoExpr =
  result = ijoExpr(kind: ijoFunctionCallExpr, callName: name, callParams: params)

proc functionDefinitionExpr*(name: string, params: seq[string], body: ijoExpr): ijoExpr =
  result = ijoExpr(kind: ijoFunctionDefinitionExpr, funcName: name, funcParams: params, funcBody: body)

proc structDefinitionExpr*(name: string, body: seq[ijoExpr]): ijoExpr =
  result = ijoExpr(kind: ijoStructDefinitionExpr, structName: name, structBody: body)

proc getIdentifierExpr*(name: string): ijoExpr =
  result = ijoExpr(kind: ijoGetIdentifierExpr, getName: name)

proc setIdentifierExpr*(name: string, expression: ijoExpr): ijoExpr =
  result = ijoExpr(kind: ijoSetIdentifierExpr, setName: name, setVal: expression)

proc ifExpr*(condition: ijoExpr, body: ijoExpr, otherwise: ijoExpr): ijoExpr =
  result = ijoExpr(kind: ijoConditionalExpr, condition: condition, condThen: body, condElse: some(otherwise))

proc ifExpr*(condition: ijoExpr, body: ijoExpr): ijoExpr =
  result = ijoExpr(kind: ijoConditionalExpr, condition: condition, condThen: body, condElse: none(ijoExpr))

proc loopExpr*(body: ijoExpr): ijoExpr =
  result = ijoExpr(kind: ijoLoopExpr, loopInit: none(ijoExpr), loopCondition: none(ijoExpr), loopIncrement: none(ijoExpr), loopBody: body)

proc loopExpr*(cond: ijoExpr, body: ijoExpr): ijoExpr =
  result = ijoExpr(kind: ijoLoopExpr, loopInit: none(ijoExpr), loopCondition: some(cond), loopIncrement: none(ijoExpr), loopBody: body)

proc loopExpr*(cond: ijoExpr, increment: ijoExpr, body: ijoExpr): ijoExpr =
  result = ijoExpr(kind: ijoLoopExpr, loopInit: none(ijoExpr), loopCondition: some(cond), loopIncrement: some(increment), loopBody: body)

proc loopExpr*(init: ijoExpr, cond: ijoExpr, increment: ijoExpr, body: ijoExpr): ijoExpr =
  result = ijoExpr(kind: ijoLoopExpr, loopInit: some(init), loopCondition: some(cond), loopIncrement: some(increment), loopBody: body)

proc blockExpr*(expressions: seq[ijoExpr]): ijoExpr =
  result = ijoExpr(kind: ijoBlockExpr, blockVal: expressions)

proc undefinedExpr*(): ijoExpr =
  result = ijoExpr(kind: ijoUndefinedExpr, undefinedVal: nil)

proc errorExpr*(message: string): ijoExpr =
  result = ijoExpr(kind: ijoErrorExpr, errorVal: stringExpr(message))

proc errorExpr*(): ijoExpr =
  result = ijoExpr(kind: ijoErrorExpr, errorVal: undefinedExpr())