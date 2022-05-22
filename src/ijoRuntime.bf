using System;
using ijo.Mixins;

namespace ijo
{
	class ijoRuntime
	{
		public static void PrintError(StringView message)
			=> Console.Error.WriteLine(scope $"[Error]: {message}");

		public static void PrintError(int line, int column, StringView message)
			=> Console.Error.WriteLine(scope $"[Error]{{{line}:{column}}}: {message}");

		public static void PrintWarning(int line, int column, StringView message)
			=> Console.Error.WriteLine(scope $"[Warning]{{{line}:{column}}}: {message}");

		public static void Print(Variant value)
		{
			let val = Assume!(value.GetBoxed(),
						(Otherwise) scope () => { PrintError("Unknown error"); });
			Console.WriteLine(scope $"{val}");
		}
	}
}