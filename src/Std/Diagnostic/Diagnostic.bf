using System;
using System.Collections;
using System.Diagnostics;
using ijo.Interpreter;

namespace ijo.Std.Diagnostic
{
	class Diagnostic: IFunctionRegistrer
	{
		public void RegisterFunctions(ijoEnvironment env)
		{
			env.DefineFunction("elapsedMilliseconds", Variant.Create<ijoCallable>(new ElapsedMillisecondsFunc(), true));
		}
	}

	class ElapsedMillisecondsFunc: ijoCallable
	{
		public override int Arity { get => 0; }

		public override Variant call(Interpreter interpreter, List<Variant> arguments)
		{
			let time = DateTime.Now;
			return Variant.Create<int>(time.Millisecond);
		}
	}
}