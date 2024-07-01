type
    ijoTokenType* = enum
        Error = 0,
        EOF = 1,

        Call = 2,

        Comma = 3,
        Dot = 4,
        LeftBrace = 5,
        LeftParen = 6,
        Minus = 7,
        Plus = 8,
        RightBrace = 9,
        RightParen = 10,
        LeftBracket = 11,
        RightBracket = 12,
        Pipe = 13,
        Semicolon = 14,
        Slash = 15,
        Star = 16,
        Percent = 17,

        # One or two character tokens.
        Bang = 18,
        BangEqual = 19,
        Equal = 20,
        EqualEqual = 21,
        Greater = 22,
        GreaterEqual = 23,
        Less = 24,
        LessEqual = 25,

        # Literals.
        Identifier = 26,
        Integer = 27,
        Double = 28,
        String = 29,
        InterpolatedString = 30,

        # KeySymbols. They act like keywords, but use symbols instead.
        And = 31,
        Array = 32,
        Assert = 33,
        Const = 34,
        Else = 35,
        Enum = 36,
        False = 37,
        Func = 38,
        Lambda = 39,
        If = 40,
        Switch = 41,
        SwitchDefault = 42,
        Map = 43,
        Module = 44,
        Or = 45,
        Print = 46,
        PrintLn = 47,
        Return = 48,
        Break = 49,
        Struct = 50,
        Super = 51,
        This = 52,
        True = 53,
        Var = 54,
        Loop = 55,

        Builtin = 56,

        # Acts like ';' in other languages. Kind of.
        EOL = 57

    ijoToken* = object
        tokenType*: ijoTokenType
        literal*: string
        identifier*: string
        line*: int

const
    # For when a parsing rule can accept any kind of token.
    # Except the ERROR and EOF.
    AllToken* = {
        Call,
        Comma,
        Dot,
        Minus,
        Plus,
        Slash,
        Star,
        Percent,
        Pipe,
        Semicolon,
        LeftBrace,
        LeftParen,
        LeftBracket,
        RightBrace,
        RightParen,
        RightBracket,

        # One or two character tokens.
        Bang,
        BangEqual,
        Equal,
        EqualEqual,
        Greater,
        GreaterEqual,
        Less,
        LessEqual,

        # Literals.
        Identifier,
        Integer,
        Double,
        String,
        InterpolatedString,

        # KeySymbols. They act like keywords, but use symbols instead.
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
        
        # Acts like ';' in other languages. Kind of.
        EOL}