using System;
using System.Collections;
using ijo.Stmt;
using ijo.Interpreter;
namespace ijo
{
	class ijoFunction: ijoCallable
	{
		private FunctionStmt declaration;

		public BlockStmt Body => declaration.body as BlockStmt;

		public override int Arity { get => declaration.parameters.Count; }

		public this(FunctionStmt declaration)
		{
			this.declaration = declaration;
		}

		public override Variant call(Interpreter interpreter, List<Variant> arguments)
		{
			let environment = scope ijoEnvironment(interpreter.Globals);

			for (var i = 0; i < declaration.parameters.Count; i++)
			{
				environment.Define(declaration.parameters[i].Lexeme, Variant.CreateFromVariant(arguments[i]));
			}

			interpreter.ExecuteBlock((declaration.body as BlockStmt).Statements, environment);
			return default;
		}
	}
}