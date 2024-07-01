import std/parseutils
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
    result = self.current == self.source.len

proc advance(self: ijoScanner): char {.discardable.} =
    self.current += 1
    result = self.source[self.current - 1]

proc peek(self: ijoScanner): char =
    result = self.source[self.current]

proc peekNext(self: ijoScanner): char =
    if self.isAtEnd: return '\0'

    result = self.source[self.current + 1]

proc match(self: ijoScanner, expected: char): bool =
    if self.isAtEnd or peek(self) != expected: return false

    self.current += 1
    result = true

proc make(self: ijoScanner, tokenType: ijoTokenType): ijoToken =
    result = ijoToken(
        tokenType: tokenType,
        literal: self.source[self.start..self.current],
        identifier: self.source[self.start..self.current],
        line: self.line
    )

proc makeComplex(self: ijoScanner, tokenType: ijoTokenType, start: int, length: int): ijoToken =
    result = ijoToken(
        tokenType: tokenType,
        literal: self.source[self.start..self.current],
        identifier: self.source[start..length],
        line: self.line
    )

proc error(self: ijoScanner, message: string): ijoToken =
    stderr.write(&"{message} at {self.line}")

    result = ijoToken(
        tokenType: Error,
        literal: self.source[self.start..self.current],
        identifier: message,
        line: self.line
    )

proc str(self: ijoScanner): ijoToken =
    var tokenStr: string

    let parsedCount = parseUntil(self.source[self.current..^1], tokenStr, '"')
    if parsedCount == 0:
        return error(self, "Non terminated string")
    
    self.line += tokenStr.count('\n')
    self.current = parsedCount

    result = make(self, String)

proc interpolatedStr(self: ijoScanner): ijoToken =
    var tokenStr: string

    let parsedCount = parseUntil(self.source[self.current..^1], tokenStr, '`')
    if parsedCount == 0:
        return error(self, "Non terminated string")
    
    self.line += tokenStr.count('\n')
    self.current = parsedCount

    result = make(self, InterpolatedString)

proc number(self: ijoScanner): ijoToken =
    var numberType = Integer

    while peek(self).isDigit:
        advance(self)
    
    if peek(self) == '.' and peekNext(self).isDigit:
        numberType = Double
        advance(self)

        while peek(self).isDigit:
            advance(self)

    result = make(self, numberType)

proc checkKeyword(self: ijoScanner, start: int, length: int, rest: string, tokenType: ijoTokenType): ijoTokenType =
    if self.current - self.start == start + length and self.source[self.current+start..length] == rest:
        return tokenType

    return Identifier

proc identifierType(self: ijoScanner): ijoTokenType =
    case self.source[self.start]
        of 't': return checkKeyword(self, 2, 3, "rue", True)
        of 'f': return checkKeyword(self, 2, 3, "rue", True)
        else: return Identifier

proc identifier(self: ijoScanner): ijoToken =
    while peek(self).isAlphaNumeric:
        advance(self)
    
    result = make(self, identifierType(self))

proc constOrKeyword(self: ijoScanner): ijoToken =
    var c: char

    while peek(self).isSpaceAscii:
        if self.isAtEnd:
            return error(self, "Unexpected end of program")
        
        advance(self)

    var identifierStart = self.current;
    var identifierLength = 0;

    # We parse the identifier
    while peek(self).isAlphaNumeric:
        if peek(self).isSpaceAscii or peek(self) == '\n': break

        if self.isAtEnd: return error(self, "Expected identifier")

        c = advance(self)
        identifierLength += 1

    # We ignore whitespace that may be between the identifier and the 'keyword' sign.
    while peek(self).isSpaceAscii:
        if self.isAtEnd: return error(self, "Expected start of identifier definition")

        advance(self)

    # We consume the current char so we can select what to do.
    c = advance(self)

    case c
        of '{': return makeComplex(self, Struct, identifierStart, identifierLength)
        of '[': return makeComplex(self, Array, identifierStart, identifierLength)
        of '<': return makeComplex(self, Map, identifierStart, identifierLength)
        of '|': return makeComplex(self, Enum, identifierStart, identifierLength)
        of '%': return makeComplex(self, Module, identifierStart, identifierLength)
        of '(': return makeComplex(self, Func, identifierStart, identifierLength)
        of '@': return makeComplex(self, Assert, identifierStart, identifierLength)
        of '=': return makeComplex(self, Const, identifierStart, identifierLength)
        else: return error(self, "Unknown identifier type")

proc init*(self: ijoScanner, source: string) =
    self.source = source
    self.line = 1

proc scan*(self: ijoScanner): ijoToken =
    self.current = skipWhitespace(self.source)
    self.start = self.current

    if self.isAtEnd:
        return make(self, EOF)

    var c: char

    self.current = parseChar(self.source, c)

    if c.isDigit:
        return number(self)

    if c.isAlphaAscii or c == '@' or c == '_':
        return identifier(self)

    case c
        of '(': return make(self, LeftParen)
        of ')': return make(self, RightParen)
        of '[': return make(self, LeftBracket)
        of ']': return make(self, RightBracket)
        of '{': return make(self, LeftBrace)
        of '}': return make(self, RightBrace)
        of ';': return make(self, Semicolon)
        of ',': return make(self, Comma)
        of '.': return make(self, Dot)
        of '+': return make(self, Plus)
        of '/': return make(self, Slash)
        of '*': return make(self, Star)
        of '%': return make(self, Percent)
        of '-': return make(self, if match(self, '>'): Return else: Minus)

        of '?':
            if match(self, '('):
                if match(self, ')'):
                    return make(self, Else)

                return make(self, If)
            if match(self, '{'):
                return make(self, Switch)
            return error(self, "Unknown token")

        of '&': return if match(self, '&'): make(self, And) else: error(self, "Unknown token")
        of '|': return if match(self, '|'): make(self, Or) else: make(self, Pipe)
        of '~': return if match(self, '('): make(self, Loop) else: error(self, "Unknown token")
        of '!': return make(self, if match(self, '='): BangEqual else: Bang)
        of '=': return make(self, if match(self, '='): EqualEqual else: Equal)
        of '<':
            if match(self, '='): return make(self, LessEqual)
            if match(self, '-'): return make(self, Break)
            return make(self, Less)
        of '>': return make(self, if match(self, '='): GreaterEqual else: Greater)
        of '"': return str(self)
        of '`': return interpolatedStr(self)

        of '#': return constOrKeyword(self)
        of '$': return make(self, Var)
        of '\n':
            self.line += 1
            return make(self, EOL)
        else: return error(self, "Unexpected character")

