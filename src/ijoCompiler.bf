using System;
namespace ijo
{
    class ijoCompiler
    {
        ijoScanner scanner = new .() ~ delete _;

        public CompileResult Compile(StringView source)
        {
            var line = -1;

            while (true)
            {
                let token = scanner.ScanToken();

                if (token.Line != line)
                {
                    Console.Write(scope $"{token.Line:4D}");
                    line = token.Line;
                }
                else
                {
                    Console.Write("   | ");
                }

                Console.WriteLine(scope $"{token.Type} '{token.Start:token.Length}'");
            }
        }
    }

    enum CompileResult
    {
        case Ok;
        case Error;
    }
}