using System;
using System.Collections;
namespace ijo
{
    enum ijoTypes
    {
        Int,
        Double,
        Bool,
        Object,
    }

    enum ijoVal
    {
        case Int(int32);
        case Double(double);
        case Bool(bool);
        case Function;
        case Nil;

        public static ijoVal From(void* other) => From(*((ijoVal*)other));
        public static ijoVal From(ijoVal other)
        {
            switch (other)
            {
            case .Int(let p0): return .Int(p0);
            case .Double(let p0): return .Double(p0);
            case .Bool(let p0): return .Bool(p0);
            case .Nil: return .Nil;
            }
        }
    }

    struct ijoObject : IDisposable
    {
        protected ijoTypes ijotype { get; } = .Object;
        protected int32 referenceCount = 0;
        protected Dictionary<StringView, void*> slots = null;

        public this()
        {
            referenceCount += 1;
        }

        public void Dispose()
        {
            delete slots;
        }

        public void setSlot(StringView name, void* address) mut
        {
            if (slots == null) slots = new .();
            slots[name] = address;
        }

        public ijoVal getSlot(StringView name)
        {
            if (!slots.ContainsKey(name))
                return .Nil;

            return *((ijoVal*)slots[name]);
        }

        public ijoObject Clone()
        {
            var x = ijoObject();
            x.slots = CloneSlots();

            return x;
        }

        Dictionary<StringView, void*> CloneSlots()
        {
            var cloned = new Dictionary<StringView, void*>();

            for (let slot in slots)
            {
                var x = ijoVal.From(slot.value);
                cloned[slot.key] = &x;
            }

            return cloned;
        }
    }

    struct ijoInt : ijoObject
    {
        ijoVal __value = .Int(0);

        public this(ijoVal val)
        {
            referenceCount += 1;
            __value = val;
            setSlot("__value", &__value);
        }
    }
}