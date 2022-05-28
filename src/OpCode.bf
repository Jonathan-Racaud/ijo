using System;

namespace ijo
{
	enum OpCode: uint8
	{
		case Constant;
		case ConstantLong;
		case Exit; // Exit a function from anywhere

		public static operator uint8(Self code) => (uint8)code;
		public static operator OpCode(uint8 code) => (OpCode)code;

		public static operator StringView(Self code)
		{
			switch (code)
			{
			case .Constant: return "OP_CONSTANT";
			case .ConstantLong: return "OP_CONSTANT_LONG";
			case .Exit: return "OP_EXIT";
			default: return "OP_UNKNOWN";
			}
		}
	}
}