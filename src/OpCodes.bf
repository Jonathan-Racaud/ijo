namespace ijo;

enum OpCode : uint16
{
    case Constant;
    case String;
    case Symbol;

    case Add;
    case Subtract;
    case Multiply;
    case Divide;
    case Modulo;

    case True;
    case False;
    case Undefined;

    case Equal;
    case Greater;
    case GreaterThan;
    case Less;
    case LessThan;

    case Not;
    case Negate;

    case Break;
    case Return;
}