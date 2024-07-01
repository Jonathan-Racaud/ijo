using System;
using System.Collections;

namespace ijo;

enum ijoType: IDisposable
{
	case Int(int i);
	case Double(double d);
	case String(String str);
	case StringLiteral(StringView str);
	case Bool(bool b);
	case List(List<Value> list);
	case BuiltinFunction(int paramCount, function Value(List<Value>));
	case UserFunction(List<String> parameters, ExprList body, Env env);
	case Undefined;
	case Error;

	public void Dispose()
	{
		switch (this)
		{
		case .String(let str): delete str;
		case .List(let list): DeleteContainerAndDisposeItems!(list);
		case .UserFunction(let parameters, let body, let env):
 			DeleteContainerAndItems!(parameters);
			DeleteContainerAndDisposeItems!(body);
		default: break;
		}
	}

	public override void ToString(String strBuffer)
	{
		switch (this)
		{
		case .Int(let i): i.ToString(strBuffer);
		case .Double(let d): d.ToString(strBuffer);
		case .Bool(let b): b.ToString(strBuffer);
		case .String(let str): strBuffer.Append(str);
		case .StringLiteral(let str): strBuffer.Append(str);
		case .BuiltinFunction(let paramCount, let p1): strBuffer.Append("BuiltinFunction");
		case .UserFunction(?, ?, ?): strBuffer.Append("UserFunction");
		case .Undefined: strBuffer.Append("???");
		case .List(let list):
			strBuffer.Append("[");

			for (let elem in list)
			{
				elem.ToString(strBuffer);
			}

			strBuffer.Append("]");
		case .Error: strBuffer.Append("<!!!>");
		}
	}
}

enum Value: IDisposable
{
	case Const(ijoType constant);
	case Var(ijoType variable);
	case Func(ijoType func);

	public void Dispose()
	{
		switch (this)
		{
		case .Const(let c): c.Dispose();
		case .Var(let v): v.Dispose();
		case .Func(let f): f.Dispose();
		default: break;
		}
	}

	public override void ToString(String strBuffer)
	{
		switch (this)
		{
		case .Const(let constant): strBuffer.Append(scope $"#{constant.ToString(..scope .())}");
		case .Var(let variable): strBuffer.Append(scope $"${variable.ToString(..scope .())}");
		case .Func(let func): strBuffer.Append("Func");
		}
	}
}

/*************************************
    ijoType Operators
**************************************/
extension ijoType
{
	[Commutable]
	public static ijoType operator>=(ijoType a, ijoType b)
	{
	    if (a case .Int(let aVal) && b case .Int(let bVal))
	        return .Bool(aVal >= bVal);

	    if (a case .Double(let aVal) && b case .Double(let bVal))
	        return .Bool(aVal >= bVal);

	    return .Bool(false);
	}

	[Commutable]
	public static ijoType operator>(ijoType a, ijoType b)
	{
	    if (a case .Int(let aVal) && b case .Int(let bVal))
	        return .Bool(aVal > bVal);

	    if (a case .Double(let aVal) && b case .Double(let bVal))
	        return .Bool(aVal > bVal);

	    return .Bool(false);
	}

	[Commutable]
	public static ijoType operator<=(ijoType a, ijoType b)
	{
	    if (a case .Int(let aVal) && b case .Int(let bVal))
	        return .Bool(aVal <= bVal);

	    if (a case .Double(let aVal) && b case .Double(let bVal))
	        return .Bool(aVal <= bVal);

	    return .Bool(false);
	}

	[Commutable]
	public static ijoType operator<(ijoType a, ijoType b)
	{
	    if (a case .Int(let aVal) && b case .Int(let bVal))
	        return .Bool(aVal < bVal);

	    if (a case .Double(let aVal) && b case .Double(let bVal))
	        return .Bool(aVal < bVal);

	    return .Bool(false);
	}

	[Commutable]
	public static ijoType operator==(ijoType a, ijoType b)
	{
	    if (a case .Int(let aVal) && b case .Int(let bVal))
	        return .Bool(aVal == bVal);

	    if (a case .Double(let aVal) && b case .Double(let bVal))
	        return .Bool(aVal == bVal);

		if (a case .Bool(let aVal) && b case .Bool(let bVal))
			return .Bool(aVal == bVal);

		if (a case .String(let aVal) && b case .String(let bVal))
			return .Bool(aVal == bVal);

		if (a case .StringLiteral(let aVal) && b case .StringLiteral(let bVal))
			return .Bool(aVal == bVal);

		if (a case .Undefined && b case .Undefined)
			return .Bool(true);

	    return .Bool(false);
	}

	public static ijoType operator+(ijoType a, ijoType b)
	{
	    if (a case .Int(let aVal) && b case .Int(let bVal))
	        return .Int(aVal + bVal);

	    if (a case .Double(let aVal) && b case .Double(let bVal))
	        return .Double(aVal + bVal);

	    return .Undefined;
	}

