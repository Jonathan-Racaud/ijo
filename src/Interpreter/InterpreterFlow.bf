using System;
namespace ijo.Interpreter
{
	enum InterpreterFlow
	{
		case Normal;
		case Return(Variant);
	}
}