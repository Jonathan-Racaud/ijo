import std/strutils
import std/strformat

import expression
import scanner
import types
import token

const parseRuleCount = int(EOL) + 1

type
    ijoParser = object
        scanner: ijoScanner
        previous: ijoToken
        current: ijoToken
        hadError: bool
        parsingLoop: bool
        precedence: Precedence
        scopeDepth: int
        rules: array[parseRuleCount, ParseRule]

    Precedence = enum
        None,
        Assigment,
        Or,
        And,
        Equality,
        Comparison,
        Term,
        Factor,
        Unary,
        Call,
        Primary
    
    ParseFunc = proc(self: var ijoParser): ijoExpr
    
    ParseRule = object
        prefix: ParseFunc
        infix: ParseFunc
        precedence: Precedence
        acceptedTokens: set[ijoTokenType]

    ParserError = enum
        ErrorMultipleExpressionPerLine = "Only one expression per line accepted"
        ErrorNotImplemented = "Feature not implemented"
        ErrorMissingLeftBrace = "Expected '{'"
        ErrorMissingRightBrace = "Expected '}' after expression"
        ErrorMissingLeftParen = "Expected '('"
        ErrorMissingRightParen = "Expected ')' after expression"
        ErrorExpectedExpression = "Expected an expression"
        ErrorInvalidToken = "Invalid token"
        ErrorInvalidExpression = "Invalid expression"
        ErrorFailedParsing = "Failed to parse program"
        ErrorGlobalScopeVariable = "Global scope cannot have variables. Only constants, functions (call, def) and type definition"
        ErrorExpectedVariableName = "Expected variable name"
        ErrorDeclarationMustHaveValue = "Declaration must have a value"
        ErrorIncorrectLoop = "Wrong loop expression format. Expected one of:\n  ~(initializer; condition; increment) {...}\n  ~(condition;increment){...}\n  ~(condition){...}\n  ~(){...}"
        ErrorExpectedBooleanExpression = "Expected a boolean expression"
        ErrorExpectedComma = "Expected a comma"
        ErrorMissingPipe = "Expected '|'"
        ErrorExpectedSwitchDefault = "Switch statements must be terminated by '?()'"

proc errorAt(self: var ijoParser, token: ijoToken, message: string) =
    stderr.write(&"line {token.line} ")

    if token.tokenType == EOF:
        stderr.write(&" at end ")
    elif token.tokenType == Error:
        discard
    else:
        stderr.write(&" at {token.literal} ")
    
    stderr.write(message)
    stderr.write("\n")

    self.hadError = true

proc errorAtCurrent(self: var ijoParser, message: string) =
    self.errorAt(self.previous, message)

# proc checkIsOperator(self: var ijoParser): bool =
#     case self.current.tokenType
#         of EqualEqual, Less, LessEqual, Greater, GreaterEqual, BangEqual: return true
#         else: return false

proc check(self: var ijoParser, expected: ijoTokenType): bool =
    result = self.current.tokenType == expected

proc advance(self: var ijoParser) =
    self.previous = self.current

    while true:
        self.current = self.scanner.scan()

        if self.current.tokenType != Error: break

        self.errorAtCurrent("")

proc match(self: var ijoParser, expected: ijoTokenType): bool =
    if not self.check(expected): return false

    self.advance()
    return true

proc consume(self: var ijoParser, expected: ijoTokenType, message: string): bool =
    if self.check(expected):
        self.advance()
        return true

    self.errorAtCurrent(message)
    return false

##################### 
## Parse functions ##
#####################

# Forward declaration
proc getRuleFrom(self: ijoParser, tokenType: ijoTokenType): ParseRule
proc parseBlockExpression(self: var ijoParser): ijoExpr
proc parseVarExpression(self: var ijoParser): ijoExpr
proc parseStatementExpression(self: var ijoParser): ijoExpr
proc parseInternal(self: var ijoParser): ijoExpr