	public static ijoType operator-(ijoType a, ijoType b)
	{
	    if (a case .Int(let aVal) && b case .Int(let bVal))
	        return .Int(aVal - bVal);

	    if (a case .Double(let aVal) && b case .Double(let bVal))
	        return .Double(aVal - bVal);

	    return .Undefined;
	}

	public static ijoType operator-(ijoType a)
	{
	    if (a case .Int(let aVal))
	        return .Int(-aVal);

	    if (a case .Double(let aVal))
	        return .Double(- aVal);

	    return .Undefined;
	}

	public static ijoType operator*(ijoType a, ijoType b)
	{
	    if (a case .Int(let aVal) && b case .Int(let bVal))
	        return .Int(aVal * bVal);

	    if (a case .Double(let aVal) && b case .Double(let bVal))
	        return .Double(aVal * bVal);

	    return .Undefined;
	}

	public static ijoType operator/(ijoType a, ijoType b)
	{
	    if (a case .Int(let aVal) && b case .Int(let bVal))
	        return .Int(aVal / bVal);

	    if (a case .Double(let aVal) && b case .Double(let bVal))
	        return .Double(aVal / bVal);

	    return .Undefined;
	}

	public static ijoType operator%(ijoType a, ijoType b)
	{
	    if (a case .Int(let aVal) && b case .Int(let bVal))
	        return .Int(aVal % bVal);

	    if (a case .Double(let aVal) && b case .Double(let bVal))
	        return .Double(aVal % bVal);

	    return .Undefined;
	}
}

/*************************************
    Value Operators
**************************************/
extension Value
{
	[Commutable]
	public static Value operator>=(Value a, Value b)
	{
	    if (a case .Const(let aVal) && b case .Const(let bVal))
	        return .Const(aVal >= bVal);

	    if (a case .Var(let aVal) && b case .Var(let bVal))
	        return .Const(aVal >= bVal);

	    return .Const(.Bool(false));
	}

	[Commutable]
	public static Value operator<=(Value a, Value b)
	{
	    if (a case .Const(let aVal) && b case .Const(let bVal))
	        return .Const(aVal <= bVal);

	    if (a case .Var(let aVal) && b case .Var(let bVal))
	        return .Const(aVal <= bVal);

	    return .Const(.Bool(false));
	}

	[Commutable]
	public static Value operator>(Value a, Value b)
	{
	    if (a case .Const(let aVal) && b case .Const(let bVal))
	        return .Const(aVal > bVal);

	    if (a case .Var(let aVal) && b case .Var(let bVal))
	        return .Const(aVal > bVal);

	    return .Const(.Bool(false));
	}

	[Commutable]
	public static Value operator<(Value a, Value b)
	{
	    if (a case .Const(let aVal) && b case .Const(let bVal))
	        return .Const(aVal < bVal);

	    if (a case .Var(let aVal) && b case .Var(let bVal))
	        return .Const(aVal < bVal);

	    return .Const(.Bool(false));
	}

	[Commutable]
	public static Value operator==(Value a, Value b)
	{
	    if (a case .Const(let aVal) && b case .Const(let bVal))
	        return .Const(aVal == bVal);

	    if (a case .Var(let aVal) && b case .Var(let bVal))
	        return .Const(aVal == bVal);

	    return .Const(.Bool(false));
	}

	public static Value operator+(Value a, Value b)
	{
	    if (a case .Const(let aVal) && b case .Const(let bVal))
	        return .Const(aVal + bVal);

	    if (a case .Var(let aVal) && b case .Var(let bVal))
	        return .Const(aVal + bVal);

	    return Const(.Undefined);
	}

	public static Value operator-(Value a, Value b)
	{
	    if (a case .Const(let aVal) && b case .Const(let bVal))
	        return .Const(aVal - bVal);

	    if (a case .Var(let aVal) && b case .Var(let bVal))
	        return .Const(aVal - bVal);

	    return Const(.Undefined);
	}

	public static Value operator-(Value a)
	{
	    if (a case .Const(let aVal))
	        return .Const(-aVal);

	    if (a case .Var(let aVal))
	        return .Const(-aVal);

	    return Const(.Undefined);
	}

	public static Value operator*(Value a, Value b)
	{
	    if (a case .Const(let aVal) && b case .Const(let bVal))
	        return .Const(aVal * bVal);

	    if (a case .Var(let aVal) && b case .Var(let bVal))
	        return .Const(aVal * bVal);

	    return Const(.Undefined);
	}

	public static Value operator/(Value a, Value b)
	{
	    if (a case .Const(let aVal) && b case .Const(let bVal))
	        return .Const(aVal / bVal);

	    if (a case .Var(let aVal) && b case .Var(let bVal))
	        return .Const(aVal / bVal);

	    return Const(.Undefined);
	}

	public static Value operator%(Value a, Value b)
	{
	    if (a case .Const(let aVal) && b case .Const(let bVal))
	        return .Const(aVal % bVal);

	    if (a case .Var(let aVal) && b case .Var(let bVal))
	        return .Const(aVal % bVal);

	    return Const(.Undefined);
	}
}