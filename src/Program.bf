using System;
using System.IO;

namespace ijo
{
    class Program
    {
        static ijoVM vm = new .() ~ delete _;

        public static int Main(String[] args)
        {
            var result = 0;

            result = Run(args);

            return result;
        }

        static int Run(String[] args)
        {
            if (args.IsEmpty)
                return RunRepl();

            if (args[0].Equals("run"))
                return RunFile(args);

            return Usage();
        }

        static int RunRepl()
        {
            while (true)
            {
                Console.Write("$ ");

                let line = scope String();
                if (Console.ReadLine(line) case .Err)
                    return Exit.IOErr;

                if (line.Equals("exit"))
                    break;

                vm.Interpret(line, true);
                Console.WriteLine();
            }

            return Exit.Ok;
        }

        static int RunFile(String[] args)
        {
            if (args[1].IsEmpty)
                return Exit.Usage;

            let path = args[1];
            if (!File.Exists(path))
            {
                Console.Error.WriteLine(scope $"File doesn't exists: {path}");
                return Exit.IOErr;
            }

            let source = File.ReadAllText(path, .. new .());
            defer delete source;

            switch (vm.Interpret(source))
            {
            case .CompileError: return Exit.DataErr;
            case .RuntimeError: return Exit.Software;
            case .Ok: return Exit.Ok;
            }
        }

        static int Usage()
        {
            Console.WriteLine("Usage:  ijo [run <path>]\n");
            Console.WriteLine("    run    Interpret the file given at path.");

            return Exit.Usage;
        }
    }
}