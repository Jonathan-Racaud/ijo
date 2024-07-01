using System;
using System.Collections;

namespace ijo;

class ValueExpr
{
	Expr e ~ _.Dispose();
}

class NamedExpr
{
	public StringView name;
	public Expr e ~ _.Dispose();

	public this(StringView name, Expr e)
	{
		this.name = name;
		this.e = e;
	}
}

enum Expr
{
	case Int(int i);
	case Double(double d);
	case String(String str);
	case StringLiteral(StringView str);
	case Bool(bool b);

	// (42, x, "Hello")
	case List(ExprList list);

	// { ($ x 10), (print x), (= x 30), (print x) }
	case Block(ExprList expr);

	// ($ var 42)
	case VarDefinition(NamedExpr expr);
	
	// (# var 42)
	case ConstDefinition(NamedExpr expr);

	// (= var 42)
	case SetIdentifier(NamedExpr expr);
	// (var)
	case GetIdentifier(StringView name);

	case FunctionDefinition(StringView name, List<String> parameters, ExprList body);
	case FunctionCall(StringView name, ExprList parameters);

	case Conditional(ExprList list);
	case Loop(ExprList list);

	case Undefined;

	case Error;

	public void Dispose()
	{
		switch (this)
		{
		case .String(let str): delete str;
		case .List(var list): DeleteContainerAndDisposeItems!(list);
		case .Block(let list): DeleteContainerAndDisposeItems!(list);
		case .VarDefinition(let e): delete e;
		case .ConstDefinition(let e): delete e;
		case .SetIdentifier(let e): delete e;
		case .FunctionDefinition(?, let parameters, let body): DeleteContainerAndItems!(parameters); DeleteContainerAndDisposeItems!(body);
		case .FunctionCall(?, let parameters): DeleteContainerAndDisposeItems!(parameters);
		case .Conditional(let list): DeleteContainerAndDisposeItems!(list);
		case .Loop(let list): DeleteContainerAndDisposeItems!(list);
		case .Int, .Double, .Bool, .StringLiteral, .Undefined, .Error, .GetIdentifier: break;
		}
	}
}

typealias ExprList = List<Expr>;

class InstructionStack<T>
{
	private List<T> values;
	public List<T> Values { get => values; }

	private int index = 0;
	private T* ptr;

	public this(List<T> list)
	{
		values = list;
		ptr = values.Ptr;
	}

	public T Current => *ptr;
	public T Next {
		get
		{
			if (index >= values.Count)
				return default;

			index++;
			return *ptr++;
		}
	}

	public T Prev {
		get
		{
			if (index <= 0)
				return default;

			index--;
			return *ptr--;
		}
	}
}

enum BuiltinFuncName
{
	case DefineConst;
	case DefineVar;

	case SetIdentifier;

	case Print;
	case Println;

	case GreaterThan;
	case GreaterEqualThan;

	case LessThan;
	case LessEqualThan;

	case Cond;
	case Loop;

	case Add;
}

static
{
    public static mixin SError(StringView message)
    {
		Console.Error.WriteLine(message);
        Expr.Error
    }
}