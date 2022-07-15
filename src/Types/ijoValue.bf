using System;
namespace ijo.Types
{
    struct ijoValue : IDisposable
    {
        ijoType type = .Object;
        void* data = null;
        int32 refCount;

        public ijoType ValueType => type;
        public void* Data mut => data;

        public this(ijoType typeIn, void* dataIn)
        {
            InitValue(typeIn, dataIn);
            refCount = 1;
        }

        public void InitValue(ijoType typeIn, void* dataIn) mut
        {
            type = typeIn;

            switch (type)
            {
            case .Bool:
                data = new bool();
                *(bool*)data = AsBool(dataIn);
            case .Int:
                data = new int();
                *(int*)data = AsInt(dataIn);
            case .Double:
                data = new double();
                *(double*)data = AsDouble(dataIn);
            case .String:
                data = dataIn;
            case .Symbol:
                data = AsSymbol(dataIn);
            case .Function:
                data = new ijoFunction();
                *(ijoFunction*)data = AsFunction(dataIn);
            case .Object:
                data = new ijoObject("");
                *(ijoObject*)data = AsObject(dataIn);
            case .Enum:
                data = new ijoEnum("");
                *(ijoEnum*)data = AsEnum(dataIn);
            }
        }

        public int AsInt => AsInt(data);
        public double AsDouble => AsDouble(data);
        public bool AsBool => AsBool(data);
        public ijoFunction AsFunction => AsFunction(data);
        public ijoEnum AsEnum => AsEnum(data);
        public ijoObject AsObject => AsObject(data);
        public StringView AsSymbol => *(StringView*)data;
        public StringView AsString => *(StringView*)data;

        int AsInt(void* ptr) => *(int*)(ptr);
        double AsDouble(void* ptr) => *(double*)(ptr);
        bool AsBool(void* ptr) => *(bool*)(ptr);
        ijoFunction AsFunction(void* ptr) => *(ijoFunction*)(ptr);
        ijoEnum AsEnum(void* ptr) => *(ijoEnum*)(ptr);
        ijoObject AsObject(void* ptr) => *(ijoObject*)(ptr);
        char8* AsSymbol(void* ptr) => (char8*)ptr;
        char8* AsString(void* ptr) => (char8*)ptr;

        public bool IsNumber() => type == .Int || type == .Double;

        public void ReduceRefCount() mut => refCount -= 1;

        public void Print()
        {
            switch (type)
            {
            case .Bool: Console.Write(AsBool);
            case .Int: Console.Write(AsInt);
            case .Double: Console.Write(AsDouble);
            case .Symbol: Console.Write(AsSymbol);
            case .Function: Console.Write(scope $"$(Function({AsFunction.Name})");
            case .Object: Console.Write(scope $"${{Object({AsObject.Name})");
            case .Enum: Console.Write(scope $"$|Enum({AsEnum.Name})");
            case .String: Console.Write(AsString);
            }
        }

        public void PrintLine()
        {
            Print();
            Console.WriteLine();
        }

        public void Dispose()
        {
            switch (type)
            {
            case .String,.Symbol: break;
            default: delete data;
            }
        }
    }

    // Construction of ijoValue
    extension ijoValue
    {
        public static ijoValue Nil()
        {
            ijoValue val = .(.Symbol, ":nil");
            return val;
        }

        public static ijoValue Bool(bool value)
        {
            var value;
            return ijoValue(.Bool, &value);
        }

        public static ijoValue Int(int value)
        {
            var value;
            return ijoValue(.Int, &value);
        }

        public static ijoValue Double(double value)
        {
            var value;
            return ijoValue(.Double, &value);
        }

        public static ijoValue From(ijoValue other)
        {
            var other;
            let type = other.ValueType;

            ijoValue val;

            switch (type)
            {
            case .Bool:
                bool newVal;
                Internal.MemCpy(&newVal, other.Data, type.Size());
                val = ijoValue(type, &newVal);
            case .Int:
                int newVal;
                Internal.MemCpy(&newVal, other.Data, type.Size());
                val = ijoValue(type, &newVal);
            case .Double:
                double newVal;
                Internal.MemCpy(&newVal, other.Data, type.Size());
                val = ijoValue(type, &newVal);
            case .String:
                let size = other.AsString.Length;
                var newVal = new char8[size];
                Internal.MemCpy(&newVal, other.Data, size);
                val = ijoValue(type, &newVal);
            case .Symbol:
                let size = other.AsSymbol.Length;
                var newVal = new char8[size];
                Internal.MemCpy(&newVal, other.Data, size);
                val = ijoValue(type, &newVal);
            case .Object:
                var obj = other.AsObject;
                let size = obj.Size();
                var newVal = new uint8[size];

                Internal.MemCpy(&newVal, &obj, size);
                val = ijoValue(type, newVal.Ptr);
            case .Function:
                var func = other.AsFunction;
                let size = func.Size();
                var newVal = new uint8[size];

                Internal.MemCpy(&newVal, &func, size);
                val = ijoValue(type, newVal.Ptr);
            case .Enum:
                var obj = other.AsEnum;
                let size = obj.Size();
                var newVal = new uint8[size];

                Internal.MemCpy(&newVal, &obj, size);
                val = ijoValue(type, newVal.Ptr);
            }

            return val;
        }
    }

