using System;
using System.Collections;
using ijo.Stmt;
using ijo.Mixins;

namespace ijo.Scope
{
	class Scope
	{
		private Scope parent;

		private Dictionary<String, Variant> mutableVariables = new .();
		private Dictionary<String, Variant> constVariables = new .();

		public this(Scope parent = null)
		{
			this.parent = parent;
		}

		public ~this()
		{
			for (var value in mutableVariables)
			{
				value.value.Dispose();
				delete value.key;
			}
			delete mutableVariables;

			for (var value in constVariables)
			{
				value.value.Dispose();
				delete value.key;
			}
			delete constVariables;
		}

		public Result<void, ScopeError> Define(StringView name, Variant value, bool constant = false)
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

		public Result<void, ScopeError> Assign(Token name, Variant value)
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

		public Result<Variant, ScopeError> Get(Token name)
		{
			let key = scope String(name.Lexeme);

			if (mutableVariables.ContainsKey(key))
				return Unwrap!(mutableVariables.GetValue(key));

			if (constVariables.ContainsKey(key))
				return Unwrap!(constVariables.GetValue(key));

			if (parent != null)
				return parent.Get(name);

			return .Err(.UndefinedVariable(name.Literal.Get<String>()));
		}
	}
}