using System;

namespace ijo
{
	enum EnvError
	{
		case AssignToConstVariable(StringView);
		case VariableAlreadyDeclared(StringView);
		case UndefinedVariable(StringView);
	}
}