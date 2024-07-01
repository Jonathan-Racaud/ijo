using System;
using System.Collections;

namespace ijo;

enum TokenType: int
{
    Error,
    EOF,

    Call,

    Comma,
    Dot,
    LeftBrace,
    LeftParen,
    Minus,
    Plus,
    RightBrace,
    RightParen,
    LeftBracket,
    RightBracket,
    Pipe,
    Semicolon,
    Slash,
    Star,
    Percent,

    // One or two character tokens.
    Bang,
    BangEqual,
    Equal,
    EqualEqual,
    Greater,
    GreaterEqual,
    Less,
    LessEqual,

    // Literals.
    Identifier,
    Integer,
    Double,
    String,
    InterpolatedString,

    // KeySymbols. They act like keywords, but use symbols instead.
    And,
    Array,
    Assert,
    Const,
    Else,
    Enum,
    False,
    Func,
    Lambda,
    If,
    Switch,
    SwitchDefault,
    Map,
    Module,
    Or,
    Print,
    PrintLn,
    Return,
    Break,
    Struct,
    Super,
    This,
    True,
    Var,
    Loop,

    Builtin,

    // Acts like ';' in other languages. Kind of.
    EOL,

    // For when a parsing rule can accept any kind of token.
    // Except the ERROR and EOF.
    // All = ~((1 << Error.Underlying) | (1 << EOF.Underlying))
    All =
		Error | EOF |
		Call | Comma | Dot |
		LeftBrace | LeftParen | RightBrace | RightParen | LeftBracket | RightBracket | Pipe |
		Minus | Plus | Slash | Star | Percent |
		Bang | BangEqual | Equal | EqualEqual | Greater | GreaterEqual | Less | LessEqual |
		Semicolon |
		Identifier | Integer | Double | String | InterpolatedString |
		And | Array | Assert |
		Const | Else | Enum | False | Func | Lambda |
		If | Switch | SwitchDefault | Map | Module | Or | Print | PrintLn | Return | Struct | Super | This | True | Var | Loop | Builtin | EOL
}

struct Token
{
    public TokenType Type;
    public StringView Literal;
    public StringView Identifier;
    public int Line;
}

typealias TokenList = List<Token>;