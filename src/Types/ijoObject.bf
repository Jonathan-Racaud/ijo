using System;
using System.Collections;

namespace ijo.Types
{
    struct ijoObject : IDisposable
    {
        public StringView Name { get; private set mut; }
        public int32 Size() => sizeof(ijoObject) + slots.[Friend]mAllocSize;

        protected ijoType type { get; } = .Object;
        protected int32 refCount = 0;
        protected Dictionary<StringView, ijoValue*> slots = null;

        public this(StringView name)
        {
            Name = name;
            refCount += 1;
        }

        public void Dispose()
        {
            delete slots;
        }

        public void setSlot(StringView name, ijoValue* address) mut
        {
            if (slots == null) slots = new .();
            slots[name] = address;
        }

        public ijoValue getSlot(StringView name)
        {
            if (!slots.ContainsKey(name))
                return ijoValue.Nil();

            return *((ijoValue*)slots[name]);
        }

        public ijoObject Clone(StringView name)
        {
            var x = ijoObject(name);
            x.slots = CloneSlots();

            return x;
        }

        Dictionary<StringView, ijoValue*> CloneSlots()
        {
            var cloned = new Dictionary<StringView, ijoValue*>();

            for (let slot in slots)
            {
                var x = ijoValue.From(*slot.value);
                cloned[slot.key] = &x;
            }

            return cloned;
        }
    }
}