using System;
namespace ijo;

enum Value
{
    case Integer(int);
    case Double(double);
    case Bool(bool);
    case String(String);
    case Symbol(String);
    // The parameter represent the number of arguments
    // The object is its return type
    case Function(FuncDefinition);
    case Undefined;
}

enum ReturnType
{
    case Integer;
    case Double;
    case Bool;
    case String;
    case Symbol;
    case Function;
    case Undefined;
}

extension Value : IDisposable
{
    public void Dispose()
    {
        if (this case .String(let p0)) delete p0;
    }
}

extension Value : IFormattable
{
    public void Print()
    {
        switch (this)
        {
        case .Integer(let val): Console.Write(val);
        case .Double(let val): Console.Write(val);
        case .Bool(let val): Console.Write(val);
        case .String(let val): Console.Write(val);
        case .Symbol(let val): Console.Write(val);
        case .Function: Console.Write("Function");
        case .Undefined: Console.Write(Default.Undefined);
        }
    }

    public void ToString(String outString, String format, IFormatProvider formatProvider)
    {
        outString.Clear();

        switch (this)
        {
        case .Integer(let val): ToString(val, format, formatProvider, outString);
        case .Double(let val): ToString(val, format, formatProvider, outString);
        case .Bool(let val): if (val) outString.Set(Default.True); else outString.Set(Default.False);
        case .String(let val): outString.Set(val);
        case .Symbol(let val): outString.Set(val);
        case .Function: outString.Set("Function");
        case .Undefined: outString.Set(Default.Undefined);
        }
    }

    void ToString(int val, String format, IFormatProvider formatProvider, String outString)
    {
        if (format == null || format.IsEmpty)
        {
            outString.Set(scope $"{val}");
        }
        else
        {
            NumberFormatter.NumberToString(format, val, formatProvider, outString);
        }
    }

    void ToString(double val, String format, IFormatProvider formatProvider, String outString)
    {
        if (format == null || format.IsEmpty)
        {
            outString.Set(scope $"{val}");
        }
        else
        {
            NumberFormatter.NumberToString(format, val, formatProvider, outString);
        }
    }
}