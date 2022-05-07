using System;
using System.Collections;

namespace BLox
{
	public class Environment
	{
		private Dictionary<String, Variant> values = new .() ~ DeleteDictionaryAndKeys!(_);
		private BLox.Environment enclosing;

		public this()
		{
			enclosing = null;
		}

		public this(BLox.Environment env)
		{
			this.enclosing = enclosing;
		}

		public ~this()
		{
			if (enclosing != null)
			{
				delete enclosing;
				enclosing = null;
			}
		}

		public void Define(StringView name, Variant value)
		{
			let key = scope String(name);

			if (values.ContainsKey(key))
				values[key] = value;
			else
				values.Add(new .(name), value);
		}

		public Result<void, Error> Get(Token name, out Variant value)
		{
			if (values.ContainsKey(name.lexeme))
			{
				value = values.GetValue(name.lexeme);
				return .Ok;
			}

			if (enclosing != null)
			{
				return enclosing.Get(name, out value);
			}

			value = default;
			return .Err(new RuntimeError(name, scope $"Undefined variable '{name.lexeme}'."));
		}

		public Result<void, Error> Assign(Token name, Variant value)
		{
			let key = scope String(name.lexeme);

			if (values.ContainsKey(key))
			{
				values[key].Dispose();
				values[key] = value;
				return .Ok;
			}

			if (enclosing != null)
				return enclosing.Assign(name, value);

			return .Err(new RuntimeError(name, scope $"Undefined variable '{name.lexeme}'."));
		}
	}
}