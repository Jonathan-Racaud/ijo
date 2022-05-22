using System;
using System.Collections;
using ijo.Scope;

namespace ijo.Std
{
	class Console: IFunctionRegistrer
	{
		public void RegisterFunctions(Scope env)
		{
			env.Define("write", Variant.Create<ijoCallable>(new WriteFunc(), true), true);
		}

		public class WriteFunc: ijoCallable
		{
			public override int Arity { get => 1; }

			public override Variant call(Scope env, List<Variant> arguments)
			{
				let arg = arguments[0];

				switch (arg.VariantType)
				{
				case typeof(String): System.Console.WriteLine(arg.Get<String>());
				case typeof(int): System.Console.WriteLine(arg.Get<int>());
				case typeof(double): System.Console.WriteLine(arg.Get<double>());
				default: System.Console.WriteLine(arg.Get<Object>());
				}

				return default;
			}
		}
	}
}