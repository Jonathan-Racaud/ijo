using System;
using System.Collections;
namespace ijo
{
    class ijoScanner
    {
        /// The start of the current lexeme being scanned
        char8* start;

        /// Current character being looked at
        char8* current;

        int line;

        StringView source;

        public this(StringView source = "")
        {
            this.source = source;
            start = source.Ptr;
            current = start;
            line = 1;
        }

        public Token ScanToken()
        {
            SkipWhitespaceAndComments();
            start = current;

            if (IsAtEnd()) return MakeToken(.EOF);

            let c = Advance();

            if (c.IsDigit) return MakeNumber();
            if (c.IsLetter) return MakeIdentifier();

            switch (c)
            {
            case '(': return MakeToken(.LeftParen);
            case ')': return MakeToken(.RightParen);
            case '{': return MakeToken(.LeftBrace);
            case '}': return MakeToken(.RightBrace);
            case ';': return MakeToken(.Semicolon);
            case ',': return MakeToken(.Comma);
            case '.': return MakeToken(.Dot);
            case '+': return MakeToken(.Plus);
            case '-': return MakeToken(.Minus);
            case '*': return MakeToken(.Star);
            case '/': return MakeToken(.Slash);

            case '!': return MakeToken(Match('=') ? .BangEqual : .Bang);
            case '<': return MakeToken(Match('=') ? .LessEqual : .Less);
            case '>': return MakeToken(Match('=') ? .GreaterEqual : .Greater);
            case '=': return MakeToken(Match('=') ? .EqualEqual : .Equal);

            case '"': return MakeString();
            }

            return MakeErrorToken("Unexpected character");
        }

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
            if (IsAtEnd()) return '\0';
            return current[1];
        }

        bool Match(char8 char)
        {
            if (IsAtEnd()) return false;
            if (*current != char) return false;

            current++;
            return true;
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
                    Advance();
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
            return .(
                type,
                start,
                GetLength(),
                line);
        }

        Token MakeErrorToken(StringView message)
        {
            return .(
                .Error,
                message.Ptr,
                message.Length,
                line);
        }

        Token MakeString()
        {
            while (Peek() != '"' && !IsAtEnd())
            {
                if (Peek() == '\n') line++;
                Advance();
            }

            if (IsAtEnd()) return MakeErrorToken("Unterminated string");

            // The closing quote
            Advance();

            return MakeToken(.String);
        }

        Token MakeNumber()
        {
            while (Peek().IsDigit)
                Advance();

            if (Peek() == '.' && PeekNext().IsDigit)
                Advance();

            while (Peek().IsDigit) Advance();

            return MakeToken(.Number);
        }

        Token MakeIdentifier()
        {
            while (Peek().IsLetterOrDigit) Advance();

            return MakeToken(GetIdentifierType());
        }

        TokenType GetIdentifierType()
        {
            switch (start[0])
            {
            case 'a': return CheckKeyword(1, 2, "nd", .And);
            case 'b': return CheckKeyword(1, 3, "ase", .Base);
            case 'i': return CheckKeyword(1, 1, "f", .If);
            case 'o': return CheckKeyword(1, 1, "r", .Or);
            case 'r': return CheckKeyword(1, 6, "eturn", .Return);
            case 'w': return CheckKeyword(1, 5, "hile", .And);
            case 'f':
                if (GetLength() > 1)
                {
                    switch (start[1])
                    {
                    case 'a': return CheckKeyword(2, 3, "lse", .False);
                    case 'o': return CheckKeyword(2, 1, "r", .Or);
                    }
                }
            case 't':
                if (GetLength() > 1)
                {
                    switch (start[1])
                    {
                    case 'h': return CheckKeyword(2, 2, "is", .This);
                    case 'r': return CheckKeyword(2, 3, "rue", .True);
                    }
                }
            default: break;
            }

            return .Identifier;
        }

        TokenType CheckKeyword(int begin, int length, StringView rest, TokenType type)
        {
            if (GetLength() == (begin + length) && rest.Equals((StringView(start + begin))))
                return type;

            return .Identifier;
        }

        bool IsAtEnd() => *current == '\0';
        int GetLength() => (int)(current - start);
    }
}