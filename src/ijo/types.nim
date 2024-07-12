import std/options
import std/tables

type
  ijoType* = enum
    ijoInt,
    ijoFloat,
    ijoBool,
    ijoString,
    ijoList,
    ijoFunc,
    ijoStruct,
    ijoUndefined,
  
  ijoBuiltInFuncType* = proc(params: seq[ijoValue]): ijoValue
  ijoRecord* = TableRef[string, ijoValue]

  ijoValue* = ref object
    isMutable*: bool
    case kind*: ijoType
      of ijoInt: intVal*: int
      of ijoFloat: floatVal*: float
      of ijoBool: boolVal*: bool
      of ijoString: strVal*: string
      of ijoList: listVal*: seq[ijoValue]
      of ijoFunc:
        funcName*: string
        funcParamCount*: int
        funcParams*: seq[string]
        funcBody*: ijoExpr
        funcEnv*: ijoEnv
        builtInFunc*: ijoBuiltInFuncType = nil
      of ijoUndefined: undefinedVal* = 0
      of ijoStruct:
        structName*: string
        structRecord*: ijoRecord

  ijoEnv* = ref object
    parent*: ijoEnv
    record*: ijoRecord

  ijoExprType* = enum
    ijoIntExpr,
    ijoFloatExpr,
    ijoStringExpr,
    ijoBoolExpr,
    ijoListExpr,
    ijoBlockExpr,
    ijoConstExpr,
    ijoVarExpr,
    ijoSetIdentifierExpr,
    ijoGetIdentifierExpr,
    ijoFunctionDefinitionExpr,
    ijoFunctionCallExpr,
    ijoStructDefinitionExpr,
    ijoConditionalExpr,
    ijoLoopExpr,
    ijoUndefinedExpr,
    ijoErrorExpr

  ijoExpr* = ref object
    case kind*: ijoExprType
      of ijoIntExpr: intVal*: int
      of ijoFloatExpr: floatVal*: float
      of ijoStringExpr: strVal*: string
      of ijoBoolExpr: boolVal*: bool
      of ijoListExpr: listVal*: seq[ijoExpr]
      of ijoBlockExpr: blockVal*: seq[ijoExpr]
      of ijoConstExpr: 
        constName*: string
        constVal*: ijoExpr
      of ijoVarExpr: 
        varName*: string
        varVal*: ijoExpr
      of ijoSetIdentifierExpr: 
        setName*: string
        setVal*: ijoExpr
      of ijoGetIdentifierExpr: 
        getName*: string
      of ijoFunctionDefinitionExpr:
        funcName*: string
        funcParams*: seq[string]
        funcBody*: ijoExpr
      of ijoStructDefinitionExpr:
        structName*: string
        structBody*: seq[ijoExpr]
      of ijoFunctionCallExpr:
        callName*: string
        callParams*: seq[ijoExpr]
      of ijoConditionalExpr:
        condition*: ijoExpr
        condThen*: ijoExpr
        condElse*: Option[ijoExpr]
      of ijoLoopExpr:
        loopInit*: Option[ijoExpr]
        loopCondition*: Option[ijoExpr]
        loopIncrement*: Option[ijoExpr]
        loopBody*: ijoExpr
      of ijoUndefinedExpr: undefinedVal*: ijoExpr
      of ijoErrorExpr: errorVal*: ijoExpr