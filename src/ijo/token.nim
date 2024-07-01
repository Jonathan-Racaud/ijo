type
    ijoTokenType* = enum
        Error,
        EOF,

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
        RightBracket

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
        EOL,

    ijoToken* = object
        tokenType*: ijoTokenType
        literal*: string
        identifier*: string
        line*: int

const
    # For when a parsing rule can accept any kind of token.
    # Except the ERROR and EOF.
    AllToken* = {
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