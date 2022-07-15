using System;

namespace ijo
{
    enum OpCode : uint8
    {
        case Constant;
        case ConstantLong;
        case InternString;
        case InternStringLong;
        case Symbol;
        case SymbolLong;
        case Nil;
        case True;
        case False;
        case Equal;
        case Greater;
        case Less;
        case Negate;
        case Not;
        case Add;
        case Subtract;
        case Multiply;
        case Divide;
        case Modulo;
        case Print;
        case Pop;
        case Return; // Exit a function from anywhere

        public static operator uint8(Self code) => (uint8)code;
        public static operator OpCode(uint8 code) => (OpCode)code;

        public static operator StringView(Self code)
        {
            switch (code)
            {
            case .Constant: return "OP_CONSTANT";
            case .ConstantLong: return "OP_CONSTANT_LONG";
            case .InternString: return "OP_INTERN_STRING";
            case .InternStringLong: return "OP_INTERN_STRING_LONG";
            case .Symbol: return "OP_INTERN_STRING";
            case .SymbolLong: return "OP_INTERN_STRING_LONG";
            case .Nil: return "OP_NIL";
            case .True: return "OP_TRUE";
            case .False: return "OP_FALSE";
            case .Equal: return "OP_EQUAL";
            case .Greater: return "OP_GREATER";
            case .Less: return "OP_LESS";
            case .Negate: return "OP_NEGATE";
            case .Not: return "OP_NOT";
            case .Add: return "OP_ADD";
            case .Subtract: return "OP_SUBTRACT";
            case .Multiply: return "OP_MULTIPLY";
            case .Divide: return "OP_DIVIDE";
            case .Modulo: return "OP_MODULO";
            case .Return: return "OP_RETURN";
            case .Print: return "OP_PRINT";
            case .Pop: return "OP_POP";
            default: return "OP_UNKNOWN";
            }
        }
    }
}