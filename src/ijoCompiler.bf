using System;
using ijo.Types;

namespace ijo
{
    class ijoCompiler
    {
        ijoScanner scanner = .();
        ijoParser parser = .();
        Chunk compilingChunk;
        ParseRule[?] rules = ParseRule[TokenType.__Total]();

        public bool IsInRepl = false;

        public this()
        {
            InitParseRules();
        }

        public ~this()
        {
            for (let rule in rules)
            {
                rule.Dispose();
            }

            scanner.Dispose();
        }

        public CompileResult Compile(String source, out Chunk outChunk)
        {
            parser.HadError = false;
            outChunk = Chunk();
            compilingChunk = outChunk;

            scanner.Init(source);
            defer scanner.Dispose();

            Advance();

            while (!Match(.EOF))
            {
                ParseDeclaration();
            }

            EndCompiler();

            return parser.HadError ? .Error : .Ok;
        }

        void ParseDeclaration()
        {
            if (!ParseStatement())
                ParseExpressionStatement();
            else
            {
                if (IsInRepl)
                {
                    ParseExpression();
                    EmitByte(OpCode.Print);
                }
            }

            if (parser.HadError)
            {
                Synchronize();
            }
        }

        bool ParseStatement()
        {
            if (Match(.Print))
            {
                PrintStatement();
            }
            else
            {
                return false;
            }

            return true;
        }

        void ParseExpressionStatement()
        {
            ParseExpression();
            Consume(.Semicolon, "Expected ';' after value");
            EmitByte(OpCode.Pop);
        }

        void PrintStatement()
        {
            ParseExpression();
            Consume(.Semicolon, "Expected ';' after value");
            EmitByte(OpCode.Print);
        }

        void ParseExpression()
        {
            ParsePrecedence(.Assignment);
        }

        void ParseNumber()
        {
            if (Int.Parse(StringView(parser.Previous.Start, parser.Previous.Length)) case .Ok(let val))
            {
                EmitConstant(ijoValue.Int(val));
                return;
            }

            if (Double.Parse(StringView(parser.Previous.Start, parser.Previous.Length)) case .Ok(let val))
            {
                EmitConstant(ijoValue.Double(val));
                return;
            }

            ErrorAtCurrent("is not a number");
        }

        void ParseGrouping()
        {
            ParseExpression();
            Consume(.RightParen, "Expect ')' after expression.");
        }

        void ParseUnary()
        {
            let operatorType = parser.Previous.Type;

            ParsePrecedence(.Unary);

            switch (operatorType)
            {
            case .Bang: EmitByte(OpCode.Not);
            case .Minus: EmitByte(OpCode.Negate);
            default: return; // Unreachable
            }
        }

        void ParseBinary()
        {
            let operatorType = parser.Previous.Type;

            let rule = rules[operatorType];
            ParsePrecedence(rule.Precedence + 1);

            switch (operatorType)
            {
            case .BangEqual: EmitBytes(OpCode.Equal, OpCode.Not);
            case .EqualEqual: EmitByte(OpCode.Equal);
            case .Greater: EmitByte(OpCode.Greater);
            case .GreaterEqual: EmitBytes(OpCode.Greater, OpCode.Not);
            case .Less: EmitByte(OpCode.Less);
            case .LessEqual: EmitBytes(OpCode.Less, OpCode.Not);
            case .Plus: EmitByte(OpCode.Add);
            case .Minus: EmitByte(OpCode.Subtract);
            case .Star: EmitByte(OpCode.Multiply);
            case .Slash: EmitByte(OpCode.Divide);
            default: return;
            }
        }

        void ParseLiteral()
        {
            switch (parser.Previous.Type)
            {
            case .True: EmitByte(OpCode.True);
            case .False: EmitByte(OpCode.False);
            case .Nil: EmitByte(OpCode.Nil);
            default: return;
            }
        }

        void ParsePrecedence(Precedence precedence)
        {
            Advance();
            let prefixRule = rules[parser.Previous.Type].Prefix;

            if (prefixRule == null)
            {
                Console.Error.WriteLine("Expected expression");
                return;
            }

            prefixRule();

            while (precedence <= rules[parser.Current.Type].Precedence)
            {
                Advance();
                let infixRule = rules[parser.Previous.Type].Infix;

                if (infixRule == null)
                {
                    Console.Error.WriteLine("Unexpected error with infix rule");
                    return;
                }

                infixRule();
            }
        }

        void ParseString()
        {
            // +1 to remove the first " and - 2 to remove the last "
            let string = StringView(parser.Previous.Start + 1, parser.Previous.Length - 2);
            EmitInternString(string);
        }

        void ParseSymbol()
        {
            let symbol = StringView(parser.Previous.Start, parser.Previous.Length);
            EmitSymbol(symbol);
        }

        void Synchronize()
        {
            parser.PanicMode = false;

            while (parser.Current.Type != .EOF)
            {
                if (parser.Previous.Type == .Semicolon)
                    return;

                switch (parser.Current.Type)
                {
                case .Function,
                    .Var,
                    .Const,
                    .Type,
                    .While,
                    .If,
                    .Print,
                    .Return:
                    return;
                default: continue;
                }

                Advance();
            }
        }

        bool Match(TokenType tokenType)
        {
            if (!Check(tokenType))
                return false;

            Advance();
            return true;
        }

