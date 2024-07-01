using System;
using System.Collections;

namespace ijo;

class Env
{
	public typealias ValueDict = Dictionary<String, Value>;

	private bool ownRecord = false;
	private ValueDict record ~ {
		if (ownRecord) {
			for (let x in record) {
				delete x.key;
				x.value.Dispose();
			}
			delete record;
		}
	};

	private Env parent = null;

	public this(ValueDict record = null, Env parent = null)
	{
		if (record == null)
		{
			this.record = new .();
			this.ownRecord = true;
		}
		else
		{
			this.record = record;
		}

		this.parent = parent;

		for (let r in record)
		{
			Console.WriteLine(r.key);
		}
	}

	public this()
	{
		record = new .();
		ownRecord = true;
	}

	public Result<ijoType> GetIdentifier(StringView name)
	{
		switch (Lookup(name))
		{
		case .Ok(.Const(let constant)): return constant;
		case .Ok(.Var(let variable)): return variable;
		case .Ok(.Func(let func)):
			Console.WriteLine("Function found");
			return func;
		default: return .Err;
		}
	}

	public Result<ijoType, StringView> SetIdentifier(StringView name, ijoType value)
	{
		if (Resolve(name) case .Ok(let env))
		{
			switch (env[scope .(name)])
			{
			case .Var(?):
				env[scope .(name)] = Value.Var(value);
				return .Ok(value);
			default: return .Err("Trying to modify const variable");
			}
		}

		return .Err(scope $"Identifier `{name}` not found.");
	}

	public ijoType GetVariable(StringView name)
	{
		switch (Lookup(name))
		{
		case .Ok(.Var(let variable)): return variable;
		case .Ok(?), .Err: break;
		}

		return parent?.GetVariable(name) ?? .Undefined;
	}

	public ijoType GetConstant(StringView name)
	{
		switch (Lookup(name))
		{
		case .Ok(.Const(let constant)): return constant;
		case .Ok(?), .Err: break;
		}

		return parent?.GetConstant(name) ?? .Undefined;
	}

	public Result<ijoType> DefineConst(StringView name, ijoType value)
	{
		if (record.ContainsKey(scope .(name)))
			return .Err;

		var val = Value.Const(value);
		record[new .(name)] = val;

		return value;
	}

	public Result<ijoType> DefineVar(StringView name, ijoType value)
	{
		if (record.ContainsKey(scope .(name)))
			return .Err;

		var val = Value.Var(value);
		record[new .(name)] = val;

		return value;
	}

	private Result<Value> Lookup(StringView forName)
	{
		switch (Resolve(forName))
		{
		case .Ok(let env):
			Console.WriteLine("Found");
			return .Ok(env[scope .(forName)]);
		case .Err: return .Err;
		}
	}

	public Result<ValueDict> Resolve(StringView name)
	{
		Console.WriteLine(scope $"Trying to find: {name}");
		if (record.ContainsKey(scope .(name))) return record;

		Console.WriteLine("Not found in own record");
		if (parent != null)
		{
			Console.WriteLine("Trying to find in parent");
			return parent.Resolve(name);
		}

		return .Err;
	}
}

static
{
	private static Env.ValueDict __ijoGlobalEnv = new .() {
		("+", .Func(.BuiltinFunction(2, => __ijoAdd))),
		("-", .Func(.BuiltinFunction(2, => __ijoSub))),
		("/", .Func(.BuiltinFunction(2, => __ijoDiv))),
		("*", .Func(.BuiltinFunction(2, => __ijoMul))),
		("%", .Func(.BuiltinFunction(2, => __ijoMod))),
		("==", .Func(.BuiltinFunction(2, => __ijoEqual))),
		("!=", .Func(.BuiltinFunction(2, => __ijoNotEqual))),
		(">", .Func(.BuiltinFunction(2, => __ijoGreaterThan))),
		(">=", .Func(.BuiltinFunction(2, => __ijoGreaterOrEqual))),
		("<", .Func(.BuiltinFunction(2, => __ijoLessThan))),
		("<=", .Func(.BuiltinFunction(2, => __ijoLessOrEqual))),
		("\\>", .Func(.BuiltinFunction(-1, => __ijoPrint))),
		("\\>>", .Func(.BuiltinFunction(-1, => __ijoPrintln)))
	} ~ {
		for (let (key, value)in __ijoGlobalEnv) {
			switch (value) {
			case .Func(.BuiltinFunction(?, ?)): break;
			case .Func(let func):
				delete key;
				func.Dispose();
			case .Const(let constant):
				delete key;
				constant.Dispose();
			case .Var(let variable):
				delete key;
				variable.Dispose();
			}
		}
		delete __ijoGlobalEnv;
	};
	public static Env.ValueDict GlobalEnv => __ijoGlobalEnv;

	static Value __ijoPrint(List<Value> parameters) {
		Console.Write("__ijoPrint enter");
		for (let param in parameters) {
			var str = scope String();

			switch (param)
			{
			case .Const(let constant): constant.ToString(str);
			case .Var(let variable): variable.ToString(str);
			case .Func(let func): param.ToString(str);
			}
			Console.Write(scope $"{str}");
		}
		Console.Write("__ijoPrint exit");
		return .Const(.Undefined);
	}

	static Value __ijoPrintln(List<Value> parameters) {
		__ijoPrint(parameters);
		Console.WriteLine();

		return .Const(.Undefined);
	}

	static Value __ijoAdd(List<Value> parameters) {
		let a = parameters[0];
		let b = parameters[1];

		return a + b;
	}

	static Value __ijoSub(List<Value> parameters) {
		if (parameters.Count == 2)
		{
			let a = parameters[0];
			let b = parameters[1];

			return a - b;
		}

		return -parameters[0];
	}

	static Value __ijoDiv(List<Value> parameters) {
		let a = parameters[0];
		let b = parameters[1];

		return a / b;
	}

	static Value __ijoMul(List<Value> parameters) {
		let a = parameters[0];
		let b = parameters[1];

		return a * b;
	}

	static Value __ijoMod(List<Value> parameters) {
		let a = parameters[0];
		let b = parameters[1];

		return a % b;
	}

	static Value __ijoEqual(List<Value> parameters) {
		let a = parameters[0];
		let b = parameters[1];

		return a == b;
	}

	static Value __ijoNotEqual(List<Value> parameters) {
		let a = parameters[0];
		let b = parameters[1];

		return a != b;
	}

	static Value __ijoGreaterThan(List<Value> parameters) {
		let a = parameters[0];
		let b = parameters[1];

		return a > b;
	}

	static Value __ijoGreaterOrEqual(List<Value> parameters) {
		let a = parameters[0];
		let b = parameters[1];

		return a >= b;
	}

	static Value __ijoLessThan(List<Value> parameters) {
		let a = parameters[0];
		let b = parameters[1];

		return a < b;
	}

	static Value __ijoLessOrEqual(List<Value> parameters) {
		let a = parameters[0];
		let b = parameters[1];

		return a <= b;
	}

	public static mixin DeleteDictionaryAndDisposeValues(var dict) {
		for (let v in dict.Values)
		{
			v.Dispose();
		}
		delete dict;
	}
}