using System;

namespace ijo;

class Scanner
{
    private String source;
    private char8* start;
    private char8* current;
    private int line;

    public this(String sourceCode)
    {
        source = sourceCode;
        source.EnsureNullTerminator();

        start = source.Ptr;
        current = start;
        line = 1;
    }

    public Token Scan()
    {
        SkipWhitespace();

        start = current;

        if (IsAtEnd)
		{
            return Make(.EOF);
		}

        let c = Advance();

        if (c.IsDigit)
        {
            return Number();
        }

        if (c.IsLetter || (c == '@') || (c == '_'))
        {
            return Identifier();
        }

        switch (c)
        {
        case '(': return Make(.LeftParen);
        case ')': return Make(.RightParen);
        case '{': return Make(.LeftBrace);
        case '}': return Make(.RightBrace);
        case '[': return Make(.LeftBracket);
        case ']': return Make(.RightBracket);
        case ';': return Make(.Semicolon);
        case ',': return Make(.Comma);
        case '.': return Make(.Dot);
        case '+': return Make(.Plus);
        case '/': return Make(.Slash);
        case '%': return Make(.Percent);
        case '*': return Make(.Star);
        case '-': return Make(Match('>') ? .Return : .Minus);

        case '?':
            if (Match('('))
            {
                if (Match(')'))
                {
                    return Make(.Else);
                }

                return Make(.If);
            }
            if (Match('{'))
            {
                return Make(.Switch);
            }
            return Error("Unknown token");
        case '&': return Match('&') ? Make(.And) : Error("Unknown token");
        case '|': return Match('|') ? Make(.Or) : Make(.Pipe);
        case '~': return Match('(') ? Make(.Loop) : Error("Unknown token");
        case '!': return Make(Match('=') ? .BangEqual : .Bang);
        case '=': return Make(Match('=') ? .EqualEqual : .Equal);
        case '<':
			if (Match('='))
				return Make(.LessEqual);
			else if (Match('-'))
				return Make(.Break);
			else
                return Make(.Less);
        case '>': return Make(Match('=') ? .GreaterEqual : .Greater);
        case '\\': return Builtin();
        case '"': return Str();
        case '`': return InterpolatedStr();

        /**
        * In ijo a 'Keyword' is the combination of '#' + identifier + one of the
        * symbols used in the switch inside of the varOrKeyword function.
        */
        case '#': return ConstOrKeyword();
        case '$': return Make(.Var);
        case '\n':
            line++;
			return Make(.EOL);
        }

        return Error("Unexpected character");
    }

    Token Make(TokenType type)
    {
        return Token() {
            Type = type,
            Literal = .(start, current - start),
            Identifier = .(start, current - start),
            Line = line
		};
    }

    Token MakeComplexe(TokenType type, char8 *identifierStart, int length)
    {
        return Token() {
            Type = type,
            Literal = .(start, current - start),
            Identifier = .(identifierStart, length),
            Line = line
		};
    }

    Token Error(StringView message)
    {
        Console.Error.WriteLine(scope $"{message} at line {line}");

        return Token() {
            Type = .Error,
            Literal = .(start, current - start),
            Identifier = message,
            Line = line
		};
    }

    Token Str()
    {
        while (Peek() != '"' && !IsAtEnd)
        {
            if (Peek() == '\n')
            {
                line++;
            }

            Advance();
        }

        if (IsAtEnd)
        {
            return Error("Non terminated String");
        }

        Advance();

        return Make(.String);
    }

    Token InterpolatedStr()
    {
        while (Peek() != '`' && !IsAtEnd)
        {
            if (Peek() == '\n')
            {
                line++;
            }

            Advance();
        }

        if (IsAtEnd)
        {
            return Error("Non terminated String");
        }

        Advance();

        return Make(.String);
    }

    Token Number()
    {
        TokenType numberType = .Integer;

        while (Peek().IsDigit)
        {
            Advance();
        }

        // Look for a fractional part.
        if (Peek() == '.' && PeekNext().IsDigit)
        {
            numberType = .Double;
            // Consume the '.'
            Advance();

            while (Peek().IsDigit)
            {
                Advance();
            }
        }

        return Make(numberType);
    }

