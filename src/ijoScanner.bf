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
            case '*': return MakeToken(.Star);
            case '/': return MakeToken(.Slash);
            case '%': return MakeToken(.Percent);
            case '_': return MakeToken(.Underscore);
            case '$': return MakeToken(.Var);

            case '-': return MakeToken(Match('>') ? .Return : .Minus);
            case '!': return MakeToken(Match('=') ? .BangEqual : .Bang);
            case '>': return MakeToken(Match('=') ? .GreaterEqual : .Greater);
            case '=': return MakeToken(Match('=') ? .EqualEqual : .Equal);
            case '|': return MakeToken(Match('|') ? .Or : .Pipe);
            case '&':
                if (Match('&')) return MakeToken(.And);
                return MakeErrorToken("Unexpected character.");

            case '<':
                // <-
                if (Match('-')) return MakeToken(.Break);
                // <=
                if (Match('=')) return MakeToken(.LessEqual);
                // <SomeType>
                if (PeekNext().IsLetterOrDigit) return MakeTypeDef();
                return MakeToken(.Less);

            case '?':
                // ?(condition) { then; }
                if (Match('(')) return MakeToken(.If);
                // ?|identifier| { case1: ; case2: ; }
                if (Match('|')) return MakeToken(.Switch);
                return MakeErrorToken("Unexpected character");

            case '~':
                // ~(condition) { do; }
                if (Match('(')) return MakeToken(.While);
                return MakeErrorToken("Unexpected character");

            case ':':
                // :north, :south, :apple, :some-symbol, :other_symbol
                if (PeekNext().IsLetterOrDigit) return MakeSymbol();
                return MakeToken(.Colon);

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

        Token MakeSymbol() mut
        {
            while (IsValidSymbolChar() && !IsAtEnd())
            {
                Advance();
            }

            return MakeToken(.Symbol);
        }

        Token MakeTypeDef() mut
        {
            while (Peek().IsLetterOrDigit && Peek() != '>' && IsAtEnd())
            {
                Advance();
            }

            if (IsAtEnd()) return MakeErrorToken("Unterminated type definition");

            // The closing '>'
            Advance();

            return MakeToken(.Type);
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

        bool IsValidSymbolChar() => (Peek().IsLetterOrDigit || Peek() == '_' || Peek() == '-');
        bool IsAtEnd() => *current == '\0';
        int GetLength() => (int)(current - start);
    }
}