proc parsePrecedence(self: var ijoParser, expected: Precedence): ijoExpr =
    self.advance()

    let rule = self.getRuleFrom(self.previous.tokenType)

    if not rule.acceptedTokens.contains(self.current.tokenType):
        self.errorAt(self.current, $ErrorInvalidToken)

    if rule.prefix == nil:
        stderr.write($ErrorExpectedExpression)
        return errorExpr($ErrorExpectedExpression)

    self.precedence = expected
    let prefix: ijoExpr = rule.prefix(self)

    while int(self.precedence) <= int(self.getRuleFrom(self.current.tokenType).precedence):
        self.advance()

        let op = self.previous
        let infixRule = self.getRuleFrom(self.previous.tokenType).infix

        let infix: ijoExpr = self.infixRule()

        return functionCallExpr(op.literal, @[prefix, infix])
    
    result = prefix

proc parseExpression(self: var ijoParser): ijoExpr =
    result = self.parsePrecedence(Assigment)

proc parseNoopExpression(self: var ijoParser): ijoExpr =
    result = undefinedExpr()

proc parseOrExpression(self: var ijoParser): ijoExpr =
    result = self.parsePrecedence(Or)

proc parseAndExpression(self: var ijoParser): ijoExpr =
    result = self.parsePrecedence(And)

proc parseFunctionDefExpression(self: var ijoParser): ijoExpr =
    let typ = self.previous.tokenType
    let identifier = if typ == Func: self.previous.identifier else: "anon"

    # We do not need to consume the '(' as it has already been scanned and is part of
    # the literal for the token. It was consume to know we were dealing with a function
    # since there's no keyword for defining functions.

    var parameters: seq[string]

    while not self.check(RightParen) and not self.check(EOF):
        self.advance()
        parameters.add(self.previous.literal)

        if not self.check(RightParen) and not self.consume(Comma, $ErrorExpectedComma):
            return errorExpr($ErrorExpectedComma)
    
    if not self.consume(RightParen, $ErrorMissingRightParen):
        return errorExpr($ErrorMissingRightParen)

    if not self.consume(LeftBrace, $ErrorMissingLeftBrace):
        return errorExpr($ErrorMissingLeftBrace)

    var body = self.parseBlockExpression()

    # TODO: Reimplement lambda
    result = functionDefinitionExpr(identifier, parameters, body)

proc parseFunctionCallExpression(self: var ijoParser, identifier: string): ijoExpr =
    var expressions: seq[ijoExpr]

    while not self.check(RightParen) and not self.check(EOF):
        expressions.add(self.parseExpression())

        if self.check(Comma):
            self.advance()
        elif not self.check(RightParen):
            self.errorAtCurrent($ErrorInvalidExpression)
            return errorExpr($ErrorInvalidExpression)
    
    if not self.consume(RightParen, $ErrorMissingRightParen):
        return errorExpr($ErrorMissingRightParen)

    functionCallExpr(identifier, expressions)

proc parseIdentifierExpression(self: var ijoParser): ijoExpr =
    let identifier = self.previous.literal
    var canAssign = int(self.precedence) <= int(Assigment)

    case identifier
        of "true": return boolExpr(true)
        of "false": return boolExpr(false)
        else: discard
    
    if canAssign and self.match(Equal):
        let expression = self.parseExpression()

        return setIdentifierExpr(identifier, expression)

    if self.match(LeftParen):
        return self.parseFunctionCallExpression(identifier)

    result = getIdentifierExpr(identifier)

proc parseLiteralExpression(self: var ijoParser): ijoExpr =
    result = self.parseIdentifierExpression()

proc parseInterpolatedStringExpression(self: var ijoParser): ijoExpr =
    result = errorExpr($ErrorNotImplemented)

proc parseStringExpression(self: var ijoParser): ijoExpr =
    var str = self.previous.literal
    str.removePrefix('"')
    str.removeSuffix('"')

    return stringExpr(str)

proc parseFloatExpression(self: var ijoParser): ijoExpr =
    result = floatExpr(parseFloat(self.previous.literal))

proc parseIntegerExpression(self: var ijoParser): ijoExpr =
    result = intExpr(parseInt(self.previous.literal))

