using System;
using System.IO;

namespace BLox
{
	public static class Lox
	{
		private static bool _hadError;

		/// Returns code according to UNIX's sysexit.h:
		/// https://www.freebsd.org/cgi/man.cgi?query=sysexits&apropos=0&sektion=0&manpath=FreeBSD+4.3-RELEASE&format=html
		public static int Main(String[] args)
		{
			int exit;

			if (args.Count > 1)
			{
				Console.Error.WriteLine("Usage: blox [script]");
				exit = 64;
			}
			else if (args.Count == 1)
			{
				exit = RunFile(args[0]);
			}
			else
			{
				exit = RunPrompt();
			}

			return exit;
		}

		static int RunFile(String file)
		{
			var data = new String();
			defer delete data;

			if (File.ReadAllText(file, data) case .Err)
			{
				return 74;
			}

			Run(data);

			if (_hadError) return 65;

			return 0;
		}

		static int RunPrompt()
		{
			for(;;)
			{
				Console.Write("> ");
				String line = scope String();

				if (Console.ReadLine(line) case .Err)
					return 75;

				if (ShouldExit(line)) break;

				Run(line);
				_hadError = false;
			}

			return 0;
		}

		static void Run(String source)
		{
			let scanner = scope Scanner(source);
			let tokens = scanner.ScanTokens();

			let parser = scope Parser(tokens);
			Expr expr;

			if (parser.Parse(out expr) case .Ok)
			{
				let astPrinter = scope AstPrinter();
				astPrinter.Build(expr);

				Console.WriteLine(astPrinter.Result);

				delete expr;
			}
		}

		static bool ShouldExit(StringView line)
		{
			return (line.IsEmpty || line.Equals("exit"));
		}

		public static void Error(int line, String message)
		{
			Report(line, "", message);
		}

		public static void Error(Token token, StringView message)
		{
			if (token.type == .EOF)
			{
				Report(token.line, " at end", scope .(message));
			}
			else
			{
				Report(token.line, scope $" at '{token.lexeme}'", scope .(message));
			}
		}

		public static void Report(int line, String location, String message)
		{
			Console.Error.WriteLine(scope $"[{line}] Error {location}: {message}");
			_hadError = true;
		}
	}
}