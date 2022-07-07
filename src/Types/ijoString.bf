using System;

namespace ijo.Types
{
    struct ijoString : ijoObject
    {
        private String string = new .();

        public this(StringView name) : base(name)
        {
        }

        new public void Dispose()
        {
            base.Dispose();
            delete string;
        }
    }
}