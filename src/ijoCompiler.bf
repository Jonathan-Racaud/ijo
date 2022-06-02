using System;
namespace ijo
{
    class ijoCompiler
    {
        ijoScanner scanner;
        ijoParser parser = .();

        public CompileResult Compile(StringView source, out Chunk chunk)
        {
            chunk = Chunk();

            scanner = ijoScanner(source);

            Advance();
            ParseExpression();
            Consume(.EOF, "Expected end of expression.");

            return parser.HadError ? .Error : .Ok;
        }

        void Consume(TokenType type, StringView message)
        {
            if (parser.Current.Type == type)
            {
                Advance();
                return;
            }

            ErrorAtCurrent(message);
        }

        void Advance()
        {
            parser.Previous = parser.Current;

            while (true)
            {
                parser.Current = scanner.ScanToken();

                if (parser.Current.Type != .Error) break;

                ErrorAtCurrent(parser.Current.Start);
            }
        }

        void ErrorAtCurrent(StringView message)
        {
            ErrorAt(parser.Current, message);
        }

        void ErrorAt(Token token, StringView message)
        {
            if (parser.PanicMode) return;

            parser.PanicMode = true;
            Console.Error.Write(scope $"At line {token.Line} [Error]:");

            if (token.Type == .EOF)
            {
                Console.Error.Write(" at end");
            }
            else if (token.Type == .Error) { }
            else
            {
                Console.Error.Write(scope $" at {token.Start:token.Length}");
            }

            Console.Error.WriteLine(scope $": {message}");
            parser.HadError = true;
        }
    }

    enum CompileResult
    {
        case Ok;
        case Error;
    }
}