using System;
using System.Collections;
using ijo.Scope;

namespace ijo
{
	abstract class ijoCallable
	{
		public abstract int Arity { get; }
		public abstract Variant call(Scope env, List<Variant> arguments);
	}
}