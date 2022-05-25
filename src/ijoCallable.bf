using System;
using System.Collections;
using ijo.Interpreter;

namespace ijo
{
	abstract class ijoCallable
	{
		public abstract int Arity { get; }
		public abstract Variant call(Interpreter interpreter, List<Variant> arguments);
	}
}