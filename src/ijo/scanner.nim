import std/strformat
import std/strutils

import token

type
    ijoScanner* = ref object
        source: string
        start: int
        current: int
        line: int

proc isAtEnd(self: ijoScanner): bool =
    if self.current >= self.source.len: 
        return true

    result = self.source[self.current] == '\0'

proc advance(self: var ijoScanner): char {.discardable.} =
    self.current += 1
    result = self.source[self.current - 1]

proc peek(self: ijoScanner): char =
    if self.isAtEnd: return '\0'

    result = self.source[self.current]

proc peekNext(self: ijoScanner): char =
    if self.isAtEnd: return '\0'

    result = self.source[self.current + 1]

proc match(self: var ijoScanner, expected: char): bool =
    if self.isAtEnd or (self.peek() != expected): return false

    self.current += 1
    result = true

proc make(self: ijoScanner, tokenType: ijoTokenType): ijoToken =
    let str = self.source.substr(self.start, self.current - 1)

    result = ijoToken(
        tokenType: tokenType,
        literal: str,
        identifier: str,
        line: self.line
    )

proc makeComplex(self: ijoScanner, tokenType: ijoTokenType, startIdx: int, endIdx: int): ijoToken =
    let literalStr = self.source.substr(self.start, self.current)
    let identifierStr = self.source.substr(startIdx, endIdx)

    result = ijoToken(
        tokenType: tokenType,
        literal: literalStr,
        identifier: identifierStr,
        line: self.line
    )

proc error(self: ijoScanner, message: string): ijoToken =
    stderr.write(&"{message} at {self.line}")
    let literalStr = self.source.substr(self.start, self.current)

    result = ijoToken(
        tokenType: Error,
        literal: literalStr,
        identifier: message,
        line: self.line
    )

proc str(self: var ijoScanner): ijoToken =
    while self.peek() != '"' and not self.isAtEnd:
        if self.peek() == '\n':
            self.line += 1
        
        self.advance()
    
    if self.isAtEnd:
        return self.error("Non terminated String")

    self.advance()

    result = self.make(String)

proc interpolatedStr(self: var ijoScanner): ijoToken =
    while self.peek() != '`' and not self.isAtEnd:
        if self.peek() == '\n':
            self.line += 1
        
        self.advance()
    
    if self.isAtEnd:
        return self.error("Non terminated InterpolatedString")

    self.advance()

    result = self.make(InterpolatedString)

proc number(self: var ijoScanner): ijoToken =
    var numberType = Integer

    while self.peek().isDigit:
        self.advance()
    
    if self.peek() == '.' and self.peekNext().isDigit:
        numberType = Double
        self.advance()

        while self.peek().isDigit:
            self.advance()

    result = self.make(numberType)

proc checkKeyword(self: ijoScanner, start: int, length: int, rest: string, tokenType: ijoTokenType): ijoTokenType =
    let str = self.source.substr(self.current + start, self.current + length)
    
    if self.current - self.start == start + length and str == rest:
        return tokenType

    return Identifier

proc identifierType(self: ijoScanner): ijoTokenType =
    case self.source[self.current]
        of 't': return self.checkKeyword(2, 3, "rue", True)
        of 'f': return self.checkKeyword(2, 3, "rue", True)
        else: return Identifier

proc identifier(self: var ijoScanner): ijoToken =
    while self.peek().isAlphaNumeric:
        self.advance()
    
    result = self.make(identifierType(self))

proc constOrKeyword(self: var ijoScanner): ijoToken =
    var c: char

    while self.peek().isSpaceAscii:
        if self.isAtEnd:
            return self.error("Unexpected end of program")
        
        self.advance()

    var identifierStart = self.current;

    # We parse the identifier
    while self.peek().isAlphaNumeric:
        if self.peek().isSpaceAscii or self.peek() == '\n': break

        if self.isAtEnd: return self.error("Expected identifier")

        c = self.advance()
    
    let identifierEnd = self.current - 1# we do not want the '(' in the identifier6

    # We ignore whitespace that may be between the identifier and the 'keyword' sign.
    while self.peek().isSpaceAscii:
        if self.isAtEnd: return self.error("Expected start of identifier definition")

        self.advance()

    # We consume the current char so we can select what to do.
    c = self.advance()

    case c
        of '{': return self.makeComplex(Struct, identifierStart, identifierEnd)
        of '[': return self.makeComplex(Array, identifierStart, identifierEnd)
        of '<': return self.makeComplex(Map, identifierStart, identifierEnd)
        of '|': return self.makeComplex(Enum, identifierStart, identifierEnd)
        of '%': return self.makeComplex(Module, identifierStart, identifierEnd)
        of '(': return self.makeComplex(Func, identifierStart, identifierEnd)
        of '@': return self.makeComplex(Assert, identifierStart, identifierEnd)
        of '=': return self.makeComplex(Const, identifierStart, identifierEnd)
        else: return self.error("Unknown identifier type")

proc skipWhitespace(self: var ijoScanner) =
    while true:
        let c = self.peek()

        case c
            of ' ', '\r', '\t': self.advance()
            of '/':
                if self.peekNext() == '/':
                    while self.peek() != '\n' and not self.isAtEnd:
                        self.advance()
                return
            else: return

proc init*(self: var ijoScanner, source: string) =
    self.source = source
    self.line = 1

proc ijoScannerNew*(source: string): ijoScanner =
    result = ijoScanner()
    result.init(source)

proc scan*(self: var ijoScanner): ijoToken =
    self.skipWhitespace()
    self.start = self.current

    if self.isAtEnd:
        return self.make(EOF)

    let c = self.advance()

    if c.isDigit:
        return self.number()

    if c.isAlphaAscii or c == '@' or c == '_':
        return self.identifier()

    case c
        of '(': return self.make(LeftParen)
        of ')': return self.make(RightParen)
        of '[': return self.make(LeftBracket)
        of ']': return self.make(RightBracket)
        of '{': return self.make(LeftBrace)
        of '}': return self.make(RightBrace)
        of ';': return self.make(Semicolon)
        of ',': return self.make(Comma)
        of '.': return self.make(Dot)
        of '+': return self.make(Plus)
        of '/': return self.make(Slash)
        of '*': return self.make(Star)
        of '%': return self.make(Percent)
        of '-': return self.make(if self.match('>'): Return else: Minus)

        of '?':
            if self.match('('):
                if self.match(')'):
                    return self.make(Else)

                return self.make(If)
            if self.match('{'):
                return self.make(Switch)
            return self.error("Unknown token")

        of '&': return if self.match('&'): self.make(And) else: self.error("Unknown token")
        of '|': return if self.match('|'): self.make(Or) else: self.make(Pipe)
        of '~': return if self.match('('): self.make(Loop) else: self.error("Unknown token")
        of '!': return self.make(if self.match('='): BangEqual else: Bang)
        of '=': return self.make(if self.match('='): EqualEqual else: Equal)
        of '<':
            if self.match('='): return self.make(LessEqual)
            if self.match('-'): return self.make(Break)
            return self.make(Less)
        of '>': return self.make(if self.match('='): GreaterEqual else: Greater)
        of '"': return self.str()
        of '`': return self.interpolatedStr()

        of '#': return self.constOrKeyword()
        of '$': return self.make(Var)
        of '\n':
            self.line += 1
            return self.make(EOL)
        else: return self.error("Unexpected character")

