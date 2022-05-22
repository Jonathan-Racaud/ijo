using System;
using ijo.Scope;
namespace ijo.Interpreter
{
	enum InterpretError
	{
		case NoError;
		case CouldNotEvaluate;
		case OperandMustBeANumber(Token);
		case OperandsMustBeNumbers(Token);
		case VariableError(ScopeError);
		case CallNonFunction(String);
		case InvalidArgumentCount;

		public static operator StringView(Self value)
		{
			switch (value)
			{
			case .NoError: return "No Error";
			case .CouldNotEvaluate: return "Could not evaluate expression";
			case .OperandMustBeANumber(let t): return scope $"Operand must be a number at: {t.Lexeme}";
			case .OperandsMustBeNumbers(let t): return scope $"Operands must be numbers at: {t.Lexeme}";
			case .VariableError(let e): return scope $"Error with variable: {e}";
			case .CallNonFunction(let func): return scope $"Trying to call a non function: {func}";
			case .InvalidArgumentCount: return "Invalid argument count";
			}
		}
	}
}