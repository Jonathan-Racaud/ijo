using System;
using System.IO;

namespace ijo
{
    class Program
    {
        static ijoVM vm = new .() ~ delete _;

        public static int Main(String[] args)
        {
            var number = ijoInt(.Int(42));

            var age = ijoInt(.Int(27));
            var x10 = ijoVal.Int(270);

            var clonedAge = age.Clone();
            age.setSlot("x10", &x10);

            Console.WriteLine(scope $"age: {age.getSlot("__value")}");
            Console.WriteLine(scope $"age.x10: {age.getSlot("x10")}");
            age.Dispose();

            Console.WriteLine(scope $"Cloned age: {clonedAge.getSlot("__value")}");
            Console.WriteLine(scope $"Cloned age.x10: {clonedAge.getSlot("x10")}");
            clonedAge.Dispose();

            Console.WriteLine(scope $"number: {number.getSlot("__value")}");
            Console.WriteLine(scope $"number: {number.getSlot("x10")}");
            number.Dispose();

            return 0;
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
                Console.Write("> ");

                let line = scope String();
                if (Console.ReadLine(line) case .Err)
                    Console.Error.WriteLine("[Error]: IO Error");

                if (line.Equals("exit"))
                    break;

                vm.Interpret(line);
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