        bool Check(TokenType tokenType)
        {
            return parser.Current.Type == tokenType;
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

        void EmitByte(uint8 byte)
        {
            CurrentChunk().Write(byte, parser.Previous.Line);
        }

        void EmitBytes(uint8 byte1, uint8 byte2)
        {
            EmitByte(byte1);
            EmitByte(byte2);
        }

        void EmitConstant(ijoValue value)
        {
            CurrentChunk().WriteConstant(value, parser.Previous.Line);
        }

        void EmitInternString(StringView string)
        {
            CurrentChunk().WriteInternString(string);
        }

        void EmitSymbol(StringView symbol)
        {
            CurrentChunk().WriteSymbol(symbol);
        }

        void EmitReturn()
        {
            EmitByte(OpCode.Return);
        }

        void EndCompiler()
        {
            EmitReturn();

#if DEBUG_PRINT_CODE
            if (!parser.HadError)
            {
                Disassembler.DisassembleChunk(CurrentChunk(), "Code");
            }
#endif
        }

        Chunk CurrentChunk()
        {
            return compilingChunk;
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

        // Prefix, Infix, Precedence
        void InitParseRules()
        {
            rules[TokenType.LeftParen]    = .(new () => ParseGrouping(), null, Precedence.None);
            rules[TokenType.RightParen]   = .(null, null, Precedence.None);
            rules[TokenType.LeftBrace]    = .(null, null, Precedence.None);
            rules[TokenType.RightBrace]   = .(null, null, Precedence.None);
            rules[TokenType.LeftBracket]  = .(null, null, Precedence.None);
            rules[TokenType.RightBracket] = .(null, null, Precedence.None);
            rules[TokenType.Comma]        = .(null, null, Precedence.None);
            rules[TokenType.Colon]        = .(null, null, Precedence.None);
            rules[TokenType.Dot]          = .(null, null, Precedence.None);
            rules[TokenType.Minus]        = .(new () => ParseUnary(), new () => ParseBinary(), Precedence.Term);
            rules[TokenType.Plus]         = .(null, new () => ParseBinary(), Precedence.Term);
            rules[TokenType.Semicolon]    = .(null, null, Precedence.None);
            rules[TokenType.Slash]        = .(null, new () => ParseBinary(), Precedence.Factor);
            rules[TokenType.Star]         = .(null, new () => ParseBinary(), Precedence.Factor);
            rules[TokenType.Percent]      = .(null, null, Precedence.None);
            rules[TokenType.Var]          = .(null, null, Precedence.None);
            rules[TokenType.Const]        = .(null, null, Precedence.None);
            rules[TokenType.Question]     = .(null, null, Precedence.None);
            rules[TokenType.Underscore]   = .(null, null, Precedence.None);
            rules[TokenType.Tilde]        = .(null, null, Precedence.None);
            rules[TokenType.Pipe]         = .(null, null, Precedence.None);

            rules[TokenType.And]          = .(null, null, Precedence.None);
            rules[TokenType.Bang]         = .(new () => ParseUnary(), null, Precedence.None);
            rules[TokenType.BangEqual]    = .(null, new () => ParseBinary(), Precedence.Equality);
            rules[TokenType.Equal]        = .(null, null, Precedence.None);
            rules[TokenType.EqualEqual]   = .(null, new () => ParseBinary(), Precedence.Equality);
            rules[TokenType.Greater]      = .(null, new () => ParseBinary(), Precedence.Comparison);
            rules[TokenType.GreaterEqual] = .(null, new () => ParseBinary(), Precedence.Comparison);
            rules[TokenType.Less]         = .(null, new () => ParseBinary(), Precedence.Comparison);
            rules[TokenType.LessEqual]    = .(null, new () => ParseBinary(), Precedence.Comparison);
            rules[TokenType.Or]           = .(null, null, Precedence.None);

            rules[TokenType.If]           = .(null, null, Precedence.None);
            rules[TokenType.Else]         = .(null, null, Precedence.None);
            rules[TokenType.Switch]       = .(null, null, Precedence.None);
            rules[TokenType.While]        = .(null, null, Precedence.None);
            rules[TokenType.Return]       = .(null, null, Precedence.None);
            rules[TokenType.Break]        = .(null, null, Precedence.None);
            rules[TokenType.Function]     = .(null, null, Precedence.None);
            rules[TokenType.Type]         = .(null, null, Precedence.None);
            rules[TokenType.Enum]         = .(null, null, Precedence.None);
            rules[TokenType.Array]        = .(null, null, Precedence.None);
            rules[TokenType.Map]          = .(null, null, Precedence.None);

            rules[TokenType.True]         = .(new () => ParseLiteral(), null, Precedence.None);
            rules[TokenType.False]        = .(new () => ParseLiteral(), null, Precedence.None);
            rules[TokenType.Nil]          = .(new () => ParseLiteral(), null, Precedence.None);

            rules[TokenType.Identifier]   = .(null, null, Precedence.None);
            rules[TokenType.String]       = .(new () => ParseString(), null, Precedence.None);
            rules[TokenType.Symbol]       = .(new () => ParseSymbol(), null, Precedence.None);
            rules[TokenType.Number]       = .(new () => ParseNumber(), null, Precedence.None);
            rules[TokenType.Error]        = .(null, null, Precedence.None);
            rules[TokenType.EOF]          = .(null, null, Precedence.None);
        }
    }

    enum CompileResult
    {
        case Ok;
        case Error;
    }
}