using System;
namespace ijo
{
    typealias ParseFn = delegate void();
    struct ParseRule : IDisposable
    {
        public ParseFn Prefix;
        public ParseFn Infix;
        public Precedence Precedence;

        public this(ParseFn prefix, ParseFn infix, Precedence precedence)
        {
            Prefix = prefix;
            Infix = infix;
            Precedence = precedence;
        }

        public void Dispose()
        {
            if (Prefix != null)
                delete Prefix;

            if (Infix != null)
                delete Infix;
        }
    }
}