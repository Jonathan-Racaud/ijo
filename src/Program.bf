using System;
using System.IO;
using ijoLang.AST;
using ijoLang.Emitters;
using ijoLang.Commands;

namespace ijoLang
{
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

            let res = (parser.Parse(tokens));
            if (res == .Err)
                return Exit.Software;

            let output = new FileStream();
            defer delete output;

            let currentDir = Directory.GetCurrentDirectory(.. scope .());
            let outputPath = Path.InternalCombine(..scope .(), currentDir, scope $"program{outputExt}");

            output.Create(outputPath, .Write);

            let ast = scope Ast("program", res.Value);

            ast.Print();

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