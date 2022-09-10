using System;
using System.IO;

namespace ijo
{
    class Program
    {
        private static VirtualMachine vm = new .() ~ delete _;

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

                vm.Run(line);
                line.Clear();
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

            return Exit.Software;
        }

        static int Usage()
        {
            Console.WriteLine("Usage:  ijo [run <path>]\n");
            Console.WriteLine("    run    Interpret the file given at path.");

            return Exit.Usage;
        }
    }
}