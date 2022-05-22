using System;
using System.Collections;
using System.Diagnostics;
using ijo.Scope;

namespace ijo.Std.Diagnostic
{
	class Diagnostic: IFunctionRegistrer
	{
		public void RegisterFunctions(Scope env)
		{
			env.Define("elapsedMilliseconds", Variant.Create<ijoCallable>(new ElapsedMillisecondsFunc(), true), true);
		}
	}

	class ElapsedMillisecondsFunc: ijoCallable
	{
		public override int Arity { get => 0; }

		public override Variant call(Scope env, List<Variant> arguments)
		{
			let time = DateTime.Now;
			return Variant.Create<int>(time.Millisecond);
		}
	}
}