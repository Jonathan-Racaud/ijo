using System;
using System.Collections;
using ijo.Stmt;
using ijo.Mixins;

namespace ijo
{
	class ijoEnvironment
	{
		private ijoEnvironment parent;

		private Dictionary<String, Variant> mutableVariables = new .() ~ DeleteDictionaryAndKeys!(_);
		private Dictionary<String, Variant> constVariables = new .() ~ DeleteDictionaryAndKeys!(_);
		private Dictionary<String, Variant> funcVariables = new .();

		public this(ijoEnvironment parent = null)
		{
			this.parent = parent;
		}

		public ~this()
		{
			for (var dictVal in funcVariables)
			{
				var variant = dictVal.value;
				variant.Dispose();

				delete dictVal.key;
			}
			delete funcVariables;
		}

		public Result<void, EnvError> DefineFunction(StringView name, Variant value)
		{
			let key = new String(name);

			if (constVariables.ContainsKey(key))
			{
				delete key;
				return .Err(.VariableAlreadyDeclared(name));
			}

			funcVariables.Add(key, value);

			return .Ok;
		}

		public Result<void, EnvError> Define(StringView name, Variant value, bool constant = false)
		{
			let key = new String(name);

			if (mutableVariables.ContainsKey(key) || constVariables.ContainsKey(key))
			{
				delete key;
				return .Err(.VariableAlreadyDeclared(name));
			}

			if (constant)
				constVariables.Add(key, value);
			else
				mutableVariables.Add(key, value);

			return .Ok;
		}

		public Result<void, EnvError> Assign(Token name, Variant value)
		{
			let key = scope String(name.Lexeme);

			if (parent != null)
			{
				if (parent.Assign(name, value) case .Err(let err))
				{
					switch (err)
					{
					case .AssignToConstVariable:
						return .Err(err);

					// Parent env can have variables not defined.
					// If that is the case we delegate that check to
					// the current context.
					default: break;
					}
				}
			}

			if (constVariables.ContainsKey(key))
				return .Err(.AssignToConstVariable(key));

			if (!mutableVariables.ContainsKey(key))
				return .Err(.UndefinedVariable(key));

			mutableVariables[key].Dispose();
			mutableVariables[key] = value;
			return .Ok;
		}

		public Result<Variant, EnvError> Get(Token name)
		{
			let key = scope String(name.Lexeme);

			if (mutableVariables.ContainsKey(key))
				return Unwrap!(mutableVariables.GetValue(key));

			if (constVariables.ContainsKey(key))
				return Unwrap!(constVariables.GetValue(key));

			if (funcVariables.ContainsKey(key))
				return Unwrap!(funcVariables.GetValue(key));

			if (parent != null)
				return parent.Get(name);

			return .Err(.UndefinedVariable(name.Literal.Get<String>()));
		}
	}
}