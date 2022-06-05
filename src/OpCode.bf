using System;

namespace ijo
{
    enum OpCode : uint8
    {
        case Constant;
        case ConstantLong;
        case Negate;
        case Add;
        case Subtract;
        case Multiply;
        case Divide;
        case Modulo;
        case Return; // Exit a function from anywhere

        public static operator uint8(Self code) => (uint8)code;
        public static operator OpCode(uint8 code) => (OpCode)code;

        public static operator StringView(Self code)
        {
            switch (code)
            {
            case .Constant: return "OP_CONSTANT";
            case .ConstantLong: return "OP_CONSTANT_LONG";
            case .Negate: return "OP_NEGATE";
            case .Add: return "OP_ADD";
            case .Subtract: return "OP_SUBTRACT";
            case .Multiply: return "OP_MULTIPLY";
            case .Divide: return "OP_DIVIDE";
            case .Modulo: return "OP_MODULO";
            case .Return: return "OP_RETURN";
            default: return "OP_UNKNOWN";
            }
        }
    }
}