proc parseGroupingExpression(self: var ijoParser): ijoExpr =
    var expressions: seq[ijoExpr]

    while not self.check(RightParen) and not self.check(EOF):
        if not self.check(EOL):
            self.advance()
        
        expressions.add(self.parseExpression())
    
    if not self.consume(RightParen, $ErrorMissingRightParen):
        return errorExpr($ErrorMissingRightParen)

    result = blockExpr(expressions)

proc parseBinaryExpression(self: var ijoParser): ijoExpr =
    let rule = self.getRuleFrom(self.previous.tokenType)

    let precedence = cast[Precedence](int(rule.precedence) + 1)
    return self.parsePrecedence(precedence)

proc parseUnaryExpression(self: var ijoParser): ijoExpr =
    let operatorType = self.previous
    let expression = self.parsePrecedence(Unary)

    result = functionCallExpr(operatorType.literal, @[expression])

proc parseBlockExpression(self: var ijoParser): ijoExpr =
    var expressions: seq[ijoExpr]

    self.scopeDepth += 1
    defer: self.scopeDepth -= 1

    while not self.check(RightBrace) and not self.check(EOF):
        if self.check(EOL):
            self.advance()
            continue

        expressions.add(self.parseInternal())
    
    if not self.consume(RightBrace, $ErrorMissingRightBrace):
        return errorExpr($ErrorMissingRightBrace)

    return blockExpr(expressions)

proc parseLoopBody(self: var ijoParser): ijoExpr =
    if not self.match(LeftBrace):
        self.errorAtCurrent($ErrorMissingLeftBrace)
        self.hadError = true
        return errorExpr($ErrorMissingLeftBrace)

    result = self.parseBlockExpression()

proc parseLoopExpression(self: var ijoParser): ijoExpr =
    if self.match(Semicolon):
        return errorExpr($ErrorIncorrectLoop)

    self.hadError = false

    result = errorExpr()
    var first = errorExpr()
    var second = errorExpr()
    var third = errorExpr()
    var body = errorExpr()

    var parsedStatements = 0
    self.parsingLoop = true

    if self.match(RightParen):
        body = self.parseLoopBody()
    else:
        if self.match(Var):
            first = self.parseVarExpression()
            parsedStatements += 1
        else:
            first = self.parseExpression()
            parsedStatements += 1
        
        if self.match(Semicolon):
            if self.match(Var):
                self.errorAtCurrent($ErrorExpectedBooleanExpression)
                self.parsingLoop = false
                self.hadError = true

                return errorExpr($ErrorExpectedBooleanExpression)

            second = self.parseExpression()
            parsedStatements += 1
        
        if self.match(Semicolon):
            if self.match(Var):
                self.errorAtCurrent($ErrorExpectedExpression)
                self.parsingLoop = false
                self.hadError = true

                return errorExpr($ErrorExpectedExpression)

            second = self.parseExpression()
            parsedStatements += 1
        
        if not self.consume(RightParen, $ErrorMissingRightParen):
            self.hadError = true
            return errorExpr($ErrorMissingRightParen)
        
        body = self.parseLoopBody()
    
    case parsedStatements
        of 0: result = loopExpr(body)
        of 1: result = loopExpr(first, body)
        of 2: result = loopExpr(first, second, body)
        of 3: result = loopExpr(first, second, third, body)
        else:
            self.errorAtCurrent($ErrorIncorrectLoop)
            self.hadError = true
            return errorExpr($ErrorIncorrectLoop)

proc parseIfExpression(self: var ijoParser): ijoExpr =
    let condition = self.parseExpression()

    if not self.consume(RightParen, $ErrorMissingRightParen):
        return errorExpr($ErrorMissingRightParen)

    let body = self.parseStatementExpression()

    if self.match(Else):
        let otherwise = self.parseStatementExpression()
        return ifExpr(condition, body, otherwise)
    
    result = ifExpr(condition, body)

#    ?{expression}
#      42 {
#	    @>>("The answer to everthying, the universe and the rest" )
#      }
#      "Hello" {
#	    @>>("Goodbye")
#      }
#     _0 > 18 && _0 < 65 {}
#	?() {}
proc parseSwitchExpression(self: var ijoParser): ijoExpr =
    result = errorExpr($ErrorNotImplemented)

proc parseReturnExpression(self: var ijoParser): ijoExpr =
    result = errorExpr($ErrorNotImplemented)

