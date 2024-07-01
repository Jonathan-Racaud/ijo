using System;
using System.Collections;

namespace ijo;

class Interpreter
{
	public ijoType Eval(ExprList expressions, Env env)
	{
		var returnValue = ijoType.Undefined;

		for (let expr in expressions)
		{
			returnValue = Eval(expr, env);
		}

		return returnValue;
	}

	public ijoType Eval(Expr expression, Env env)
	{
		ijoType value = .Undefined;

		switch (expression)
		{
		case .Int(let i): value = .Int(i);
		case .Double(let d): value = .Double(d);
		case .Bool(let b): value = .Bool(b);
		case .String(let str): value = .String(new String(str));
		case .StringLiteral(let str): value = .StringLiteral(str);
		/*case .List(let list): value = Eval(list, env);*/
		case .VarDefinition(let expr):
			var val = Eval(expr.e, env);
			if (env.DefineVar(expr.name, val) case .Ok(let v)) {
				value = v;
			}
		case .ConstDefinition(let expr):
			var val = Eval(expr.e, env);
			if (env.DefineConst(expr.name, val) case .Ok(let v)) {
				value = v;
			}
		case .SetIdentifier(let expr):
			var val = Eval(expr.e, env);
			let result = env.SetIdentifier(expr.name, val);

			switch (result) {
			case .Ok(let v): value = v;
			case .Err: value = .Error;
			}
		case .GetIdentifier(let name):
			if (env.GetIdentifier(name) case .Ok(let val)) { value = val; }
		case .Block(let exprs):
			return EvalBlock(exprs, scope Env(parent: env));
		case .FunctionDefinition(let name, let parameters, let body):
			let funcParams = parameters.CopyTo(..new List<String>());
			let funcBody = body.CopyTo(..new List<Expr>());
			ijoType func = .UserFunction(funcParams, funcBody, env);

			if (env.DefineConst(name, func) case .Ok(let v)) {
				value = v;

				// We clear to avoid other part of a program that would destroy
				// those elements. This effectively move the items from the
				// original list to the copied-into one.
				parameters.Clear();
				body.Clear();
			}
		case .FunctionCall(let name, let parameters):
			Console.WriteLine(scope $"Function call: {name}");
			let f = env.GetIdentifier(name);
			Console.WriteLine(f);
			switch (f)
			{
			case .Ok(.BuiltinFunction(let paramCount, let impl)):
				Console.WriteLine("Function call builtin");
				if (parameters.Count > paramCount && paramCount != -1) return .Error;

				Console.WriteLine("Function call has param count");
				var args = new List<Value>();
				defer { DeleteContainerAndDisposeItems!(args); }

				for (let param in parameters)
				{
					Console.WriteLine("Function call parsed param");
					args.Add(.Const(Eval(param, env)));
				}
				
				Console.WriteLine("Function call builtin will be called");
				switch (impl(args))
				{
				case .Const(let constant): value = constant;
				case .Var(let variable): value = variable;
				case .Func(let func): value = func;
				}
				Console.Write("Function call builtin called");
			case .Ok(.UserFunction(let args, let body, let funcEnv)):
				if (parameters.Count != args.Count) return .Error;
				let activationEnv = scope Env(parent: funcEnv);

				for (var i = 0; i < parameters.Count; i++)
				{
					if (activationEnv.DefineConst(args[i], Eval(parameters[i], activationEnv)) case .Err)
					{
						return .Error;
					}
				}

				value = EvalBody(body, activationEnv);
			default:
				Console.WriteLine(scope $"Function not found: {name}");
				return .Error;
			}
		case .Conditional(let list):
			let exprs = scope InstructionStack<Expr>(list);

			let cond = Eval(exprs.Next, env);
			let then = exprs.Next;
			let els = exprs.Next;

			if (cond case .Bool(true))
			{
				 value = Eval(then, env);
			}
			else
			{
				 value = Eval(els, env);
			}
		case .Loop(let list):
			let exprs = scope InstructionStack<Expr>(list);

			let loopComponents = (exprs.Next, exprs.Next, exprs.Next, exprs.Next);

			switch (loopComponents)
			{
			// ~() { ... }
			case (let body, .Undefined, .Undefined, .Undefined):
			while (true)
			{
				Eval(body, env);
			}
			// ~(true) { ... }
			case (let cond, let body, .Undefined, .Undefined):
			while (Eval(cond, env) case .Bool(true))
			{
				Eval(body, env);
			}
			// ~(i < 5; i++) { ... }
			case (let cond, let incr, let body, .Undefined):
			while (Eval(cond, env) case .Bool(true))
			{
				Eval(body, env);
				Eval(incr, env);
			}
			// ~($i = 0; i < 5; i++) { ... }
			case (let init, let cond, let incr, let body):
			Eval(init, env);

			while (Eval(cond, env) case .Bool(true))
			{
				Eval(body, env);
				Eval(incr, env);
			}
			}
		case .Undefined: value = .Undefined; 
		default: break;
		}

		return value;
	}

	ijoType EvalBlock(ExprList expressions, Env env)
	{
		ijoType result = .Undefined;

		for (let expr in expressions)
		{
		    result = Eval(expr, env);
		}

		return result;
	}

	ijoType EvalBody(ExprList expressions, Env env)
	{
		if (expressions[0] case .Block(let exprs))
		{
			return EvalBlock(exprs, env);
		}

		return Eval(expressions, env);
	}
}