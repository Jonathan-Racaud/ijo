using System;
namespace ijo
{
    enum ijoValue
    {
        case Bool(bool value);
        case Nil;
        case Number(double value);
        case Obj(ijoObj obj);

        public void Print()
        {
            switch (this)
            {
            case .Bool(let value): Console.Write(scope $"{value}");
            case .Nil: Console.Write("nil");
            case .Number(let value): Console.Write(scope $"{value}");
            case .Obj(let obj): Console.Write(scope $"{obj}");
            }
        }

        public void PrintLine()
        {
            Print();
            Console.WriteLine();
        }

        public double Double() => this case .Number(let value) ? value : double.NaN;
        public bool Boolean() => this case .Bool(let value) ? value : false;
        public ijoObj Object() => this case .Obj(let obj) ? obj : default;
        public ijoType Type()
        {
            switch (this)
            {
            case .Bool: return .Bool;
            case .Number: return .Number;
            case .Nil: return .Nil;
            case .Obj(let obj): return obj.Type;
            }
        }

        public bool IsNumber() => this case .Number ? true : false;
        public bool IsBool() => this case .Bool ? true : false;
        public bool IsNil() => this case .Nil ? true : false;
        public bool IsObject() => this case .Obj ? true : false;

        public static operator ijoValue(double value) => ijoValue.Number(value);
        public static operator ijoValue(bool value) => ijoValue.Bool(value);
        public static operator ijoValue(ijoObj obj) => ijoValue.Obj(obj);

        public static ijoValue operator +(Self a, Self b)
        {
            if (a case .Number(let aVal) && b case .Number(let bVal))
                return aVal + bVal;

            return .Nil;
        }

        public static ijoValue operator -(Self a, Self b)
        {
            if (a case .Number(let aVal) && b case .Number(let bVal))
                return aVal - bVal;

            return .Nil;
        }

        public static ijoValue operator /(Self a, Self b)
        {
            if (a case .Number(let aVal) && b case .Number(let bVal))
                return aVal / bVal;

            return .Nil;
        }

        public static ijoValue operator *(Self a, Self b)
        {
            if (a case .Number(let aVal) && b case .Number(let bVal))
                return aVal * bVal;

            return .Nil;
        }

        public static ijoValue operator %(Self a, Self b)
        {
            if (a case .Number(let aVal) && b case .Number(let bVal))
                return aVal % bVal;

            return .Nil;
        }

        [Commutable]
        public static ijoValue operator >(Self a, Self b)
        {
            if (a case .Number(let aVal) && b case .Number(let bVal))
                return aVal > bVal;

            return .Bool(false);
        }

        [Commutable]
        public static ijoValue operator ==(Self a, Self b)
        {
            if (a case .Number(let aVal) && b case .Number(let bVal))
                return aVal == bVal;

            if (a case .Bool(let aVal) && b case .Bool(let bVal))
                return aVal == bVal;

            if (a case .Nil && b case .Nil)
                return true;

            return .Bool(false);
        }

        public static ijoValue operator !(Self value)
        {
            switch (value)
            {
            case .Nil,Number: return value;
            case .Bool(let val): return .Bool(!val);
            default: return value;
            }
        }
    }
}