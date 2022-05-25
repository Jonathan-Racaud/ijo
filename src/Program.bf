using System;
using System.Collections;
using System.IO;
using ijo.Interpreter;
using ijo.Mixins;
using ijo.Parser;
using ijo.Scanner;
using ijo.Stmt;

namespace ijo
{
	static
	{
		public static let FuncDeclStmt = 0;
		public static let OtherStmt = 1;
	}
	

	class Program
	{
		private static Interpreter interpreter = new .() ~ delete _;

		public static int Main(String[] args)
		{
			if (args.Count != 2 || !args[0].Equals("run"))
			{
				Console.Error.WriteLine("Usage: ijo run <script>");
				return Exit.Usage;
			}

			interpreter.RegisterFunctions(
				scope ijo.Std.Console(),
				scope ijo.Std.Diagnostic.Diagnostic()
			);

			return ExecuteScript(args[1]);
		}

		static int ExecuteScript(String path)
		{
			let fs = scope FileStream();
			defer fs.Close();

			if (fs.Open(path) case .Err)
				return Exit.IOErr;

			return Execute(fs);
		}

		static int Execute(Stream source)
		{
			let scanner = scope Scanner(source);
			List<Token> tokens = default;

			if (scanner.ScanTokens(out tokens) case .Err)
				return Exit.Software;

			let parser = scope Parser(tokens);
			List<Stmt>[2] stmts = .(
				new List<Stmt>(),
				new List<Stmt>()
			);

			if (parser.Parse(stmts) case .Err)
				return Exit.Software;

			interpreter.Interpret(stmts[FuncDeclStmt]);
			interpreter.Interpret(stmts[OtherStmt]);

			DeleteContainerAndItems!(stmts[FuncDeclStmt]);
			DeleteContainerAndItems!(stmts[OtherStmt]);
			DeleteContainerAndDisposeItems!(tokens);

			return Exit.Ok;
		}
	}
}