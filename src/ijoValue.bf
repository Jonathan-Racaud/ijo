using System;
namespace ijo
{
    enum ijoValue
    {
        case Bool(bool value);
        case Nil;
        case Number(double value);

        public void Print()
        {
            switch (this)
            {
            case .Bool(let value): Console.Write(scope $"{value}");
            case .Nil: Console.Write("nil");
            case .Number(let value): Console.Write(scope $"{value}");
            }
        }

        public void PrintLine()
        {
            Print();
            Console.WriteLine();
        }

        public double Double() => this case .Number(let value) ? value : double.NaN;
        public bool Boolean() => this case .Bool(let value) ? value : false;

        public bool IsNumber() => this case .Number ? true : false;
        public bool IsBool() => this case .Bool ? true : false;
        public bool IsNil() => this case .Nil ? true : false;

        public static operator ijoValue(double value) => ijoValue.Number(value);
        public static operator ijoValue(bool value) => ijoValue.Bool(value);

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

        public static ijoValue operator !(Self value)
        {
            switch (value)
            {
            case .Nil,Number: return value;
            case .Bool(let val): return .Bool(!val);
            }
        }
    }
}