proc parseStructExpression(self: var ijoParser): ijoExpr =
    let identifier = self.previous.identifier
    let body = self.parseBlockExpression()

    return constExpr(identifier, body)

proc parseVariable(self: var ijoParser): string =
    if self.match(Identifier):
        return self.previous.literal
    
    return ""

proc parseConstExpression(self: var ijoParser): ijoExpr =
    let identifier = self.previous.identifier

    if self.check(EOF) or self.check(EOL):
        return errorExpr($ErrorMultipleExpressionPerLine)

    return constExpr(identifier, self.parseExpression())

proc parseVarExpression(self: var ijoParser): ijoExpr =
    if self.scopeDepth == 0:
        return errorExpr($ErrorGlobalScopeVariable)

    var name: string
    let parseResult = self.parseVariable()

    if parseResult != "":
        name = parseResult
    else:
        return errorExpr($ErrorExpectedVariableName)
    
    var expression = errorExpr()
    if self.match(Equal):
        expression = self.parseExpression()
    else:
        self.errorAtCurrent($ErrorDeclarationMustHaveValue)
    
    if not self.parsingLoop:
        if not self.consume(EOL, $ErrorMultipleExpressionPerLine):
            return errorExpr($ErrorMultipleExpressionPerLine)
    
    result = varExpr(name, expression)

proc parseStatementExpression(self: var ijoParser): ijoExpr =
    # This might be removed entirely. Depends on if we need this type of expression or not
    # if self.match(Builtin):
    #     result = self.parseBuiltinExpression()
    # el
    if self.match(If):
        result = self.parseIfExpression()
    elif self.match(Switch):
        result = self.parseSwitchExpression()
    elif self.match(Loop):
        result = self.parseLoopExpression()
    elif self.match(LeftBrace):
        result = self.parseBlockExpression()
    
    result = self.parseExpression()

    if not self.parsingLoop and not self.check(EOL) and not self.check(RightBrace) and not self.check(Dot):
        if not self.consume(EOL, $ErrorMultipleExpressionPerLine):
            return errorExpr($ErrorMultipleExpressionPerLine)

proc parseInternal(self: var ijoParser): ijoExpr =
    result = errorExpr()

    if self.match(Const):
        result = self.parseConstExpression()
    elif self.match(Var):
        result = self.parseVarExpression()
    elif self.match(Struct):
        result = self.parseStructExpression()
    elif self.match(Return):
        result = self.parseReturnExpression()
    else:
        result = self.parseStatementExpression()
    
    if result.kind == ijoErrorExpr:
        return errorExpr($ErrorInvalidExpression)

proc newParseRule(prefix: ParseFunc, infix: ParseFunc, precedence: Precedence, acceptedTokens: set[ijoTokenType]): ParseRule =
    result = ParseRule(prefix: prefix, infix: infix, precedence: precedence, acceptedTokens: acceptedTokens)

