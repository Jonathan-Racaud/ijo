using System;
using System.Collections;
namespace ijo;

class Scanner
{
    int position = 0;
    int line = 0;
    int column = 0;
    String source;

    public Result<void> Scan(String source, List<Token> tokens)
    {
        this.source = source;

        position = 0;
        line = 0;
        column = 0;

        while (!IsAtEnd())
        {
            tokens.Add(ScanToken());
        }

        tokens.Add(MakeEOF());

        return .Ok;
    }

    Token ScanToken()
    {
        SkipWhitespaceAndComments();

        if (IsAtEnd()) return MakeToken(.EOF);

        MoveColumn();
        let c = Advance();

        if (c.IsDigit) return MakeNumber();
        if (c.IsLetter) return MakeIdentifier();

        switch (c)
        {
        case '$': return MakeToken(.Var);
        case '#': return MakeToken(.Const);

        case '(':
            if (Match('$')) return MakeToken(.Function);
            return MakeToken(.LeftParen);

        case '{':
            if (Match('$')) return MakeToken(.Struct);
            return MakeToken(.LeftBrace);

        case '[':
            if (Match('$')) return MakeToken(.Array);
            return MakeToken(.LeftBracket);

        case '|':
            if (Match('$')) return MakeToken(.Enum);
            return MakeToken(Match('|') ? .Or : .Pipe);

        case '<':
            if (Match('$')) return MakeToken(.Map);
            if (Match('-')) return MakeToken(.Break);
            if (Match('=')) return MakeToken(.LessEqual);
            return MakeToken(.Less);

        case '?':
            if (Match('(')) return MakeToken(.Condition);
            if (Match('|')) return MakeToken(.Switch);
            return MakeErrorToken("Undefined token");

        case '-':
            if (Match('>')) return MakeToken(.Return);
            return MakeToken(.Minus);

        case ':':
            if (Peek().IsLetterOrDigit) return MakeSymbol();
            return MakeToken(.Colon);

        case '~':
            if (Match('(')) return MakeToken(.Loop);
            return MakeErrorToken("Undefined token");

        case '&':
            if (Match('&')) return MakeToken(.And);
            return MakeErrorToken("Undefined token");

        case ')': return MakeToken(.RightParen);
        case ']': return MakeToken(.RightBracket);
        case '}': return MakeToken(.RightBrace);
        case '+': return MakeToken(.Plus);
        case '_': return MakeToken(.Underscore);
        case '/': return MakeToken(.Slash);
        case '*': return MakeToken(.Star);
        case '\\': return MakeToken(.BackSlash);
        case '!': return MakeToken(Match('=') ? .BangEqual : .Bang);
        case '.': return MakeToken(.Dot);
        case '=': return MakeToken(Match('=') ? .EqualEqual : .Equal);
        case '"': return MakeString();
        case ';': return MakeToken(.Semicolon);
        case '\n': return MakeToken(.NewLine);
        }

        return MakeErrorToken("Undefined token");
    }

    void SkipWhitespaceAndComments()
    {
        while (true)
        {
            let c = Peek();

            switch (c)
            {
            case ' ','\r','\t': Advance();
            case '\n':
                line++;
                return;
            case '/':
                if (PeekNext() == '/')
                {
                    while (Peek() != '\n' && !IsAtEnd())
                        Advance();
                }
                else
                {
                    return;
                }
            default: return;
            }
        }
    }

    Token MakeToken(TokenType type)
    {
        return .()
            {
                Type = type,
                Line = line,
                Column = column,
                Literal = StringView(source, column, Length())
            };
    }

    Token MakeNumber()
    {
        TokenType type = .Integer;
        /*MoveColumn();*/

        while (Peek().IsDigit)
            Advance();

        if (Peek() == '.' && PeekNext().IsDigit)
        {
            type = .Float;
            Advance();
        }

        while (Peek().IsDigit)
            Advance();

        return MakeToken(type);
    }

    Token MakeIdentifier()
    {
        /*MoveColumn();*/
        while (Peek().IsLetterOrDigit)
            Advance();

        return MakeToken(.Identifier);
    }

    Token MakeString()
    {
        /*MoveColumn();*/

        // We assume that the first " has already been consumed
        while (Peek() != '"' && !IsAtEnd())
        {
            if (Peek() == '\n') line++;
            Advance();
        }

        if (IsAtEnd()) return MakeErrorToken("Unterminated String");

        // We consume the closing "
        Advance();

        return MakeToken(.String);
    }

    Token MakeSymbol()
    {
        /*MoveColumn();*/
        while (Peek().IsLetterOrDigit || Peek() == '_' || Peek() == '-' && !IsAtEnd())
        {
            Advance();
        }

        let str = StringView(source, position, Length());

        if (str == ":undefined")
        {
            return MakeUndefined();
        }

        return MakeToken(.Symbol);
    }

    Token MakeErrorToken(StringView message)
    {
        return .()
            {
                Type = .Error,
                Literal = message,
                Line = line,
                Column = column
            };
    }

    Token MakeUndefined()
    {
        return .()
            {
                Type = .Undefined,
                Line = line,
                Column = column,
                Literal = ":undefined"
            };
    }

    Token MakeEOF()
    {
        return .()
            {
                Type = .EOF
            };
    }

    char8 Peek()
    {
        if (position >= source.Length)
            return '\0';
        return source[position];
    }

    char8 PeekNext(int offset = 1)
    {
        if (IsAtEnd() || (position + offset >= source.Length))
        {
            return '\0';
        }

        return source[position + offset];
    }

    char8 Advance()
    {
        return source[position++];
    }

    bool Match(char8 char)
    {
        if (IsAtEnd()) return false;
        if (source[position] != char) return false;

        position++;
        return true;
    }

    int Length()
    {
        if (position == column) return 1;
        return position - column;
    }

    bool IsAtEnd()
    {
        let endOfSource = position >= source.Length;
        let eofFound = false;

        return endOfSource || eofFound;
    }

    void MoveColumn()
    {
        column = position;
    }
}