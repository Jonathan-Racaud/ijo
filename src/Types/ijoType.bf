namespace ijo.Types
{
    enum ijoType
    {
        case Int;
        case Double;
        case Bool;
        case Symbol;
        case Function;
        case Enum;
        case Object;

        public int Size()
        {
            switch (this)
            {
            case .Int: return sizeof(int32);
            case .Double: return sizeof(double);
            case .Bool: return sizeof(bool);
            case .Symbol: return 0;
            case .Function: return 0;
            case .Enum: return 0;
            case .Object: return 0;
            }
        }
    }
}