using System;
using System.IO;
using ijoLang.Emitters;
using ijoLang.Commands;

namespace ijoLang
{
    /*class Program
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
            vm.IsInRepl = true;
            while (true)
            {
                Console.Write("@> ");

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
            vm.IsInRepl = false;
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

            vm.Run(source);

            return Exit.Software;
        }

        static int Usage()
        {
            Console.WriteLine("Usage:  ijo [run <path>]\n");
            Console.WriteLine("    run    Interpret the file given at path.");

            return Exit.Usage;
        }
    }*/

    class Program
    {
        public static int Main(String[] args)
        {
            let scanner = scope Scanner();
            let parser = scope Parser();
            let source = new String();
            defer delete source;

            let outputExt = scope String();

            Emitter emitter = null;
            defer { if (emitter != null) delete emitter; }

            let cCodeCommand = Command() {
                Name = "c",
                Handler = new [&](c) => {
                    emitter = new CEmitter();
                    outputExt.Set(".c");
                    return 0;
				}
			};

            let jsCodeCommand = Command() {
                Name = "js",
                Handler = new [&](c) => {
                    let js = new JSEmitter();
                    js.StdOutCall.Set("console.log");
                    emitter = js;
                    outputExt.Set(".js");
                    return 0;
            	}
            };

            let nodeCodeCommand = Command() {
                Name = "node",
                Handler = new [&](c) => {
                    let js = new JSEmitter();
                    js.StdOutCall.Set("process.stdout.write");
                    emitter = js;
                    outputExt.Set(".js");
                    return 0;
            	}
            };

            let helpCommand = Command() {
                Name = "help",
                Handler = new (c) => {
                    Console.WriteLine("Usage: ijoLang <target_lang> File");
                    return 0;
            	}
            };

            let cliManager = scope CommandManager(helpCommand);
            cliManager.Register(cCodeCommand);
            cliManager.Register(jsCodeCommand);
            cliManager.Register(nodeCodeCommand);

            if (args.Count != 2)
            {
                helpCommand.Handler(helpCommand);
                return 1;
            }

            let commandName = args[0];

            if (cliManager.HasCommandWithName(commandName))
            {
                var command = cliManager.GetCommandWithName(commandName);
                command.Handler(command);
            }

            ReadSourceFile(args[1], source);

            let tokens = scanner.Scan(source, .. scope .());
            defer {
                for (let t in tokens)
                {
                    t.Dispose();
                }

                tokens.Clear();
			}

            let ast = parser.Parse(tokens, .. scope .());
            defer { ClearAndDeleteItems!(ast); }

            let output = new FileStream();
            defer delete output;

            let currentDir = Directory.GetCurrentDirectory(.. scope .());
            let outputPath = Path.InternalCombine(..scope .(), currentDir, scope $"program{outputExt}");

            output.Create(outputPath, .Write);

            emitter.Emit(output, ast);
            output.Close();

            return 0;
        }

        static void ReadSourceFile(StringView path, String output)
        {
            if (!File.Exists(path))
            {
                Console.Error.WriteLine(scope $"File doesn't exists: {path}");
                return;
            }

            File.ReadAllText(path, output);
        }
    }
}