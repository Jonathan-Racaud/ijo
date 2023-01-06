using System;
namespace ijo;

enum OpCode : uint16
{
    case ConstantI;
    case ConstantD;
    case String;
    case Symbol;

    case VarDef;
    case ConstDef;
    case Identifier;
    case VarSet;

    case Add;
    case Subtract;
    case Multiply;
    case Divide;
    case Modulo;

    case True;
    case False;
    case Undefined;

    case Equal;
    case NotEqual;
    case Greater;
    case GreaterThan;
    case Less;
    case LessThan;
    case IsTrue;

    case Not;
    case Negate;
    case Opposite;

    case Print;
    case Read;

    case LoadArg;
    case Call;

    case Jump;
    case Break;
    case Return;

    public static operator uint16(OpCode code)
    {
        return code.Underlying;
    }

    public static operator OpCode(uint16 code)
    {
        return (OpCode)code;
    }

    public StringView Str
    {
        get
        {
            switch (this)
            {
            case .ConstantD: return "OP_CONST_D";
            case .ConstantI: return "OP_CONST_I";
            case .String: return "OP_STR";
            case .Symbol: return "OP_SYM";

            case .Add: return "OP_ADD";
            case .Subtract: return "OP_SUB";
            case .Multiply: return "OP_MUL";
            case .Divide: return "OP_DIV";
            case .Modulo: return "OP_MOD";

            case .True: return "OP_TRUE";
            case .False: return "OP_FALSE";
            case .Undefined: return "OP_UNDEFINED";

            case .Equal: return "OP_EQ";
            case .Greater: return "OP_GT";
            case .GreaterThan: return "OP_GTEQ";
            case .Less: return "OP_LESS";
            case .LessThan: return "OP_LESSEQ";
            case .IsTrue: return "OP_IS_TRUE";

            case .Not: return "OP_NOT";
            case .Negate: return "OP_NEG";
            case .Opposite: return "OP_OPP";

            case .Print: return "OP_PRINT";
            case .Read: return "OP_READ";
            case .VarDef: return "OP_VAR";
            case .ConstDef: return "OP_CONST";
            case .Identifier: return "OP_IDENTIFIER";

            case .LoadArg: return "OP_LDARG";

            case Jump: return "OP_JUMP";
            case Break: return "OP_BREAK";
            case Return: return "OP_RET";
            default: return "OP_UNKNOWN";
            }
        }
    }
}