    // Operations on ijoValue
    extension ijoValue
    {
        public static ijoValue operator +(Self a, Self b)
        {
            if (a.ValueType case .Int && b.ValueType case .Int)
            {
                var val = a.AsInt + b.AsInt;
                return ijoValue(.Int, &val);
            }

            if (a.ValueType case .Double && b.ValueType case .Double)
            {
                var val = a.AsDouble + b.AsDouble;
                return ijoValue(.Int, &val);
            }

            return ijoValue.Nil();
        }

        public static ijoValue operator -(Self a, Self b)
        {
            if (a.ValueType case .Int && b.ValueType case .Int)
            {
                var val = a.AsInt - b.AsInt;
                return ijoValue(.Int, &val);
            }

            if (a.ValueType case .Double && b.ValueType case .Double)
            {
                var val = a.AsDouble - b.AsDouble;
                return ijoValue(.Int, &val);
            }

            return ijoValue.Nil();
        }

        public static ijoValue operator -(Self a)
        {
            if (a.ValueType case .Int)
            {
                var val = -a.AsInt;
                return ijoValue(.Int, &val);
            }

            if (a.ValueType case .Double)
            {
                var val = -a.AsDouble;
                return ijoValue(.Int, &val);
            }

            return ijoValue.Nil();
        }

        public static ijoValue operator /(Self a, Self b)
        {
            if (a.ValueType case .Int && b.ValueType case .Int)
            {
                var val = a.AsInt / b.AsInt;
                return ijoValue(.Int, &val);
            }

            if (a.ValueType case .Double && b.ValueType case .Double)
            {
                var val = a.AsDouble / b.AsDouble;
                return ijoValue(.Int, &val);
            }

            return ijoValue.Nil();
        }

        public static ijoValue operator *(Self a, Self b)
        {
            if (a.ValueType case .Int && b.ValueType case .Int)
            {
                var val = a.AsInt * b.AsInt;
                return ijoValue(.Int, &val);
            }

            if (a.ValueType case .Double && b.ValueType case .Double)
            {
                var val = a.AsDouble * b.AsDouble;
                return ijoValue(.Int, &val);
            }

            return ijoValue.Nil();
        }

        public static ijoValue operator %(Self a, Self b)
        {
            if (a.ValueType case .Int && b.ValueType case .Int)
            {
                var val = a.AsInt % b.AsInt;
                return ijoValue(.Int, &val);
            }

            if (a.ValueType case .Double && b.ValueType case .Double)
            {
                var val = a.AsDouble % b.AsDouble;
                return ijoValue(.Int, &val);
            }

            return ijoValue.Nil();
        }

        [Commutable]
        public static ijoValue operator >(Self a, Self b)
        {
            if (a.ValueType case .Int && b.ValueType case .Int)
            {
                return ijoValue.Bool(a.AsInt > b.AsInt);
            }

            if (a.ValueType case .Double && b.ValueType case .Double)
            {
                return ijoValue.Bool(a.AsDouble.CompareTo(b.AsDouble) == 1);
            }

            return ijoValue.Bool(false);
        }

        [Commutable]
        public static ijoValue operator ==(Self a, Self b)
        {
            if (a.type != b.type)
                return Bool(false);

            if (a.ValueType case .Int)
            {
                return ijoValue.Bool(a.AsInt == b.AsInt);
            }

            if (a.ValueType case .Double)
            {
                return ijoValue.Bool(a.AsDouble.CompareTo(b.AsDouble) == 0);
            }

            if (a.ValueType case .Symbol)
            {
                let strA = StringView(a.AsSymbol);
                let strB = StringView(b.AsSymbol);
                return ijoValue.Bool(strA.Equals(strB));
            }

            if (a.ValueType case .String)
            {
                let strA = StringView(a.AsString);
                let strB = StringView(b.AsString);
                return ijoValue.Bool(strA.Equals(strB));
            }

            return Bool(false);
        }

        public static ijoValue operator !(Self value)
        {
            if (value.ValueType case .Bool)
                return ijoValue.Bool(!value.AsBool);

            return ijoValue.Nil();
        }
    }
}