using System;
namespace ijo
{
    struct ijoObj
    {
        public ijoType Type;

        public this(ijoType type = .Nil) { Type = type; }
    }

    enum ijoType
    {
        case String;
        case Number;
        case Bool;
        case Nil;
    }

    /*struct ijoString : ijoObj
    {
        public int Length { get; private set mut; } = 0;
        public char8* Characters { get; private set mut; } = ""

        public this() : base(.String) { }
        public this(char8* chars, int length) : base(.String)
        {
            Characters = chars;
            Length = length;
        }

        public static ijoString Copy(char8* chars, int length)
        {
            var heapChar = new char8[length];
            Internal.MemCpy(&heapChar, chars, length);

            return ijoString(heapChar.CArray(), length);
        }
    }*/
}