proc initRules(self: var ijoParser) =
    self.rules[int(Comma)]       = newParseRule(nil, nil, None, AllToken)
    self.rules[int(Dot)]         = newParseRule(parseExpression, nil, None, AllToken)
    self.rules[int(LeftBrace)]   = newParseRule(nil, nil, None, AllToken)
    self.rules[int(LeftParen)]   = newParseRule(parseGroupingExpression, nil, None, AllToken)
    self.rules[int(Minus)]       = newParseRule(parseUnaryExpression, parseBinaryExpression, Term, {Integer, Double})
    self.rules[int(Plus)]        = newParseRule(nil, parseBinaryExpression, Term, {Integer, Double})
    self.rules[int(RightBrace)]  = newParseRule(nil, nil, None, AllToken)
    self.rules[int(RightParen)]  = newParseRule(nil, nil, None, AllToken)
    self.rules[int(Semicolon)]   = newParseRule(nil, nil, None, AllToken)
    self.rules[int(Slash)]       = newParseRule(nil, parseBinaryExpression, Factor, {Integer, Double})
    self.rules[int(Star)]        = newParseRule(nil, parseBinaryExpression, Factor, {Integer, Double})
    self.rules[int(Percent)]     = newParseRule(nil, parseBinaryExpression, None, AllToken)
    
    self.rules[int(Bang)]            = newParseRule(parseUnaryExpression, nil, None, AllToken)
    self.rules[int(BangEqual)]       = newParseRule(nil, parseBinaryExpression, Equality, AllToken)
    self.rules[int(Equal)]           = newParseRule(nil, nil, None, AllToken)
    self.rules[int(EqualEqual)]      = newParseRule(nil, parseBinaryExpression, Equality, AllToken)
    self.rules[int(Greater)]         = newParseRule(nil, parseBinaryExpression, Comparison, AllToken)
    self.rules[int(GreaterEqual)]    = newParseRule(nil, parseBinaryExpression, Comparison, AllToken)
    self.rules[int(Less)]            = newParseRule(nil, parseBinaryExpression, Comparison, AllToken)
    self.rules[int(LessEqual)]       = newParseRule(nil, parseBinaryExpression, Comparison, AllToken)

    self.rules[int(Identifier)]          = newParseRule(parseIdentifierExpression, nil, None, AllToken)
    self.rules[int(Integer)]             = newParseRule(parseIntegerExpression, nil, None, AllToken)
    self.rules[int(Double)]              = newParseRule(parseFloatExpression, nil, None, AllToken)
    self.rules[int(String)]              = newParseRule(parseStringExpression, nil, None, AllToken)
    self.rules[int(InterpolatedString)]  = newParseRule(parseInterpolatedStringExpression, nil, None, AllToken)

    self.rules[int(And)]     = newParseRule(nil, parseAndExpression, And, AllToken)
    self.rules[int(Array)]   = newParseRule(nil, nil, None, AllToken)
    self.rules[int(Assert)]  = newParseRule(nil, nil, None, AllToken)
    self.rules[int(Else)]    = newParseRule(nil, nil, None, AllToken)
    self.rules[int(Enum)]    = newParseRule(nil, nil, None, AllToken)
    self.rules[int(False)]   = newParseRule(parseLiteralExpression, nil, None, AllToken)
    self.rules[int(Func)]    = newParseRule(parseFunctionDefExpression, nil, None, AllToken)
    self.rules[int(Lambda)]  = newParseRule(parseFunctionDefExpression, nil, None, AllToken)
    self.rules[int(If)]      = newParseRule(nil, nil, None, AllToken)
    self.rules[int(Map)]     = newParseRule(nil, nil, None, AllToken)
    self.rules[int(Module)]  = newParseRule(nil, nil, None, AllToken)
    self.rules[int(Or)]      = newParseRule(nil, parseOrExpression, Or, AllToken)
    self.rules[int(Builtin)] = newParseRule(nil, nil, None, AllToken)
    self.rules[int(Return)]  = newParseRule(parseReturnExpression, nil, None, AllToken)
    self.rules[int(Struct)]  = newParseRule(nil, nil, None, AllToken)
    self.rules[int(This)]    = newParseRule(nil, nil, None, AllToken)
    self.rules[int(True)]    = newParseRule(parseLiteralExpression, nil, None, AllToken)
    self.rules[int(Var)]     = newParseRule(nil, nil, None, AllToken)
    self.rules[int(Loop)]    = newParseRule(nil, nil, None, AllToken)

    self.rules[int(Error)]   = newParseRule(nil, nil, None, AllToken)
    self.rules[int(EOL)]     = newParseRule(parseNoopExpression, parseNoopExpression, None, AllToken)
    self.rules[int(EOF)]     = newParseRule(parseNoopExpression, parseNoopExpression, None, AllToken)

proc parserNew*(scanner: ijoScanner): ijoParser =
    var p = ijoParser(scanner: scanner)
    p.initRules()

    result = p

proc parse*(self: var ijoParser): seq[ijoExpr] =
    self.advance()

    var expressions: seq[ijoExpr] = @[]

    while not self.match(EOF):
        if self.match(EOL):
            continue
        
        expressions.add(self.parseInternal())

proc getRuleFrom(self: ijoParser, tokenType: ijoTokenType): ParseRule =
    return self.rules[int(tokenType)]