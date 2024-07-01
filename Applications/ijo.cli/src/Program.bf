using System;
using System.Collections;
using System.IO;

using ijo;

namespace ijo.cli;

class Program
{
	public static int Main(String[] args)
	{
		if (args.Count == 0)
		{
			Repl();
		}
		else
		{
			File(args[0]);
		}

		return 0;
	}

	static void File(StringView filePath)
	{	
		String source = scope .();

		switch (File.ReadAllText(filePath, source))
		{
		case .Err:
			Console.WriteLine("Error reading source file.");
			return;
		case .Ok:
		}

		let interpreter = scope Interpreter();
		let env = scope Env(record: GlobalEnv);

		let scanner = scope Scanner(source);
		let parser = scope Parser(scanner);
		let parseResult = parser.Parse();

		switch (parseResult)
		{
		case .Ok(let expressions):
			interpreter.Eval(expressions, env);
			DeleteContainerAndDisposeItems!(expressions);
		case .Err:
			Console.WriteLine("[ERROR]: Failed interpretation");
		}
	}

	static void Repl()
	{
		Console.WriteLine(scope $"ijo Repl - v{ijo.Version}\n-----\n");

		let line = scope String();
		let interpreter = scope Interpreter();
		let replEnv = scope Env(record: GlobalEnv);
		defer { }
		
		Console.Write("$> ");

		while (Console.ReadLine(line) == .Ok)
		{
			if (line == "@quit") break;

			let scanner = scope Scanner(line);
			let parser = scope Parser(scanner);
			let parseResult = parser.Parse();

			switch (parseResult)
			{
			case .Ok(let expressions):
				let returnVal = interpreter.Eval(expressions, replEnv);
				Console.WriteLine(scope $"-> {returnVal}");

				DeleteContainerAndDisposeItems!(expressions);
			case .Err:
				Console.WriteLine("[ERROR]: Failed to parse expression");
			}
			
			line.Clear();

			Console.Write("$> ");
		}
	}

	static ExprList TestBlock => new .() {
		.VarDefinition(new .("x", .Int(10))),
		.Block(new .() {
			.VarDefinition(new .("x", .Int(20))),
			.FunctionCall("@>>", new .() { .GetIdentifier("x") }),
		}),
		.FunctionCall("@>>", new .() { .GetIdentifier("x") })
	}

	static ExprList TestConstAssign => new .() {
		.ConstDefinition(new .("x", .Int(10))),
		.SetIdentifier(new .("x", .Int(20))),
		.FunctionCall("@>>", new .() { .GetIdentifier("x") })
	}

	static ExprList TestFunctionAssign => new .() {
		.ConstDefinition(new .("myPrint", .GetIdentifier("@>>"))),
		.FunctionCall("myPrint", new .() { .Int(42) })
	}

	static ExprList TestSquare => new .() {
		.FunctionDefinition("square", new .() { "x" }, new .() {
			.FunctionCall("*", new .() { .GetIdentifier("x"), .GetIdentifier("x") })
		}),
		.FunctionCall("@>>", new .() { .FunctionCall("square", new .() { .Int(2) }) })
	}

	/**
	int a = 0, b = 1, c, i;
	if (n == 0)
	    return a;
	for (i = 2; i <= n; i++) {
	    c = a + b;
	    a = b;
	    b = c;
	}
	return b;
	*/
	static ExprList TestFib => new .() {
		.ConstDefinition(new .("n", .Int(5))),
		.VarDefinition(new .("a", .Int(0))),
		.VarDefinition(new .("b", .Int(1))),
		.VarDefinition(new .("c", .Int(0))),
		.Conditional(new .() {
			.FunctionCall("==", new .() { .GetIdentifier("n"), .Int(0) }),
			.Block(new .() {
				.FunctionCall("@>>", new .() { .GetIdentifier("a") })	
			}),
			.Block(new .() {
				.Loop(new .() {
					.VarDefinition(new .("i", .Int(2))),
					.FunctionCall("<=", new .() { .GetIdentifier("i"), .GetIdentifier("n") }),
					.SetIdentifier(new .("i", .FunctionCall("+", new .() { .GetIdentifier("i"), .Int(1) }))),
					.Block(new .() {
						.SetIdentifier(new .("c", .FunctionCall("+", new .() { .GetIdentifier("a"), .GetIdentifier("b") }))),
						.SetIdentifier(new .("a", .GetIdentifier("b"))),
						.SetIdentifier(new .("b", .GetIdentifier("c"))),
						.FunctionCall("@>", new .() { .GetIdentifier("b"), .StringLiteral(",") })
					})
				})
			})
		})
	}
}