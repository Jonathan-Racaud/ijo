namespace System
{
    extension StringView
    {
        public static operator StringView(char8* str)
        {
            return .(str);
        }
    }
}