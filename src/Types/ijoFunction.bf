using System;
namespace ijo.Types
{
    struct ijoFunction
    {
        public StringView Name { get; private set mut; }
        public int32 Size() => sizeof(ijoFunction);

        public this(StringView name = "__anon")
        {
            Name = name;
        }
    }
}