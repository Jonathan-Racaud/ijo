using System;
using System.Collections;
using ijo.Stmt;
using ijo.Interpreter;
namespace ijo
{
	class ijoFunction: ijoCallable
	{
		private FunctionStmt declaration;
		private ijoEnvironment closure ~ delete _;

		public BlockStmt Body => declaration.body as BlockStmt;

		public override int Arity { get => declaration.parameters.Count; }

		public this(FunctionStmt declaration, ijoEnvironment env)
		{
			this.declaration = declaration;
			this.closure = env;
		}

		public override Variant call(Interpreter interpreter, List<Variant> arguments)
		{
			let environment = scope ijoEnvironment(closure);

			for (var i = 0; i < declaration.parameters.Count; i++)
			{
				environment.Define(declaration.parameters[i].Lexeme, Variant.CreateFromVariant(arguments[i]));
			}

			let result = interpreter.ExecuteBlock((declaration.body as BlockStmt).statements, environment);

			switch (result) {
			case .Ok(let val): return val;
			case .Err: return default;
			}
		}
	}
}