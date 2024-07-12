import std/strformat

import fusion/matching

import env
import value
import types

const ijoVersion* = "0.1.0"

# Forward declaration
proc ijoEval*(expressions: seq[ijoExpr], env: var ijoEnv): ijoValue
proc ijoEval*(expression: ijoExpr, env: var ijoEnv): ijoValue

# Implementation
proc ijoEvalBlock(expressions: seq[ijoExpr], env: var ijoEnv): ijoValue =
  result = ijoValue(kind: ijoUndefined)

  for i, expression in expressions:
    result = ijoEval(expression, env)

proc ijoEvalBody(expression: ijoExpr, env: var ijoEnv): ijoValue =
  if expression.kind == ijoBlockExpr:
    return ijoEvalBlock(expression.blockVal, env)

  return ijoEval(expression, env)

proc ijoEval(expression: ijoExpr, env: var ijoEnv): ijoValue =
  case expression.kind:
    of ijoIntExpr: result = ijoValue(kind: ijoInt, intVal: expression.intVal)
    of ijoFloatExpr: result = ijoValue(kind: ijoFloat, floatVal: expression.floatVal)
    of ijoBoolExpr: result = ijoValue(kind: ijoBool, boolVal: expression.boolVal)
    of ijoStringExpr: result = ijoValue(kind: ijoString, strVal: expression.strVal)
    of ijoVarExpr:
      var val = ijoEval(expression.varVal, env)
      result = env.defineVar(expression.varName, val)
    of ijoConstExpr:
      var val = ijoEval(expression.constVal, env)
      result = env.defineConst(expression.constName, val)
    of ijoSetIdentifierExpr:
      let val = ijoEval(expression.setVal, env)
      result = env.setIdentifier(expression.setName, val)
    of ijoGetIdentifierExpr:
      result = env.getIdentifier(expression.getName)
    of ijoBlockExpr:
      result = ijoEvalBlock(expression.blockVal, env)
    of ijoFunctionDefinitionExpr:
      var function = UserFunction(
        expression.funcName,
        expression.funcParams.len,
        expression.funcParams,
        expression.funcBody,
        env
      )

      result = env.defineConst(expression.funcName, function)
    of ijoStructDefinitionExpr:
      var structEnv = ijoEnvironment()
      for structExpression in expression.structBody:
        # We only want to populate the record that will be associated with the struct
        discard ijoEval(structExpression, structEnv)

      var struct = Struct(
        expression.structName,
        structEnv.record
      )

      result = env.defineVar(expression.structName, struct)
    of ijoFunctionCallExpr:
      let callName = expression.callName
      let callParams = expression.callParams

      let f = env.getIdentifier(callName)
      if f.kind == ijoUndefined:
          echo &"Function not found: {callName}"
          return ijoValue(kind: ijoUndefined)
      
      if callParams.len > f.funcParamCount and f.funcParamCount != -1:
        echo &"No function {callName} which accept {callParams.len} arguments found"
        return ijoValue(kind: ijoUndefined)

      var args = newSeq[ijoValue]()
      for i, param in callParams:
          let paramVal = ijoEval(param, env)
          args.add(paramVal)
      
      if f.builtInFunc != nil:
        result = f.builtInFunc(args)
      else:
        var activationEnv = ijoEnvironment(f.funcEnv)
        
        for i, param in callParams:
          var paramVal = ijoEval(param, env)
          discard activationEnv.defineConst(f.funcParams[i], paramVal)

        result = ijoEvalBody(f.funcBody, activationEnv)
    of ijoConditionalExpr:
      let condition = ijoEval(expression.condition, env)

      if condition.boolVal == true:
        result = ijoEvalBody(expression.condThen, env)
      elif expression.condElse.isSome:
        result = ijoEvalBody(expression.condElse.get(), env)
    of ijoLoopExpr:
      let loop = (expression.loopInit, expression.loopCondition, expression.loopIncrement, expression.loopBody)

      case loop
        of (Some(@init), Some(@cond), Some(@incr), @body):
          discard ijoEval(init, env)

          while ijoEval(cond, env).boolVal == true:
            result = ijoEval(body, env)
            discard ijoEval(incr, env)
        of (None(), Some(@cond), Some(@incr), @body):
          while ijoEval(cond, env).boolVal == true:
            result = ijoEval(body, env)
            discard ijoEval(incr, env)
        of (None(), Some(@cond), None(), @body):
          while ijoEval(cond, env).boolVal == true:
            result = ijoEval(body, env)
        of (None(), None(), None(), @body):
          while true:
            result = ijoEval(body, env)
        else:
          echo "Wrong loop syntax"
          result = ijoValue(kind: ijoUndefined)
    of ijoListExpr, ijoUndefinedExpr, ijoErrorExpr:
      result = ijoValue(kind: ijoUndefined)

proc ijoEval(expressions: seq[ijoExpr], env: var ijoEnv): ijoValue =
  result = ijoValue(kind: ijoUndefined)

  for i, expression in expressions:
    result = ijoEval(expression, env)