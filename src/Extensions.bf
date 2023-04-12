namespace System
{
    extension StringView
    {
        public static operator StringView(char8* str)
        {
            return .(str);
        }

        public void Print()
        {
            Console.Write(this);
        }
    }
}

namespace System.IO
{
    extension Stream
    {
        public Result<void>  WriteLine(String val)
        {
            let res = this.Write(val);

            switch (res)
            {
                case .Err: return .Err;
                default: break;
            }

            return this.Write("\n");
        }
    }
}