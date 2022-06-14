using System;
using System.Collections;
namespace ijo.Types
{
    struct ijoEnum
    {
        public StringView Name { get; private set mut; }
        public Dictionary<StringView, ijoValue> Cases { get; } = null

        public int32 Size() => sizeof(ijoEnum) + Cases.[Friend]mAllocSize;

        public this(StringView name)
        {
            Name = name;
        }
    }
}