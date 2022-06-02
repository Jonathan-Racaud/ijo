using System;
using System.Collections;
namespace ijo
{
    struct ijoScanner
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

        public Token ScanToken() mut
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
            case '%': return MakeToken(.Percent);
            case '~': return MakeToken(.Tilde);
            case '?': return MakeToken(.Question);
            case '_': return MakeToken(.Underscore);
            case '|': return MakeToken(.Pipe);
            case '$': return MakeToken(.Dollar);
            case ':': return MakeToken(.Colon);

            case '!': return MakeToken(Match('=') ? .BangEqual : .Bang);
            case '<': return MakeToken(Match('=') ? .LessEqual : .Less);
            case '>': return MakeToken(Match('=') ? .GreaterEqual : .Greater);
            case '=': return MakeToken(Match('=') ? .EqualEqual : .Equal);

            case '"': return MakeString();
            }

            return MakeErrorToken("Unexpected character");
        }

        char8 Advance() mut
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

        bool Match(char8 char) mut
        {
            if (IsAtEnd()) return false;
            if (*current != char) return false;

            current++;
            return true;
        }

        void SkipWhitespaceAndComments() mut
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

        Token MakeString() mut
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

        Token MakeNumber() mut
        {
            while (Peek().IsDigit)
                Advance();

            if (Peek() == '.' && PeekNext().IsDigit)
                Advance();

            while (Peek().IsDigit) Advance();

            return MakeToken(.Number);
        }

        Token MakeIdentifier() mut
        {
            while (Peek().IsLetterOrDigit) Advance();

            return MakeToken(.Identifier);
        }

        bool IsAtEnd() => *current == '\0';
        int GetLength() => (int)(current - start);
    }
}