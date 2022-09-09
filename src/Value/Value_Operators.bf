using System;
namespace ijo;

// Arithmetic operators
extension Value
{
    public static Value operator +(Value a, Value b)
    {
        if (a case .Integer(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Integer(p + int(f));
            case .Integer(let i): return .Integer(p + i);
            default: return .Undefined;
            }
        }

        if (a case .Double(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Double(p + f);
            case .Integer(let i): return .Double(p + double(i));
            default: return .Undefined;
            }
        }

        if (a case .String)
        {
            switch (b)
            {
            case .String: return .String(new $"{a}{b}");
            default: return Undefined;
            }
        }

        return .Undefined;
    }

    public static Value operator -(Value a, Value b)
    {
        if (a case .Integer(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Integer(p - int(f));
            case .Integer(let i): return .Integer(p - i);
            default: return .Undefined;
            }
        }

        if (a case .Double(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Double(p - f);
            case .Integer(let i): return .Double(p - double(i));
            default: return .Undefined;
            }
        }

        return .Undefined;
    }

    public static Value operator *(Value a, Value b)
    {
        if (a case .Integer(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Integer(p * int(f));
            case .Integer(let i): return .Integer(p * i);
            default: return .Undefined;
            }
        }

        if (a case .Double(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Double(p * f);
            case .Integer(let i): return .Double(p * double(i));
            default: return .Undefined;
            }
        }

        return .Undefined;
    }

    public static Value operator /(Value a, Value b)
    {
        if (a case .Integer(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Integer(p / int(f));
            case .Integer(let i): return .Integer(p / i);
            default: return .Undefined;
            }
        }

        if (a case .Double(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Double(p / f);
            case .Integer(let i): return .Double(p / double(i));
            default: return .Undefined;
            }
        }

        return .Undefined;
    }

    public static Value operator %(Value a, Value b)
    {
        if (a case .Integer(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Integer(p % int(f));
            case .Integer(let i): return .Integer(p % i);
            default: return .Undefined;
            }
        }

        if (a case .Double(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Double(p % f);
            case .Integer(let i): return .Double(p % double(i));
            default: return .Undefined;
            }
        }

        return .Undefined;
    }
}

// Comparison operators
extension Value
{
    public static Value operator >(Value a, Value b)
    {
        if (a case .Integer(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(p > int(f));
            case .Integer(let i): return .Bool(p > i);
            default: return .Undefined;
            }
        }

        if (a case .Double(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(p > f);
            case .Integer(let i): return .Bool(p > double(i));
            default: return .Undefined;
            }
        }

        return .Undefined;
    }

    public static Value operator >=(Value a, Value b)
    {
        if (a case .Integer(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(p >= int(f));
            case .Integer(let i): return .Bool(p >= i);
            default: return .Undefined;
            }
        }

        if (a case .Double(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(p >= f);
            case .Integer(let i): return .Bool(p >= double(i));
            default: return .Undefined;
            }
        }

        return .Undefined;
    }

    public static Value operator <(Value a, Value b)
    {
        if (a case .Integer(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(p < int(f));
            case .Integer(let i): return .Bool(p < i);
            default: return .Undefined;
            }
        }

        if (a case .Double(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(p < f);
            case .Integer(let i): return .Bool(p < double(i));
            default: return .Undefined;
            }
        }

        return .Undefined;
    }

    public static Value operator <=(Value a, Value b)
    {
        if (a case .Integer(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(p <= int(f));
            case .Integer(let i): return .Bool(p <= i);
            default: return .Undefined;
            }
        }

        if (a case .Double(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(p <= f);
            case .Integer(let i): return .Bool(p <= double(i));
            default: return .Undefined;
            }
        }

        return .Undefined;
    }

    public static Value operator ==(Value a, Value b)
    {
        if (a case .Integer(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(p == int(f));
            case .Integer(let i): return .Bool(p == i);
            default: return .Undefined;
            }
        }

        if (a case .Double(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(p.Equals(f));
            case .Integer(let i): return .Bool(p.Equals(double(i)));
            default: return .Undefined;
            }
        }

        if (a case .String(let p))
        {
            switch (b)
            {
            case .String(let p1): return .Bool(p.Equals(p1));
            default: return .Undefined;
            }
        }

        return .Undefined;
    }

    public static Value operator !=(Value a, Value b)
    {
        if (a case .Integer(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(p != int(f));
            case .Integer(let i): return .Bool(p != i);
            default: return .Undefined;
            }
        }

        if (a case .Double(let p))
        {
            switch (b)
            {
            case .Double(let f): return .Bool(!p.Equals(f));
            case .Integer(let i): return .Bool(!p.Equals(double(i)));
            default: return .Undefined;
            }
        }

        if (a case .String(let p))
        {
            switch (b)
            {
            case .String(let p1): return .Bool(!p.Equals(p1));
            default: return .Undefined;
            }
        }

        return .Undefined;
    }
}