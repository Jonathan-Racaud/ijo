using System;
using System.Collections;
using ijo.Interpreter;

namespace ijo.Std
{
	class Console: IFunctionRegistrer
	{
		public void RegisterFunctions(ijoEnvironment env)
		{
			env.DefineFunction("write", Variant.Create<ijoCallable>(new WriteFunc(), true));
		}

		public class WriteFunc: ijoCallable
		{
			public override int Arity { get => 1; }

			public override Variant call(Interpreter interpreter, List<Variant> arguments)
			{
				let arg = arguments[0];

				switch (arg.VariantType)
				{
				case typeof(String): System.Console.WriteLine(arg.Get<String>());
				case typeof(StringView): System.Console.WriteLine(arg.Get<StringView>());
				case typeof(int): System.Console.WriteLine(arg.Get<int>());
				case typeof(double): System.Console.WriteLine(arg.Get<double>());
				default: System.Console.WriteLine(arg.Get<Object>());
				}

				return default;
			}
		}
	}
}