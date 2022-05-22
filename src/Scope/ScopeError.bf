using System;

namespace ijo.Scope
{
	enum ScopeError
	{
		case AssignToConstVariable(StringView);
		case VariableAlreadyDeclared(StringView);
		case UndefinedVariable(StringView);
	}
}