    Token Identifier()
    {
        while (Peek().IsLetterOrDigit)
        {
            Advance();
        }

        return Make(IdentifierType());
    }

    // A builtin call is a function call hence the expected syntax is:
    // \>>("Hello World") -> This is a println call
    // \>(42) -> This is a print call
    // $name = \<() This is a read from stdin
    Token Builtin()
    {
        while (true)
        {
            switch (Peek())
            {
            case '\n', '\t', '\r', ' ': return Error("Expected '('");
            default: break;
            }

            if (Peek() == '(') break;

            Advance();
        }

        return Make(.Builtin);
    }

    Token ConstOrKeyword()
    {
        char8 c;

        while (IsWhitespace(Peek()))
        {
            if (IsAtEnd)
            {
                return Error("Unexpected end of program");
            }

            Advance();
        }

        var identifierStart = current;
        var identifierLength = 0;

        // We parse the identifier
        while (Peek().IsLetterOrDigit)
        {
            if (IsWhitespace(Peek()) || Peek() == '\n') break;

            if (IsAtEnd) return Error("Expected identifier");

            c = Advance();
            identifierLength++;
        }

        // We ignore whitespace that may be between the identifier and the 'keyword' sign.
        while (IsWhitespace(Peek()))
        {
            if (IsAtEnd) return Error("Expected start of identifier definition");

            Advance();
        }

        // We consume the current char so we can select what to do.
        c = Advance();

        switch (c)
        {
        case '{': return MakeComplexe(.Struct, identifierStart, identifierLength);
        case '[': return MakeComplexe(.Array, identifierStart, identifierLength);
        case '<': return MakeComplexe(.Map, identifierStart, identifierLength);
        case '|': return MakeComplexe(.Enum, identifierStart, identifierLength);
        case '%': return MakeComplexe(.Module, identifierStart, identifierLength);
        case '(': return MakeComplexe(.Func, identifierStart, identifierLength);
        case '@': return MakeComplexe(.Assert, identifierStart, identifierLength);
        case '=': return MakeComplexe(.Const, identifierStart, identifierLength);
		default: return Error("Unknown identifier type");
        }
    }

    bool IsAtEnd => *current == '\0';

    char8 Advance()
    {
        current++;
        return current[-1];
    }

    char8 Peek()
    {
        return *current;
    }

    char8 PeekNext()
    {
        if (IsAtEnd)
            return '\0';

        return current[1];
    }

    bool Match(char8 expected)
    {
        if (IsAtEnd || (*current != expected)) return false;

        current++;
        return true;
    }

    void SkipWhitespace()
    {
        while (true)
        {
            char8 c = Peek();

            switch (c)
            {
            case ' ', '\r', '\t': Advance();
            case '/':
                if (PeekNext() == '/')
                {
                    while (Peek() != '\n' && !IsAtEnd) Advance();
                }
                return;
            default: return;
            }
        }
    }

    bool IsWhitespace(char8 c)
    {
        return (c == ' ' || c == '\r' || c == '\t');
    }

    TokenType IdentifierType()
    {
        /**
        * The only exception to the KeySymbol rules has to do with the boolean values.
        * The reason is that I did not find a non cryptic, easy to read way to represent
        * them using symbols for now.
        *
        * They are reusing syntax for calling an assert function as they are closely related
        * to how this type of function is meant to be used in lili.
        */
        switch (*start)
        {
        case '@':
            if (current - start > 1)
            {
                switch (start[1])
                {
                case 't': return CheckKeyword(2, 3, "rue", .True);
                case 'f': return CheckKeyword(2, 4, "alse", .False);
                }
            }
            fallthrough;
        default: return .Identifier;
        }
    }

    TokenType CheckKeyword(int keywordStart, int keywordLength, StringView rest, TokenType type)
    {
        if ((current - start == keywordStart + keywordLength) &&
			StringView(start + keywordStart, keywordLength).Equals(rest)) {
            return type;
		}

        // If the what we check was not @true or @false, then it is an assertion defined by the user (@GreaterThan10 for example).
        return .Identifier;
    }
}